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
@property (nonatomic, strong) UITapGestureRecognizer *swapTap;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic) CGRect pipRect;
@property (strong, nonatomic) NSLayoutConstraint *pipCenterXConstraint;
@property (strong, nonatomic) NSLayoutConstraint *pipCenterYConstraint;
@property (strong, nonatomic) NSLayoutConstraint *pipWidthConstraint;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;


@end
