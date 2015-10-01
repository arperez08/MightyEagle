//
//  MyScene.m
//  FlappyBird
//
//  Created by Srikanth KV on 20/02/14.
//  Copyright (c) 2014 mytechspace. All rights reserved.
//

#import "MyScene.h"
#import "StartGameLayer.h"
#import "GameOverLayer.h"
#import "InstructionGameLayer.h"
#import "FinishedGameLayer.h"

#define TIME 2.0
#define MINIMUM_PILLER_HEIGHT 100.0f
#define GAP_BETWEEN_TOP_AND_BOTTOM_PILLER 220.0f

#define PILLARS     @"Pillars"
#define UPWARD_PILLER @"Upward_Green_Pipe"
#define Downward_PILLER @"Downward_Green_Pipe"
#define AIRPLANE @"Airplane"

#define BOTTOM_BACKGROUND_Z_POSITION    100
#define START_GAME_LAYER_Z_POSITION     150
#define GAME_OVER_LAYER_Z_POSITION      200

static const uint32_t pillerCategory            =  0x1 << 0;
static const uint32_t flappyBirdCategory        =  0x1 << 1;
static const uint32_t bottomBackgroundCategory  =  0x1 << 2;
static const uint32_t cementCategory            =  0x1 << 3;
static const uint32_t cloudCategory             =  0x1 << 4;

static const float BG_VELOCITY = (TIME * 60);

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@interface MyScene() <SKPhysicsContactDelegate,
                      StartGameLayerDelegate,GameOverLayerDelegate,InstructionGameLayerDelegate,FinishedGameLayerDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
    
    BOOL _gameStarted;
    BOOL _gameOver;
    BOOL _intialGame;
    
    StartGameLayer* _startGameLayer;
    GameOverLayer* _gameOverLayer;
    InstructionGameLayer* _instructionGameLayer;
    FinishedGameLayer* _finishedGameLayer;
    
    int _score;
    SKLabelNode* _scoreLabelNode;
    SKSpriteNode * _scoreHolder;
    
    
    SKColor* _skyColor;
    SKNode* _moving;
    
    BOOL _canRestart;
    
}
@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) SKSpriteNode* flappyBird;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) NSArray* flappyBirdFrames;
@end


@implementation MyScene

static const uint32_t worldCategory = 1 << 1;

#pragma mark - Initializations
-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        //Initialize the static background
        [self initializeBackGround:size];
        
        
        [self initalizingTopScrollingBackground];

        
        //Initialize moving background
        [self initalizingScrollingBackground];
        
        //Initialize Bird
        [self initializeBird];
        
        [self initializeStartGameLayer];
        [self initializeGameOverLayer];
        [self initializeInstructionGameLayer];
        [self initializeFinishedGameLayer];
        
        
        //Set gravity to 0 so that bird remains in its position in start page
        self.physicsWorld.gravity = CGVectorMake(0, 0.0);
        
        //To detect collision detection
        self.physicsWorld.contactDelegate = self;
        
        _gameOver = NO;
        _gameStarted = NO;
    
        [self showStartGameLayer];
    }
    return self;
}

- (void) initializeBackGround:(CGSize) size
{
    self.backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"Night_Background"];
    self.backgroundImageNode.size = size;
    self.backgroundImageNode.position = CGPointMake(self.backgroundImageNode.size.width/2, self.frame.size.height/2);
    //[self addChild:self.backgroundImageNode];
    
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
    self.physicsWorld.contactDelegate = self;
    
    _skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
    [self setBackgroundColor:_skyColor];
    
    _moving = [SKNode node];
    [self addChild:_moving];
    
    // Create ground
    SKTexture* groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    
//    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02 * groundTexture.size.width*2];
//    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
//    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
    
//    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width * 2 ); ++i ) {
//        // Create the sprite
//        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
//        [sprite setScale:2.0];
//        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
//        [sprite runAction:moveGroundSpritesForever];
//        [_moving addChild:sprite];
//    }
    
    // Create skyline
    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;
    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.1 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
    
    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        [sprite setScale:2.0];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size.height);
        [sprite runAction:moveSkylineSpritesForever];
        [_moving addChild:sprite];
    }
}



