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
@interface MyLabelWithPadding : UILabel

@end

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MyAVPlayerView *mainView;
@property (weak, nonatomic) IBOutlet MyAVPlayerView *pipViewA;
@property (weak, nonatomic) IBOutlet MyAVPlayerView *pipViewB;
//@property (strong , nonatomic) AVPlayer *player1;
//@property (strong , nonatomic) AVPlayer *player2;
@property id notificationToken;

@end
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@implementation ViewController {
	UITapGestureRecognizer *singleTap;
	UITapGestureRecognizer *doubleTap;
	NSArray *captions;
	NSUInteger captionIndex;
	MyLabelWithPadding *captionLabel;
	id timeObserver;
}

- (void)removePipGestureRecognizers:(MyAVPlayerView *)aPipView {
	[aPipView removeGestureRecognizer:aPipView.swapTap];
	[aPipView removeGestureRecognizer:aPipView.pan];
	[aPipView removeGestureRecognizer:aPipView.pinch];
}

- (void)addPipGestureRecognizers:(MyAVPlayerView *)aPipView {
	aPipView.swapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwapTap:)];
	aPipView.swapTap.numberOfTapsRequired = 2;
	[singleTap requireGestureRecognizerToFail:aPipView.swapTap];
	[aPipView addGestureRecognizer:aPipView.swapTap];
	
	aPipView.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
	aPipView.pan.minimumNumberOfTouches = 1;
	[aPipView addGestureRecognizer:aPipView.pan];
	aPipView.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
	[aPipView addGestureRecognizer:aPipView.pinch];
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}
- (void)makeAndPreparePlayerForView:(MyAVPlayerView *)aPlayerView WithURL:(NSURL *)url {
	AVPlayer *player = [AVPlayer playerWithURL:url];
	[player addObserver:self
			   forKeyPath:@"status"
				  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
				  context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
//	[_player2 addObserver:self
//			   forKeyPath:@"status"
//				  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//				  context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
	
	_notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		
		[[player currentItem] seekToTime:kCMTimeZero];
		[player play];
	}];
//	_notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:_player2.currentItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//		
//		[[_player2 currentItem] seekToTime:kCMTimeZero];
//		[_player2 play];
//	}];
	aPlayerView.player = player;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	NSLog(@"constraintds for %@ %@", _mainView, [_mainView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal]);
	
//	NSString *movie1  = [[NSBundle mainBundle] pathForResource:@"MNF, Biggest Stage" ofType:@"m4v"];
//	NSString *movie2 = [[NSBundle mainBundle] pathForResource:@"MNF, Target" ofType:@"m4v"];
	NSString *movie1  = [[NSBundle mainBundle] pathForResource:@"IMG_1214" ofType:@"MOV"];
	NSString *movie3 = [[NSBundle mainBundle] pathForResource:@"IMG_0974" ofType:@"MOV"];
