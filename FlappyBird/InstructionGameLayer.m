//
//  InstructionGameLayer.m
//  FlappyBird
//
//  Created by Srikanth KV on 22/02/14.
//  Copyright (c) 2014 mytechspace. All rights reserved.
//

#import "InstructionGameLayer.h"

@interface InstructionGameLayer()
@property (nonatomic, retain) SKSpriteNode* playButton;
@end


@implementation InstructionGameLayer

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        
        SKSpriteNode * logoBottom = [SKSpriteNode spriteNodeWithImageNamed:@"LogoBottom"];
        logoBottom.position = CGPointMake(950, 700);
        [self addChild:logoBottom];
        
        
        SKSpriteNode* getReadyGameText = [SKSpriteNode spriteNodeWithImageNamed:@"GetReadyText"];
        getReadyGameText.position = CGPointMake(515,600);
        [self addChild:getReadyGameText];
        
        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"TapToStart"];
        startGameText.position = CGPointMake(515,400);
        [self addChild:startGameText];
        
//        SKSpriteNode* CementGameText = [SKSpriteNode spriteNodeWithImageNamed:@"Earnpoint"];
//        CementGameText.position = CGPointMake(800,575);
//        [self addChild:CementGameText];
//        
//        SKSpriteNode* OverGameText = [SKSpriteNode spriteNodeWithImageNamed:@"Over"];
//        OverGameText.position = CGPointMake(250,575);
//        [self addChild:OverGameText];
        
        SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithImageNamed:@"PlayButton"];
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
        if([self.delegate respondsToSelector:@selector(instructionGameLayer:tapRecognizedOnButton:)])
        {
            [self.delegate instructionGameLayer:self tapRecognizedOnButton:InstructionGameLayerPlayButton];
        }
    }
}
@end