-(void)initalizingTopScrollingBackground
{
    for (int i = 0; i < 10; i++)
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"dark_cloudy"];
        bg.zPosition = 100;
        bottomScrollerHeight = bg.size.height;
        bg.position = CGPointMake((i * bg.size.width) + (bg.size.width * 0.5f) - 1, 780);
        bg.name = @"bg";
        
        /*
         * Create a physics and specify its geometrical shape so that collision algorithm can work more prominently
         */
        bg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bg.size];
        
        //Category to which this object belongs to
        bg.physicsBody.categoryBitMask = bottomBackgroundCategory;
        
        //To notify intersection with objects
        bg.physicsBody.contactTestBitMask = flappyBirdCategory;
        
        //To detect collision with category of objects
        bg.physicsBody.collisionBitMask = 0;
        
        /*
         * Has to be explicitely mentioned. If not mentioned, bg starts moving down because of gravity.
         */
        bg.physicsBody.affectedByGravity = NO;
        [self addChild:bg];
    }
}




-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 10; i++)
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Bottom_Scroller"];
        bg.zPosition = BOTTOM_BACKGROUND_Z_POSITION;
        bottomScrollerHeight = bg.size.height;
        bg.position = CGPointMake((i * bg.size.width) + (bg.size.width * 0.5f) - 1, bg.size.height * 0.5f);
        bg.name = @"bg";
        
        /*
         * Create a physics and specify its geometrical shape so that collision algorithm can work more prominently
         */
        bg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bg.size];
        
        //Category to which this object belongs to
        bg.physicsBody.categoryBitMask = bottomBackgroundCategory;
        
        //To notify intersection with objects
        bg.physicsBody.contactTestBitMask = flappyBirdCategory;
        
        //To detect collision with category of objects
        bg.physicsBody.collisionBitMask = 0;
        
        /*
         * Has to be explicitely mentioned. If not mentioned, bg starts moving down because of gravity.
         */
        bg.physicsBody.affectedByGravity = NO;
        [self addChild:bg];
    }
}

#pragma mark -Initialize Bird
- (void)initializeBird
{
    NSMutableArray *flappyBirdFrames = [NSMutableArray array];
    for (int i = 0; i < 3; i++)
    {
        NSString* textureName = nil;
        switch (i)
        {
            case 0:
            {
                textureName = @"Yellow_Bird_Wing_Up";
                break;
            }
            case 1:
            {
                textureName = @"Yellow_Bird_Wing_Straight";
                break;
            }
            case 2:
            {
                textureName = @"Yellow_Bird_Wing_Down";
                break;
            }
            default:
                break;
        }
        
        SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
        [flappyBirdFrames addObject:texture];
    }
    [self setFlappyBirdFrames:flappyBirdFrames];
    
    self.flappyBird = [SKSpriteNode spriteNodeWithTexture:[flappyBirdFrames objectAtIndex:1]];
    /*
     * Create a physics and specify its geometrical shape so that collision algorithm
     * can work more prominently
     */
    _flappyBird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_flappyBird.size];
    
    //Category to which this object belongs to
    _flappyBird.physicsBody.categoryBitMask = flappyBirdCategory;
    
    //To notify intersection with objects
    _flappyBird.physicsBody.contactTestBitMask = pillerCategory | bottomBackgroundCategory;
    
    //To detect collision with category of objects
    _flappyBird.physicsBody.collisionBitMask = 0;
    
    [self addChild:self.flappyBird];
}

- (void) flyingBird
{
    //This is our general runAction method to make our flappy bird fly.
    [_flappyBird runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:_flappyBirdFrames
                                       timePerFrame:0.15f
                                             resize:NO
                                            restore:YES]] withKey:@"flyingFlappyBird"];
    return;
}