//	NSString *movie1  = [[NSBundle mainBundle] pathForResource:@"P8240082" ofType:@"MOV"];
	NSString *movie2 = [[NSBundle mainBundle] pathForResource:@"P8240082" ofType:@"MOV"];
	self.view.backgroundColor = [UIColor blackColor];

	[self makeAndPreparePlayerForView:_mainView WithURL:[NSURL fileURLWithPath:movie1]];
	[self makeAndPreparePlayerForView:_pipViewA WithURL:[NSURL fileURLWithPath:movie2]];
	[self makeAndPreparePlayerForView:_pipViewB WithURL:[NSURL fileURLWithPath:movie3]];

	singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTap.numberOfTapsRequired = 2;
	[singleTap requireGestureRecognizerToFail:doubleTap];
	
	[self.view addGestureRecognizer:singleTap];
	[self.view addGestureRecognizer:doubleTap];
	[self removePipGestureRecognizers:_pipViewA];
	[self addPipGestureRecognizers:_pipViewA];
	[self removePipGestureRecognizers:_pipViewB];
	[self addPipGestureRecognizers:_pipViewB];

	CGRect frame;
	CGFloat height, width;
	
	height = MIN(self.view.frame.size.width, self.view.frame.size.height);
	width = MAX(self.view.frame.size.width, self.view.frame.size.height);;

	frame.size.width = 350;
	frame.size.height = frame.size.width * 9.0/16.0;
	frame.origin.x = width - frame.size.width - 10;
	frame.origin.y = height - frame.size.height - 10;
	_mainView.pipRect = frame;
	_pipViewA.pipRect = frame;
	_pipViewA.frame = frame;
	
	frame.origin.x = 10;
	frame.origin.y = height - frame.size.height - 10;
	_pipViewB.pipRect = frame;
	_pipViewB.frame = frame;
	
	NSArray *timeOffsets = @[@(5.0),
							 @(10.0),
							 @(12.5),
							 @(20.0),
							 @(30.0),
							 @(32.75),
							 @(40.5),
							 @(50),
							 @(70),
							 @(75.0),
							 @(80.0),
							 @(92.5),
							 @(100.0),
							 @(110.0),
							 @(122.75),
							 @(130.5),
							 @(135.0),
							 @(170),
							 ];
	captions = @[
				 @"This is a title",
				 @"These titles will appear once in a while",
				 @"at different timecodes (as specified in an array)",
				 @"and they will disappear",
				 @"At different timecodes",
				 @"they aren't frame perfect",
				 @"they are based on time",
				 @"and if a frame is dropped, they still show up",
				 @"despite the drop",
				 @"This is a title",
				 @"These titles will appear once in a while",
				 @"at different timecodes",
				 @"and they will disappear",
				 @"At different timecodes",
				 @"they aren't frame perfect",
				 @"they are based on time",
				 @"and if a frame is dropped, they still show up",
				 @"despite the drop",];
	timeObserver = [_mainView.player addBoundaryTimeObserverForTimes:timeOffsets queue:dispatch_get_main_queue() usingBlock:^{
		if (captionLabel.hidden) {
			captionLabel.text = captions[captionIndex];
			[captionLabel sizeToFit];
			captionIndex++;
			captionLabel.alpha = 0;
			captionLabel.hidden = NO;
			[UIView animateWithDuration:1.5 animations:^{
				captionLabel.alpha = 1.0;
			}];
		}
		else {
			[UIView animateWithDuration:1.5 animations:^{
				captionLabel.alpha = 0;
			} completion:^(BOOL finished) {
				captionLabel.hidden = YES;
			}];
		}
	}];
	captionLabel = [MyLabelWithPadding.alloc initWithFrame:CGRectMake(0, 0, 200, 30)];
	captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
	captionLabel.textAlignment = NSTextAlignmentCenter;
	captionLabel.textColor = [UIColor whiteColor];
	captionLabel.clipsToBounds = YES;
	[self.view addSubview:captionLabel];
	captionLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.75];
	captionLabel.layer.cornerRadius = 4.0;
	captionLabel.layer.borderColor = [UIColor whiteColor].CGColor;
	captionLabel.layer.borderWidth = 6.0;
	captionLabel.text = @"-------------";
	captionLabel.numberOfLines = 0;
	captionLabel.preferredMaxLayoutWidth = 800;
	captionLabel.hidden = YES;
	captionLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:48];
