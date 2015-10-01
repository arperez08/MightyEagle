//
//  InstructionGameLayer.m
//  FlappyBird
//
//  Created by Srikanth KV on 22/02/14.
//  Copyright (c) 2014 mytechspace. All rights reserved.
//

#import "FinishedGameLayer.h"

@interface FinishedGameLayer()
@property (nonatomic, retain) SKSpriteNode* playButton;
@end


@implementation FinishedGameLayer

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        SKSpriteNode * logoBottom = [SKSpriteNode spriteNodeWithImageNamed:@"LogoBottom"];
        logoBottom.position = CGPointMake(950, 700);
        [self addChild:logoBottom];
        
        SKSpriteNode * scoreHolder = [SKSpriteNode spriteNodeWithImageNamed:@"ScorePage"];
        scoreHolder.position = CGPointMake(600, 500);
        [self addChild:scoreHolder];
        
        SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithImageNamed:@"PlayButtonFinished"];
        playButton.position = CGPointMake(size.width * 0.5f, size.height * 0.30f);
        [self addChild:playButton];
        
        [self setPlayButton:playButton];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([_playButton containsPoint:location])
    {
        if([self.delegate respondsToSelector:@selector(finishedGameLayer:tapRecognizedOnButton:)])
        {
            [self.delegate finishedGameLayer:self tapRecognizedOnButton:FinishedGameLayerPlayButton];
        }
    }
}
@end