#pragma mark -Initialize Helper Layers
- (void) initializeStartGameLayer
{
    _startGameLayer = [[StartGameLayer alloc]initWithSize:self.size];
    _startGameLayer.userInteractionEnabled = YES;
    _startGameLayer.zPosition = START_GAME_LAYER_Z_POSITION;
    _startGameLayer.delegate = self;
}

- (void) initializeInstructionGameLayer
{
    _instructionGameLayer = [[InstructionGameLayer alloc]initWithSize:self.size];
    _instructionGameLayer.userInteractionEnabled = YES;
    _instructionGameLayer.zPosition = START_GAME_LAYER_Z_POSITION;
    _instructionGameLayer.delegate = self;
}

- (void) initializeFinishedGameLayer
{
    _finishedGameLayer = [[FinishedGameLayer alloc]initWithSize:self.size];
    _finishedGameLayer.userInteractionEnabled = YES;
    _finishedGameLayer.zPosition = START_GAME_LAYER_Z_POSITION;
    _finishedGameLayer.delegate = self;
}

- (void) initializeGameOverLayer
{
    _gameOverLayer = [[GameOverLayer alloc]initWithSize:self.size];
    _gameOverLayer.userInteractionEnabled = YES;
    _gameOverLayer.zPosition = GAME_OVER_LAYER_Z_POSITION;
    _gameOverLayer.delegate = self;
}

#pragma mark - GameStatus calls
- (void) showStartGameLayer
{
    //Remove currently exising on pillars from scene and purge them
    for (int i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == pillerCategory)
        {
            [childNode removeFromParent];
        }
    }
    
    //Move Flappy Bird node to center of the scene
    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.5f, self.frame.size.height * 0.6f);
    
    [_gameOverLayer removeFromParent];
    [_finishedGameLayer removeFromParent];
    [_instructionGameLayer removeFromParent];
    
    _flappyBird.zRotation = 0.0;
    _flappyBird.hidden = NO;
    
    [self flyingBird];
    [self addChild:_startGameLayer];
}

- (void) showInstructionGameLayer
{
    //Remove currently exising on pillars from scene and purge them
    for (int i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == pillerCategory)
        {
            [childNode removeFromParent];
        }
    }
    
    //Move Flappy Bird node to center of the scene
    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.5f, self.frame.size.height * 0.6f);
    
    
    [_startGameLayer removeFromParent];
    [_gameOverLayer removeFromParent];
    
    _flappyBird.zRotation = 0.0;
    _flappyBird.hidden = NO;
    
    [self flyingBird];
    [self addChild:_instructionGameLayer];
}

- (void) showFinishedGameLayer
{
    //Remove currently exising on pillars from scene and purge them
    for (int i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == cementCategory)
        {
            [childNode removeAllActions];
            [childNode removeFromParent];
        }
        
        if(childNode.physicsBody.categoryBitMask == pillerCategory)
        {
            [childNode removeAllActions];
            [childNode removeFromParent];
        }
        
    }
    
    [_flappyBird removeAllActions];
    _flappyBird.physicsBody.velocity = CGVectorMake(0, 0);
    self.physicsWorld.gravity = CGVectorMake(0, 0.0);
    _flappyBird.hidden = NO;
    
    _gameOver = NO;
    _gameStarted = NO;
    
    _dt = 0;
    _lastUpdateTimeInterval = 0;
    _lastSpawnTimeInterval = 0;
    
    
    //Move Flappy Bird node to center of the scene
    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.5f - 100, self.frame.size.height * 0.6f);
    _flappyBird.zRotation = 0.0;
    _flappyBird.hidden = NO;
    [self flyingBird];
    
    [_startGameLayer removeFromParent];
    [_instructionGameLayer removeFromParent];
    [_gameOverLayer removeFromParent];
    [self addChild:_finishedGameLayer];
 
    _scoreHolder.position= CGPointMake(645, 490);
    _scoreLabelNode.position = CGPointMake(650, 470);
}