//	[captionLabel addConstraint:[NSLayoutConstraint constraintWithItem:captionLabel
//															  attribute:NSLayoutAttributeWidth
//															  relatedBy:NSLayoutRelationEqual
//																 toItem:nil
//															  attribute:NSLayoutAttributeNotAnAttribute
//															 multiplier:1.0
//															   constant:50]];
//	[captionLabel addConstraint:[NSLayoutConstraint constraintWithItem:captionLabel
//															  attribute:NSLayoutAttributeHeight
//															  relatedBy:NSLayoutRelationEqual
//																 toItem:nil
//															  attribute:NSLayoutAttributeNotAnAttribute
//															 multiplier:1.0
//															   constant:50]];

	
	[self removeConstraintsAndMakeMain];
	[self makeConstraints:_pipViewA];
	[self makePipBorder:_pipViewA];
	[self makeConstraints:_pipViewB];
	[self makePipBorder:_pipViewB];

}
- (void)makePipBorder:(UIView *)aPipView
{
	aPipView.layer.borderColor = [UIColor blackColor].CGColor;
	aPipView.layer.borderWidth = 2.0;
	aPipView.layer.cornerRadius = 3.0;
	aPipView.clipsToBounds = YES;
}
- (void)removePipBorder:(UIView *)aPipView
{
	aPipView.layer.borderWidth = 0;
	aPipView.layer.cornerRadius = 0;
	aPipView.clipsToBounds = NO;
}
- (void)removeConstraintsAndMakeMain
{	NSLog(@"1-constraintds for %@ %@", _mainView, [_mainView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal]);
	[_mainView removeConstraints:_mainView.constraints];
	[self.view removeConstraints:self.view.constraints];
	[_mainView makeStandardConstraints];
	NSLog(@"2-constraintds for %@ %@", _mainView, [_mainView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal]);
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_mainView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
	
	CGFloat height, width;
	height = MIN(self.view.frame.size.width, self.view.frame.size.height);
	width = MAX(self.view.frame.size.width, self.view.frame.size.height);;
	[_mainView addConstraint:[NSLayoutConstraint constraintWithItem:_mainView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
	[_mainView addConstraint:[NSLayoutConstraint constraintWithItem:_mainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:captionLabel
														  attribute:NSLayoutAttributeBottom
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeBottom
														 multiplier:1.0
														   constant:-30]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:captionLabel
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.0
														   constant:0]];
	
}
- (void)makeConstraints:(MyAVPlayerView *)aPipView
{
	[aPipView removeConstraints:aPipView.constraints];
	[aPipView makeStandardConstraints];
//	NSDictionary *views = @{@"main":_mainView};
//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[main]-|" options:0 metrics:nil views:views]];
//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[main]-|" options:0 metrics:nil views:views]];
	
	NSLayoutConstraint *pipWidthConstraint = [NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:aPipView.pipRect.size.width];
	[aPipView addConstraint:pipWidthConstraint];
	aPipView.pipWidthConstraint = pipWidthConstraint;
	[aPipView addConstraint:[NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:aPipView attribute:NSLayoutAttributeWidth multiplier:9.0/16.0 constant:0.0f]];
	
	aPipView.pipCenterXConstraint = [NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:aPipView.center.x];
	aPipView.pipCenterYConstraint = [NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:aPipView.center.y];
	[self.view addConstraints: @[aPipView.pipCenterYConstraint, aPipView.pipCenterXConstraint]];
	//	[self.view layoutIfNeeded];

	
	NSLog(@"3-constraintds for %@ %@", _mainView, [_mainView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal]);


}
- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
	[self toggleplay];
	
//	[yourPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:queue usingBlock:^(CMTime time)
//	{
//		yourLabel.text = @"your string".
//	}

}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
	[self rewind];
}
- (void)handleSwapTap:(UIGestureRecognizer *)gesture
{

	MyAVPlayerView *aPipView = (MyAVPlayerView *)gesture.view;
	[aPipView removeFromSuperview];
	[self.view insertSubview:aPipView aboveSubview:_mainView];
	//	aPipView.clipsToBounds = NO;
	CGRect origFrame = aPipView.frame;
//	[self removePipGestureRecognizers:aPipView];
	[self removePipBorder:aPipView];
	[UIView animateWithDuration:0.25 animations:^{
		CGRect frame;
		frame.origin = self.view.frame.origin;
		frame.size.height = MIN(self.view.frame.size.height, self.view.frame.size.width);
		frame.size.width = MAX(self.view.frame.size.height, self.view.frame.size.width);
		aPipView.frame = frame;
	} completion:^(BOOL finished) {
		UIView *bPipView = aPipView;
		MyAVPlayerView *aView = self.mainView;
		self.mainView = aPipView;
		if (aPipView == _pipViewA) {
			_pipViewA = aView;
		}
		else if (aPipView == _pipViewB) {
			_pipViewB = aView;

		}
		bPipView = aView;
		bPipView.frame = origFrame;
		bPipView.alpha = 0;
		[self.view insertSubview:_mainView atIndex:0];
		[self removeConstraintsAndMakeMain];
		[self makeConstraints:(MyAVPlayerView *) _pipViewA];
		[self makeConstraints:(MyAVPlayerView *) _pipViewB];
		[self makePipBorder:bPipView];
		[UIView animateWithDuration:0.25 animations:^{
			bPipView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[self addPipGestureRecognizers:(MyAVPlayerView *) bPipView];
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
	maxHeight = MIN(self.view.frame.size.width, self.view.frame.size.height);
	maxWidth = MAX(self.view.frame.size.width, self.view.frame.size.height);;
	MyAVPlayerView *aPipView = (MyAVPlayerView *)recognizer.view;
	NSLayoutConstraint *pipCenterYConstraint = aPipView.pipCenterYConstraint;
	pipCenterYConstraint.constant += translation.y ;
	if (pipCenterYConstraint.constant < aPipView.frame.size.height / 2)
		pipCenterYConstraint.constant = aPipView.frame.size.height / 2;
	if (pipCenterYConstraint.constant > (maxHeight - aPipView.frame.size.height / 2))
		pipCenterYConstraint.constant = (maxHeight - aPipView.frame.size.height / 2);
	NSLayoutConstraint *pipCenterXConstraint = aPipView.pipCenterXConstraint;
	pipCenterXConstraint.constant += translation.x ;
	if (pipCenterXConstraint.constant < aPipView.frame.size.width / 2)
		pipCenterXConstraint.constant = aPipView.frame.size.width / 2;
	if (pipCenterXConstraint.constant > maxWidth - aPipView.frame.size.width / 2)
		pipCenterXConstraint.constant = maxWidth - aPipView.frame.size.width / 2;
	[CATransaction commit];
}
- (IBAction)handlePinchFrom:(UIPinchGestureRecognizer *)gesture
{
	static CGFloat scaleStart;
	
	MyAVPlayerView *aPipView = (MyAVPlayerView *)gesture.view;
	NSLayoutConstraint *pipWidthConstraint = aPipView.pipWidthConstraint;
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// Take an snapshot of the initial scale
		scaleStart = pipWidthConstraint.constant;
		return;
	}
	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		// Apply the scale of the gesture to get the new scale
		CGFloat width = MAX(self.view.frame.size.height, self.view.frame.size.width);
		pipWidthConstraint.constant = scaleStart * gesture.scale;
		if (pipWidthConstraint.constant > 2 * width / 3)
			pipWidthConstraint.constant = 2 * width / 3;
		if (pipWidthConstraint.constant < 200)
			pipWidthConstraint.constant = 200;
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
					//					[player play];
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
	[[_mainView.player currentItem] seekToTime:kCMTimeZero];
	[[_pipViewA.player currentItem] seekToTime:kCMTimeZero];
	[[_pipViewB.player currentItem] seekToTime:kCMTimeZero];
}

- (void)play {
	[_mainView.player play];
	[_pipViewA.player play];
	[_pipViewB.player play];
}
						  
- (void)toggleplay {
  if ([self isPlaying]) {
	  [_mainView.player pause];
	  [_pipViewA.player pause];
	  [_pipViewB.player pause];
  }
  else {
	  [_mainView.player play];
	  [_pipViewA.player play];
	  [_pipViewB.player play];
  }
}
- (BOOL)isPlaying
{
	return /**mRestoreAfterScrubbingRate != 0.f ||**/ [_mainView.player rate] != 0.f;
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
	[_mainView removeObserver:self forKeyPath:@"status"];
	[_pipViewA removeObserver:self forKeyPath:@"status"];
	[_pipViewB removeObserver:self forKeyPath:@"status"];

}
@end

@implementation MyLabelWithPadding
-(CGSize)intrinsicContentSize
{
	CGSize contentSize = [super intrinsicContentSize];
	return CGSizeMake(contentSize.width + 80, contentSize.height + 50);
}
@end
