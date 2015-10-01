//
//  FinishedGameLayer.h
//  FlappyBird
//
//  Created by Srikanth KV on 22/02/14.
//  Copyright (c) 2014 mytechspace. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameHelperLayer.h"

typedef NS_ENUM(NSUInteger, FinishedGameLayerButtonType)
{
    FinishedGameLayerPlayButton = 0
};


@protocol FinishedGameLayerDelegate;
@interface FinishedGameLayer : GameHelperLayer
@property (nonatomic, assign) id<FinishedGameLayerDelegate> delegate;
@end


//**********************************************************************
@protocol FinishedGameLayerDelegate <NSObject>
@optional

- (void) finishedGameLayer:(FinishedGameLayer*)sender tapRecognizedOnButton:(FinishedGameLayerButtonType) finishedGameLayerButton;
@end