- (void) showGameOverLayer
{
    //Remove currently exising on pillars from scene and purge them
    for (int i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == cementCategory)
        {
            [childNode removeAllActions];
            [childNode removeFromParent];
        }
        
        if(childNode.physicsBody.categoryBitMask == pillerCategory)
        {
            [childNode removeAllActions];
            [childNode removeFromParent];
        }
        
    }
    
    [_flappyBird removeAllActions];
    _flappyBird.physicsBody.velocity = CGVectorMake(0, 0);
    self.physicsWorld.gravity = CGVectorMake(0, 0.0);
    _flappyBird.hidden = YES;
    
    _gameOver = YES;
    _gameStarted = NO;
    
    _dt = 0;
    _lastUpdateTimeInterval = 0;
    _lastSpawnTimeInterval = 0;
    
    [_startGameLayer removeFromParent];
    [_instructionGameLayer removeFromParent];
    [self addChild:_gameOverLayer];
    
    _scoreHolder.position= CGPointMake(500, 400);
    _scoreLabelNode.position = CGPointMake(495, 380);
}

- (void) startGame
{
    _score = 0;
    _gameStarted = YES;
    
    [_startGameLayer removeFromParent];
    [_instructionGameLayer removeFromParent];
    [_gameOverLayer removeFromParent];
    [_finishedGameLayer removeFromParent];
    [_scoreLabelNode removeFromParent];
    
    _scoreHolder = [SKSpriteNode spriteNodeWithImageNamed:@"ScoreHolder"];
    _scoreHolder.position = CGPointMake(50, 700);
    [self addChild:_scoreHolder];
    
    // Initialize label and create a label which holds the score
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    _scoreLabelNode.position = CGPointMake(50, 675);
    _scoreLabelNode.fontColor = [UIColor brownColor];
    //_scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), 3 * self.frame.size.height / 4 );
    _scoreLabelNode.zPosition = 100;
    _scoreLabelNode.fontSize = 60;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    [self addChild:_scoreLabelNode];
    
    SKSpriteNode * logoBottom = [SKSpriteNode spriteNodeWithImageNamed:@"LogoBottom"];
    logoBottom.position = CGPointMake(950, 700);
    //logoBottom.zPosition = 100;
    [self addChild:logoBottom];
    
    self.flappyBird.position = CGPointMake(self.backgroundImageNode.size.width * 0.3f, self.frame.size.height * 0.6f);
    
    //To have Gravity effect on Bird so that bird flys down when not tapped
    self.physicsWorld.gravity = CGVectorMake(0, -6.0);
    
    if (!_intialGame) {
        _intialGame = YES;
        [self updateTimeLabel];
    }
}


- (void) addACloud
{
    SKSpriteNode* upwardPiller = [self createCloud];
    float upwardPillerY = ((arc4random() % 400));
    upwardPillerY += bottomScrollerHeight;
    upwardPiller.position = CGPointMake(self.frame.size.width, upwardPillerY);
    SKAction * upwardPillerActionMove = [SKAction moveTo:CGPointMake(-upwardPiller.size.width/2, upwardPillerY) duration:(TIME * 4)];
    SKAction * upwardPillerActionMoveDone = [SKAction removeFromParent];
    [upwardPiller runAction:[SKAction sequence:@[upwardPillerActionMove, upwardPillerActionMoveDone]]];
}


- (void) addAdarkCloud
{
    SKSpriteNode* upwardPiller = [self createDarkClouds];
    float upwardPillerY = ((arc4random() % 550));
    upwardPillerY += bottomScrollerHeight;
    upwardPiller.position = CGPointMake(self.frame.size.width, upwardPillerY);
    SKAction * upwardPillerActionMove = [SKAction moveTo:CGPointMake(-upwardPiller.size.width/2, upwardPillerY) duration:(TIME * 2)];
    SKAction * upwardPillerActionMoveDone = [SKAction removeFromParent];
    [upwardPiller runAction:[SKAction sequence:@[upwardPillerActionMove, upwardPillerActionMoveDone]]];
}

