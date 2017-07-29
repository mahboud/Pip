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

@property(nonatomic, retain) AVPlayer *player;
@property(nonatomic, strong) UITapGestureRecognizer *swapTap;
@property(nonatomic, strong) UITapGestureRecognizer *twoFingerTap;
@property(nonatomic, strong) UIPanGestureRecognizer *pan;
@property(nonatomic, strong) UIPinchGestureRecognizer *pinch;
//@property (nonatomic) CGRect pipRect;
@property(nonatomic) CGFloat bigHeight;
@property(nonatomic) CGFloat smallHeight;
@property(nonatomic) CGFloat bigWidth;
@property(nonatomic) CGFloat smallWidth;

@property(strong, nonatomic) NSLayoutConstraint *pipCenterXConstraint;
@property(strong, nonatomic) NSLayoutConstraint *pipCenterYConstraint;
@property(strong, nonatomic) NSLayoutConstraint *pipWidthConstraint;
@property(strong, nonatomic) NSLayoutConstraint *pipHeightConstraint;
@property(nonatomic, getter=isMaster) BOOL master;
@property(nonatomic, getter=isCurrentMainView) BOOL isCurrentMainView;
@property(nonatomic) CGFloat aspect;
- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;
- (void)makeStandardConstraints;
- (void)makeBorder;
- (void)removeBorder;

@end
