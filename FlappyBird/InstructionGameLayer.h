//
//  InstructionGameLayer.h
//  FlappyBird
//
//  Created by Srikanth KV on 22/02/14.
//  Copyright (c) 2014 mytechspace. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameHelperLayer.h"

typedef NS_ENUM(NSUInteger, InstructionGameLayerButtonType)
{
    InstructionGameLayerPlayButton = 0
};


@protocol InstructionGameLayerDelegate;
@interface InstructionGameLayer : GameHelperLayer
@property (nonatomic, assign) id<InstructionGameLayerDelegate> delegate;
@end


//**********************************************************************
@protocol InstructionGameLayerDelegate <NSObject>
@optional

- (void) instructionGameLayer:(InstructionGameLayer*)sender tapRecognizedOnButton:(InstructionGameLayerButtonType) instructionGameLayerButton;
@end