- (void) addAPlane
{
    SKSpriteNode* upwardPiller = [self createAirPlane];
    float upwardPillerY = ((arc4random() % 500));
    upwardPillerY += bottomScrollerHeight;
    upwardPiller.position = CGPointMake(self.frame.size.width, upwardPillerY);
    SKAction * upwardPillerActionMove = [SKAction moveTo:CGPointMake(-upwardPiller.size.width/2, upwardPillerY) duration:(TIME)];
    SKAction * upwardPillerActionMoveDone = [SKAction removeFromParent];
    [upwardPiller runAction:[SKAction sequence:@[upwardPillerActionMove, upwardPillerActionMoveDone]]];
    
    SKSpriteNode* darkCloudsPiller = [self createDarkClouds];
    float darkCloudsPillerY = 0;
    if (upwardPillerY >= 450) {
        darkCloudsPillerY = upwardPillerY - upwardPiller.size.height - GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
    }
    else{
        darkCloudsPillerY = upwardPillerY + upwardPiller.size.height + GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
    }
    darkCloudsPiller.position = CGPointMake(upwardPiller.position.x, darkCloudsPillerY);
    
    SKAction * darkCloudsPillerActionMove = [SKAction moveTo:CGPointMake(-darkCloudsPiller.size.width/2, darkCloudsPillerY) duration:(TIME * 2)];
    SKAction * darkCloudsPillerActionMoveDone = [SKAction removeFromParent];
    [darkCloudsPiller runAction:[SKAction sequence:@[darkCloudsPillerActionMove, darkCloudsPillerActionMoveDone]]];
    
    //    //Create Cement
    //    SKSpriteNode* cementPiller = [self createCement];
    //    float cementPillerY = 0;
    //    if (upwardPillerY >= 450) {
    //        cementPillerY = upwardPillerY - upwardPiller.size.height - GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
    //    }
    //    else{
    //        cementPillerY = upwardPillerY + upwardPiller.size.height + GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
    //    }
    //    cementPiller.position = CGPointMake(upwardPiller.position.x, cementPillerY);
    //
    //    SKAction * cementPillerActionMove = [SKAction moveTo:CGPointMake(-cementPiller.size.width/2, cementPillerY) duration:(TIME * 2)];
    //    SKAction * cementPillerActionMoveDone = [SKAction removeFromParent];
    //    [cementPiller runAction:[SKAction sequence:@[cementPillerActionMove, cementPillerActionMoveDone]]];
    

//    SKSpriteNode* cementPiller = [self createAirPlane];
//    float cementPillerY = 0;
//    if (upwardPillerY >= 450) {
//        cementPillerY = upwardPillerY - upwardPiller.size.height - GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
//    }
//    else{
//        cementPillerY = upwardPillerY + upwardPiller.size.height + GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
//    }
//    cementPiller.position = CGPointMake(upwardPiller.position.x, cementPillerY);
//    
//    SKAction * cementPillerActionMove = [SKAction moveTo:CGPointMake(-cementPiller.size.width/2, cementPillerY) duration:(TIME * 2)];
//    SKAction * cementPillerActionMoveDone = [SKAction removeFromParent];
//    [cementPiller runAction:[SKAction sequence:@[cementPillerActionMove, cementPillerActionMoveDone]]];
}


- (SKSpriteNode*) createCement
{
    NSString* pillerImageName = @"CementScore";
    SKSpriteNode * cement = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    cement.name = @"Cement";
    cement.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cement.size];
    cement.physicsBody.categoryBitMask = cementCategory;
    cement.physicsBody.contactTestBitMask = flappyBirdCategory;
    cement.physicsBody.collisionBitMask = 0;
    cement.physicsBody.affectedByGravity = NO;
    [self addChild:cement];
    return cement;
}


- (SKSpriteNode*) createCloud
{
    
    NSArray *tips;
    tips = [NSArray arrayWithObjects:
            @"Cloud01a",
            @"Cloud01b",
            @"Cloud01c",
            nil];
    
    uint32_t rnd = arc4random_uniform([tips count]);
    NSString *pillerImageName = [tips objectAtIndex:rnd];
    
    
    //NSString* pillerImageName = @"Cloud01a";
    SKSpriteNode * cloud = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    cloud.name = @"Cloud";
    cloud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cloud.size];
    cloud.physicsBody.categoryBitMask = cloudCategory;
    cloud.physicsBody.contactTestBitMask = cloudCategory;
    cloud.physicsBody.collisionBitMask = cloudCategory;
    cloud.physicsBody.affectedByGravity = NO;
    [self addChild:cloud];
    return cloud;
}


