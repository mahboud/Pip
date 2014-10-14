//
//  ViewController.m
//  Pip
//
//  Created by mahboud on 10/10/14.
//  Copyright (c) 2014 BitsOnTheGo. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MyAVPlayerView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MyAVPlayerView *mainView;
@property (weak, nonatomic) IBOutlet MyAVPlayerView *pipView;
@property (strong , nonatomic) AVPlayer *player1;
@property (strong , nonatomic) AVPlayer *player2;
@property id notificationToken;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pipBottomCorner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pipRightCorner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pipWidth;

@end
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
//	NSString *movie1  = [[NSBundle mainBundle] pathForResource:@"MNF, Biggest Stage" ofType:@"m4v"];
//	NSString *movie2 = [[NSBundle mainBundle] pathForResource:@"MNF, Target" ofType:@"m4v"];
	NSString *movie1  = [[NSBundle mainBundle] pathForResource:@"IMG_1214" ofType:@"MOV"];
	NSString *movie2 = [[NSBundle mainBundle] pathForResource:@"IMG_0974" ofType:@"mov"];
	self.view.backgroundColor = [UIColor blackColor];
	_mainView.backgroundColor = [UIColor clearColor];
	_pipView.backgroundColor = [UIColor clearColor];
	_player1 = [AVPlayer playerWithURL:[NSURL fileURLWithPath:movie1]];
	_player2 = [AVPlayer playerWithURL:[NSURL fileURLWithPath:movie2]];
	
//	_player = [AVPlayer.alloc init];
//	AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:movie2]];
//	[self.player replaceCurrentItemWithPlayerItem:item];

//	self.mainPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//	[self.view.layer addSublayer:self.mainPlayerLayer];
//	self.mainPlayerLayer.frame = self.view.layer.bounds;

	_mainView.player = _player1;
	_pipView.player = _player2;
	[_player1 addObserver:self
			   forKeyPath:@"status"
				  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
				  context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
	[_player2 addObserver:self
			   forKeyPath:@"status"
				  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
				  context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
	
	_notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:_player1.currentItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		
		[[_player1 currentItem] seekToTime:kCMTimeZero];
		[_player1 play];
	}];
	_notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:_player2.currentItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		
		[[_player2 currentItem] seekToTime:kCMTimeZero];
		[_player2 play];
	}];

	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:singleTap];
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	[doubleTap setNumberOfTapsRequired: 2];
	[singleTap requireGestureRecognizerToFail:doubleTap];
	[self.view addGestureRecognizer:doubleTap];
	
	UITapGestureRecognizer *swapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwapTap:)];
	[swapTap setNumberOfTapsRequired: 2];
	[singleTap requireGestureRecognizerToFail:swapTap];
	[_pipView addGestureRecognizer:swapTap];
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
	pan.minimumNumberOfTouches = 1;
	[self.pipView addGestureRecognizer:pan];
	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
	[self.pipView addGestureRecognizer:pinch];

	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.pipView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.pipView attribute:NSLayoutAttributeWidth multiplier:9.0/16.0 constant:0.0f];
	
	[self.pipView addConstraint:constraint];

}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
	[self toggleplay];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
	[self rewind];
}
- (void)handleSwapTap:(UIGestureRecognizer *)gesture
{
//	AVPlayer *player = _player1;
//	_player1 = _player2;
//	_player2 = player;
//	_mainView.player = _player1;
//	_pipView.player = _player2;
//	return;
	CGRect origFrame = _pipView.frame;
	[UIView animateWithDuration:3 animations:^{
		_pipView.frame = _mainView.frame;
	} completion:^(BOOL finished) {
		AVPlayer *player = _player1;
		_player1 = _player2;
		_player2 = player;
//		MyAVPlayerView *aView = self.mainView;
//		self.mainView = self.pipView;
//		self.pipView = aView;
		self.pipView.frame = origFrame;
		self.pipView.alpha = 0;

		[UIView animateWithDuration:3 animations:^{
			self.pipView.alpha = 1.0;
		} completion:^(BOOL finished) {
//			self.pipView.frame = origFrame;
//			[UIView animateWithDuration:3 animations:^{
////				[self.view exchangeSubviewAtIndex:1
////							   withSubviewAtIndex:0];
//
//			} completion:^(BOOL finished) {
//				
//			}];
		}];
	}];
}

