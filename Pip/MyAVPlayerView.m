//
//  MyAVPlayerView.m
//  Pip
//
//  Created by mahboud on 10/13/14.
//  Copyright (c) 2014 BitsOnTheGo. All rights reserved.
//

#import "MyAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

/* ---------------------------------------------------------
 **  To play the visual component of an asset, you need a view
 **  containing an AVPlayerLayer layer to which the output of an
 **  AVPlayer object can be directed. You can create a simple
 **  subclass of UIView to accommodate this. Use the view’s Core
 **  Animation layer (see the 'layer' property) for rendering.
 **  This class, AVPlayerDemoPlaybackView, is a subclass of UIView
 **  that is used for this purpose.
 ** ------------------------------------------------------- */

@implementation MyAVPlayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}
//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//	self = [super initWithCoder:coder];
//	if (self) {
//		self.backgroundColor = [UIColor clearColor];
//	}
//	return self;
//}
-(void)awakeFromNib
{
	self.backgroundColor = [UIColor clearColor];

}
- (AVPlayer*)player
{
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