- (SKSpriteNode*) createDarkClouds
{
    NSString *pillerImageName = @"DarkCloud01e";
    SKSpriteNode * airplane = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    
    airplane.name = @"DarkClouds";
    /*
     * Create a physics and specify its geometrical shape so that collision algorithm
     * can work more prominently
     */
    airplane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:airplane.size];
    //Category to which this object belongs to
    airplane.physicsBody.categoryBitMask = pillerCategory;
    //To notify intersection with objects
    airplane.physicsBody.contactTestBitMask = flappyBirdCategory;
    //To detect collision with category of objects. Default all categories
    airplane.physicsBody.collisionBitMask = 0;
    /*
     * Has to be explicitely mentioned. If not mentioned, pillar starts moving down becuase of gravity.
     */
    airplane.physicsBody.affectedByGravity = NO;
    [self addChild:airplane];
    return airplane;
}


- (SKSpriteNode*) createAirPlane
{
    NSString* pillerImageName = AIRPLANE;
    
    SKSpriteNode * airplane = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    airplane.name = @"Airplane";
    /*
     * Create a physics and specify its geometrical shape so that collision algorithm
     * can work more prominently
     */
    airplane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:airplane.size];
    //Category to which this object belongs to
    airplane.physicsBody.categoryBitMask = pillerCategory;
    //To notify intersection with objects
    airplane.physicsBody.contactTestBitMask = flappyBirdCategory;
    //To detect collision with category of objects. Default all categories
    airplane.physicsBody.collisionBitMask = 0;
    /*
     * Has to be explicitely mentioned. If not mentioned, pillar starts moving down becuase of gravity.
     */
    airplane.physicsBody.affectedByGravity = NO;
    [self addChild:airplane];
    return airplane;
}

#pragma mark - Pillar
- (void)addAPiller
{
    //Create Upward directed pillar
    SKSpriteNode* upwardPiller = [self createPillerWithUpwardDirection:YES];
    
    int minY = MINIMUM_PILLER_HEIGHT;
    int maxY = self.frame.size.height - bottomScrollerHeight - GAP_BETWEEN_TOP_AND_BOTTOM_PILLER - MINIMUM_PILLER_HEIGHT;
    int rangeY = maxY - minY;
    
    float upwardPillerY = ((arc4random() % rangeY) + minY) - upwardPiller.size.height;
    upwardPillerY += bottomScrollerHeight;
    upwardPillerY += upwardPiller.size.height * 0.5f;
    
    /*Set position of pillar start position outside the screen so that we can be 
     sure that image is created before it comes inside screen visibility area
     */
    upwardPiller.position = CGPointMake(self.frame.size.width + upwardPiller.size.width/2, upwardPillerY);
    
    //Create Downward directed pillar
    SKSpriteNode* downwardPiller = [self createPillerWithUpwardDirection:NO];
    float downloadPillerY = upwardPillerY + upwardPiller.size.height + GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
    downwardPiller.position = CGPointMake(upwardPiller.position.x, downloadPillerY);
    
    /*
     * Create Upward Piller actions.
     * First action has to be the movement of pillar. Right to left.
     * Once first action is complete, remove that node from Scene
     */
    SKAction * upwardPillerActionMove = [SKAction moveTo:CGPointMake(-upwardPiller.size.width/2, upwardPillerY) duration:(TIME * 2)];
    SKAction * upwardPillerActionMoveDone = [SKAction removeFromParent];
    [upwardPiller runAction:[SKAction sequence:@[upwardPillerActionMove, upwardPillerActionMoveDone]]];
    
    // Create Downward Piller actions
    SKAction * downwardPillerActionMove = [SKAction moveTo:CGPointMake(-downwardPiller.size.width/2, downloadPillerY) duration:(TIME * 2)];
    SKAction * downwardPillerActionMoveDone = [SKAction removeFromParent];
    [downwardPiller runAction:[SKAction sequence:@[downwardPillerActionMove, downwardPillerActionMoveDone]]];
}