- (IBAction)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
	CGPoint translation = [recognizer translationInView:self.view];
	
	recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
										 recognizer.view.center.y + translation.y);
	[recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
//	self.pipView.center = CGPointMake(self.pipView.center.x - translation.x * 1.0,
//												self.pipView.center.y - translation.y * 1.0);
	CGFloat maxHeight, maxWidth;
	maxWidth = self.view.frame.size.height;
	maxHeight = self.view.frame.size.width;
	_pipBottomCorner.constant -=translation.y ;
	if (_pipBottomCorner.constant < 0)
		_pipBottomCorner.constant = 0;
	if (_pipBottomCorner.constant > (maxHeight - _pipView.frame.size.height))
		_pipBottomCorner.constant = (maxHeight - _pipView.frame.size.height);
	_pipRightCorner.constant -=translation.x ;
	if (_pipRightCorner.constant < 0)
		_pipRightCorner.constant = 0;
	if (_pipRightCorner.constant > maxWidth - _pipView.frame.size.width)
		_pipRightCorner.constant = maxWidth - _pipView.frame.size.width;
	[CATransaction commit];
}
- (IBAction)handlePinchFrom:(UIPinchGestureRecognizer *)gesture
{
	static CGFloat scaleStart;
	
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// Take an snapshot of the initial scale
		scaleStart = _pipWidth.constant;
		return;
	}
	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		// Apply the scale of the gesture to get the new scale
		_pipWidth.constant = scaleStart * gesture.scale;
		if (_pipWidth.constant > 2 * self.view.frame.size.height / 3)
			_pipWidth.constant = 2 * self.view.frame.size.height / 3;
		if (_pipWidth.constant < 200)
			_pipWidth.constant = 200;
		CGPoint translation = [gesture locationInView:nil];
		
//		gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
//											 gesture.view.center.y + translation.y);

		 NSLog(@"centert %@", NSStringFromCGPoint(translation));
	}
	
}
- (void)observeValueForKeyPath:(NSString*) path
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void*)context
{
	/* AVPlayerItem "status" property value observer. */
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
	{
		
		AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
		switch (status)
		{
				/* Indicates that the status of the player is not yet known because
				 it has not tried to load new media resources for playback */
			case AVPlayerStatusUnknown:
				
				break;
				
			case AVPlayerStatusReadyToPlay:
			{
				/* Once the AVPlayerItem becomes ready to play, i.e.
				 [playerItem status] == AVPlayerItemStatusReadyToPlay,
				 its duration can be fetched from the item. */
				AVPlayer *player = (AVPlayer *)object;
				
				[player prerollAtRate:2.0 completionHandler:^(BOOL finished) {
					[player play];
				}];
				
			}
				break;
				
			case AVPlayerStatusFailed:
			{
//				AVPlayerItem *playerItem = (AVPlayerItem *)object;
				//					[self assetFailedToPrepareForPlayback:playerItem.error];
			}
				break;
		}
	}
	else
	{
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
	
	//	NSError *err = [_player error];
}

- (void)rewind
{
	[[_player1 currentItem] seekToTime:kCMTimeZero];
	[[_player2 currentItem] seekToTime:kCMTimeZero];
}

- (void)play {
  [_player1 play];
  [_player2 play];
}
						  
- (void)toggleplay {
  if ([self isPlaying]) {
	  [_player1 pause];
	  [_player2 pause];
  }
  else {
	  [_player1 play];
	  [_player2 play];
  }
}
- (BOOL)isPlaying
{
	return /**mRestoreAfterScrubbingRate != 0.f ||**/ [_player1 rate] != 0.f;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	[_player1 play];
//	[_player2 play];
//	AVPlayerStatus status = [_player status];
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
-(void)dealloc
{
	[_player1 removeObserver:self forKeyPath:@"status"];
	[_player2 removeObserver:self forKeyPath:@"status"];

}
@end
