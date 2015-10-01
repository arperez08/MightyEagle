//
//  StartGameLayer.m
//  FlappyBird
//
//  Created by Srikanth KV on 22/02/14.
//  Copyright (c) 2014 mytechspace. All rights reserved.
//

#import "StartGameLayer.h"

@interface StartGameLayer()
@property (nonatomic, retain) SKSpriteNode* playButton;
@end


@implementation StartGameLayer

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        
//        CGSize constraint = CGSizeMake(1024,768);
//        //CGSize size;
//        
//        SKVideoNode* _videoNode = [SKVideoNode videoNodeWithVideoFileNamed:@"EagleIPAD_title.mp4"];
//        _videoNode.position = CGPointMake(512,385);
//        _videoNode.size = constraint;
//        [self addChild:_videoNode];
//        [_videoNode play];
        
        
//        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"FlappyBirdText"];
//        startGameText.position = CGPointMake(size.width * 0.5f, size.height * 0.8f);
//        [self addChild:startGameText];
        
        SKSpriteNode * logoBottom = [SKSpriteNode spriteNodeWithImageNamed:@"LogoBottom"];
        logoBottom.position = CGPointMake(950, 700);
        [self addChild:logoBottom];
        
        
        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"StartPage"];
        startGameText.position = CGPointMake(512,512);
        [self addChild:startGameText];
        
        
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
        if([self.delegate respondsToSelector:@selector(startGameLayer:tapRecognizedOnButton:)])
        {
            [self.delegate startGameLayer:self tapRecognizedOnButton:StartGameLayerPlayButton];
        }
    }
}
@end