- (SKSpriteNode*) createPillerWithUpwardDirection:(BOOL) isUpwards
{
    NSString* pillerImageName = nil;
    if (isUpwards)
    {
        pillerImageName = UPWARD_PILLER;
    }
    else
    {
        pillerImageName = Downward_PILLER;
    }
    
    SKSpriteNode * piller = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    piller.name = PILLARS;
    
    /*
     * Create a physics and specify its geometrical shape so that collision algorithm
     * can work more prominently
     */
    piller.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:piller.size];
    
    //Category to which this object belongs to
    piller.physicsBody.categoryBitMask = pillerCategory;
    
    //To notify intersection with objects
    piller.physicsBody.contactTestBitMask = flappyBirdCategory;
    
    //To detect collision with category of objects. Default all categories
    piller.physicsBody.collisionBitMask = 0;
    
    /*
     * Has to be explicitely mentioned. If not mentioned, pillar starts moving down becuase of gravity.
     */
    piller.physicsBody.affectedByGravity = NO;
    
    [self addChild:piller];
    
    return piller;
}

#pragma mark - Bottom Background
- (void)moveBottomScroller
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x + bg.size.width * 0.5f <= 0)
         {
             bg.position = CGPointMake(bg.size.width*2 - (bg.size.width * 0.5f) - 2,
                                       bg.position.y);
         }
     }];
}

#pragma mark - Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > TIME)
    {
        self.lastSpawnTimeInterval = 0;
        //[self addAPiller];
        [self addACloud];
        [self addAPlane];
        //[self addAdarkCloud];
        //[self addCement];
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    if(_gameOver == NO)
    {
        if (self.lastUpdateTimeInterval)
        {
            _dt = currentTime - _lastUpdateTimeInterval;
        }
        else
        {
            _dt = 0;
        }
        
        CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        if (timeSinceLast > TIME)
        {
            timeSinceLast = 1.0 / (TIME * 60.0);
            self.lastUpdateTimeInterval = currentTime;
        }
        
        [self moveBottomScroller];
        //[self updateScore];
        
        if(_gameStarted)
        {
            [self updateWithTimeSinceLastUpdate:timeSinceLast];
        }
    }
}

#pragma mark - Collision Detection
- (void)pillar:(SKSpriteNode *)pillar didCollideWithBird:(SKSpriteNode *)bird
{
    // Reset score
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    //[_scoreLabelNode removeFromParent];
    //[_scoreHolder removeFromParent];

    [self showGameOverLayer];
}

- (void)flappyBird:(SKSpriteNode *)bird didCollideWithBottomScoller:(SKSpriteNode *)bottomBackground
{
    // Reset score
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    //[_scoreLabelNode removeFromParent];
    //[_scoreHolder removeFromParent];
    [self showGameOverLayer];
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
    
    NSLog(@"secondBody:%u",secondBody.categoryBitMask);
    
    if(secondBody.categoryBitMask == 8)
    {
        ++_score;
        _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
     
       [self runAction:[SKAction playSoundFileNamed:@"point.caf" waitForCompletion:NO]];
        
        [secondBody.node removeFromParent];
        
        if (_score >= 30) {
            NSLog(@"Congratulations");
            _flappyBird.physicsBody.velocity = CGVectorMake(1500, 0);
        }
    }
    else{
        // Bird has collided with world
        _moving.speed = 0;
        _flappyBird.physicsBody.collisionBitMask = worldCategory;
        
        [self runAction:[SKAction playSoundFileNamed:@"hit.caf" waitForCompletion:NO]];
        
        [_flappyBird runAction:[SKAction rotateByAngle:M_PI * _flappyBird.position.y * 0.01 duration:_flappyBird.position.y * 0.003] completion:^{
            _flappyBird.speed = 0;
        }];
        
        // Flash background if contact is detected
        [self removeActionForKey:@"flash"];
        
        [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
            self.backgroundColor = [SKColor redColor];
        }], [SKAction waitForDuration:0.05], [SKAction runBlock:^{
            self.backgroundColor = _skyColor;
        }], [SKAction waitForDuration:0.05]]] count:4], [SKAction runBlock:^{
            SKPhysicsBody *firstBody, *secondBody;
            [self flappyBird:(SKSpriteNode *)firstBody.node didCollideWithBottomScoller:(SKSpriteNode *)secondBody.node];
        }]]] withKey:@"flash"];

    }
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_gameStarted && !_gameOver)
    {
        
        [self runAction:[SKAction playSoundFileNamed:@"wing.caf" waitForCompletion:NO]];
        
        _flappyBird.physicsBody.velocity = CGVectorMake(0, 350);
    }
}

