//
//  MyAVPlayerView.h
//  Pip
//
//  Created by mahboud on 10/13/14.
//  Copyright (c) 2014 BitsOnTheGo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface MyAVPlayerView : UIView

@property (nonatomic, retain) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;


@end
