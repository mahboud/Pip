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
{
	CADisplayLink				*_updateTimer;
	id							timerNoti;
	UILabel						*timeCodeLabel;
}
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
//	self.translatesAutoresizingMaskIntoConstraints = NO;
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = YES;
	timeCodeLabel = [UILabel.alloc initWithFrame:CGRectZero];
	timeCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	timeCodeLabel.textAlignment = NSTextAlignmentCenter;
	timeCodeLabel.textColor = [UIColor whiteColor];
	timeCodeLabel.clipsToBounds = YES;
	[self addSubview:timeCodeLabel];
	timeCodeLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.75];
	timeCodeLabel.layer.cornerRadius = 4.0;
	timeCodeLabel.text = @"";
	timeCodeLabel.hidden = YES;
}

- (void)makeStandardConstraints
{
//	NSDictionary *views = @{@"timecodelabel":timeCodeLabel};
//	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[timecodelabel]-|" options:0 metrics:nil views:views]];
//	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[timecodelabel]-|" options:0 metrics:nil views:views]];

	[timeCodeLabel removeConstraints:timeCodeLabel.constraints];
	[self removeConstraints:timeCodeLabel.constraints];
//	[self addConstraint:[NSLayoutConstraint constraintWithItem:timeCodeLabel
//													 attribute:NSLayoutAttributeBottom
//													 relatedBy:NSLayoutRelationEqual
//														toItem:self
//													 attribute:NSLayoutAttributeBottom
//													multiplier:1.0
//													  constant:-20]];
//	[self addConstraint:[NSLayoutConstraint constraintWithItem:timeCodeLabel
//													 attribute:NSLayoutAttributeCenterX
//													 relatedBy:NSLayoutRelationEqual
//														toItem:self
//													 attribute:NSLayoutAttributeCenterX
//													multiplier:1.0
//													  constant:0]];
	[timeCodeLabel addConstraint:[NSLayoutConstraint constraintWithItem:timeCodeLabel
															  attribute:NSLayoutAttributeWidth
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:1.0
															   constant:110]];
	[timeCodeLabel addConstraint:[NSLayoutConstraint constraintWithItem:timeCodeLabel
															  attribute:NSLayoutAttributeHeight
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:1.0
															   constant:24]];

//	CGRect frame = CGRectMake(30, self.frame.size.height - 20, 120, 20);
//	timeCodeLabel.frame = frame;
//	[self layoutIfNeeded];

}
- (AVPlayer*)player
{
	return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
//	timerNoti = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayer object:player.currentItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
	[player addObserver:self forKeyPath:@"rate" options:0 context:nil];
	
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"rate"]) {
		if ([self.player rate]) {
			NSLog(@"playing");
			//			[self startTimer];
		}
		else {
			NSLog(@"stopped");
			//			[self stopTimer];
		}
	}
}
/* Specifies how the video is displayed within a player layer’s bounds.
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}
#pragma mark Timer

- (void)stopTimer
{
	[_updateTimer invalidate];
	_updateTimer = nil;
}

- (void)startTimer
{
	_updateTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTimecode)];
	[_updateTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)updateTimecode
{
	AVPlayerItem *item = self.player.currentItem;
	CMTime time = [item currentTime];
	float currentTime = CMTimeGetSeconds(time);
	NSUInteger totalSeconds = currentTime;
	currentTime -= totalSeconds;
	NSUInteger subseconds = currentTime * 1000;
	NSUInteger hours = floor(totalSeconds / 3600);
	NSUInteger minutes = floor(totalSeconds % 3600 / 60);
	NSUInteger seconds = floor(totalSeconds % 3600 % 60);
	
	NSString *timecodeString = [NSString stringWithFormat:@"%lu:%02lu:%02lu.%03lu", (unsigned long)hours, (unsigned long)minutes, (unsigned long)seconds, (unsigned long)subseconds];
	timeCodeLabel.text = timecodeString;
}

- (void)makeBorder
{
	self.layer.borderColor = [UIColor blackColor].CGColor;
	self.layer.borderWidth = 1.0;
	self.layer.cornerRadius = 3.0;
	self.clipsToBounds = YES;
}
- (void)removeBorder
{
	self.layer.borderWidth = 0;
	self.layer.cornerRadius = 0;
	self.clipsToBounds = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