#pragma mark - Delegates
#pragma mark -StartGameLayer
- (void)startGameLayer:(StartGameLayer *)sender tapRecognizedOnButton:(StartGameLayerButtonType)startGameLayerButton
{
    _gameOver = NO;
    _gameStarted = NO;
    _moving.speed = 1;
    _flappyBird.speed = 1;
    [self showInstructionGameLayer];
}

- (void)instructionGameLayer:(InstructionGameLayer *)sender tapRecognizedOnButton:(InstructionGameLayerButtonType)instructionGameLayerButton
{
    _gameOver = NO;
    _gameStarted = YES;
    _moving.speed = 1;
    _flappyBird.speed = 1;
    [self startGame];
}


- (void)finishedGameLayer:(FinishedGameLayer *)sender tapRecognizedOnButton:(FinishedGameLayerButtonType)finishedGameLayerButton
{
    _gameOver = NO;
    _gameStarted = NO;
    _moving.speed = 1;
    _flappyBird.speed = 1;
    [_scoreHolder removeFromParent];
    [_scoreLabelNode removeFromParent];
    [self showStartGameLayer];
}


- (void)gameOverLayer:(GameOverLayer *)sender tapRecognizedOnButton:(GameOverLayerButtonType)gameOverLayerButtonType
{
    _gameOver = NO;
    _gameStarted = NO;
    _moving.speed = 1;
    _flappyBird.speed = 1;
    [_scoreHolder removeFromParent];
    [_scoreLabelNode removeFromParent];
    [self showStartGameLayer];
}

#pragma mark - Update Score
//- (void) updateScore
//{
//    [self enumerateChildNodesWithName:PILLARS usingBlock:^(SKNode *node, BOOL *stop)
//    {
//        if(_flappyBird.position.x > node.position.x)
//        {
//            node.name = @"";    //Reset the name to empty name so as to not track the pillar once it has passed beyond the bird's position
//            ++_score;
//            /* Since there are 2 pillars(Top and bottom), we will this function will be fired 2 times.
//             * So we take a reminder by dividing the current score with 2
//             */
//            if (_score % 2 == 0)
//            {
//                _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score/2];
//                NSLog(@"Score: %d", _score/2);
//            }
//            *stop = YES;    //To stop enumerating
//            
//            if (_score/2 >= 30) {
//                NSLog(@"Congratulations");
//                _flappyBird.physicsBody.velocity = CGVectorMake(1000, 0);
//            }
//        }
//    }];
//}

-(void)updateTimeLabel {
    
    NSLog(@"score: %d", _score);
    
    if (_score >= 30) {
        NSLog(@"Congratulations");
        _flappyBird.physicsBody.velocity = CGVectorMake(1300, 400);
        _intialGame = NO;
        [self showFinishedGameLayer];
    }
    else if (_gameOver == YES){
        _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
        _intialGame = NO;
    }
    else{
        _score = _score + 1;
        _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
        [self performSelector:@selector(updateTimeLabel) withObject:nil afterDelay:1.0];
    }

}


@end
