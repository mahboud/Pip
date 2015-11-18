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
#import <MobileCoreServices/MobileCoreServices.h>
//#import <CoreMedia/CoreMedia.h>
typedef NS_ENUM(NSInteger, MZVideoFileLocation)
{
	kBundle,
	kDocuments,
	kTempFolder,
	kLibrary,
};

static NSString *scheme = @"http";
static NSString *username = @"";
static NSString *password = @"";
static NSString *server = @"underthehood.realyze.com";
static NSString *basePath = @"/tests/replay/";
static NSString *video1 = @"Close Up Clean h264.mov";
static NSString *video2 = @"Wide Clean h264.mov";

@interface MyLabelWithPadding : UILabel

@end

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *videoContent;
@property (strong, nonatomic) AVPlayer *masterPlayer;
@property (strong, nonatomic) MyAVPlayerView *currentMainView;
@property (strong, nonatomic) NSMutableArray *pipViews;
@property (strong, nonatomic) UIViewController *modal;
@property id notificationToken;

@end
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@implementation ViewController {
	UITapGestureRecognizer *singleTap;
	UITapGestureRecognizer *twoFingerTap;
	UITapGestureRecognizer *doubleTap;
	UIPanGestureRecognizer *scrubDrag;
	UIPanGestureRecognizer *panDrag;
	NSArray *captions;
	NSUInteger captionIndex;
	MyLabelWithPadding *captionLabel;
	id timeObserver;
	NSLayoutConstraint *currentCenterXConstraint;
	NSLayoutConstraint *currentCenterYConstraint;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	_videoContent.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor blackColor];
	singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTap.numberOfTapsRequired = 2;
	[singleTap requireGestureRecognizerToFail:doubleTap];
	scrubDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrubDrag:)];
	scrubDrag.minimumNumberOfTouches = 2;
	twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
	twoFingerTap.numberOfTouchesRequired = 2;
	panDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMainPanDrag:)];
	panDrag.minimumNumberOfTouches = 1;

	[_videoContent addGestureRecognizer:singleTap];
	[_videoContent addGestureRecognizer:doubleTap];
	[_videoContent addGestureRecognizer:scrubDrag];
	[_videoContent addGestureRecognizer:twoFingerTap];
	[_videoContent addGestureRecognizer:panDrag];

	captionLabel = [MyLabelWithPadding.alloc initWithFrame:CGRectMake(0, 0, 200, 30)];
	[self.view addSubview:captionLabel];
	//	captionLabel.hidden = NO;
	[self createAllAVPlayersWithArrayOfMovies:nil];
}
- (void) createAllAVPlayersWithArrayOfMovies:(NSArray *)movieArray
{
#if 1
	
	NSArray *films = [self getVideoFilesIn:kBundle];
	_pipViews = @[].mutableCopy;
	for (NSString *film in films) {
		MyAVPlayerView *pipView = [self newPlayerWithURL:[NSURL fileURLWithPath:film]];
		if (_pipViews.count == 0)
			_currentMainView = pipView;
		[_pipViews addObject:pipView];
	}

#else
	NSURLComponents *baseURL;

	baseURL = [[NSURLComponents alloc] init];
	baseURL.scheme = scheme;
	baseURL.host = server;
	baseURL.user = username;
	baseURL.password = password;
	baseURL.path = basePath;
	_currentMainView = [self newPlayerWithURL:[[baseURL URL] URLByAppendingPathComponent:video1]];
	NSURL *url = [[baseURL URL] URLByAppendingPathComponent:video1];
	MyAVPlayerView *pipViewA = [self newPlayerWithURL: url];
	url = [[baseURL URL] URLByAppendingPathComponent:video2];
	MyAVPlayerView *pipViewB = [self newPlayerWithURL: [[baseURL URL] URLByAppendingPathComponent:video2]];
	_pipViews = @[_currentMainView, pipViewA, pipViewB];
#endif
	_currentMainView.master = YES;
	_currentMainView.isCurrentMainView = YES;
	_masterPlayer = _currentMainView.player;
		CGFloat height, width;
	_videoContent.frame = self.view.frame;
	height = MIN(_videoContent.frame.size.width, _videoContent.frame.size.height);
	width = MAX(_videoContent.frame.size.width, _videoContent.frame.size.height);;
	
	CGRect frame;
	frame.size.width = width / 5;
	frame.size.height = frame.size.width * 9.0/16.0;
	frame.origin.x = 10;
	frame.origin.y = height - frame.size.height - 10;
	NSString *frameString1 = NSStringFromCGRect(frame);
	frame.origin.x = width - frame.size.width - 10;
	NSString *frameString2 = NSStringFromCGRect(frame);
	frame.origin.x = 10;
	frame.origin.y = 10;
	NSString *frameString3 = NSStringFromCGRect(frame);
	frame.origin.x = width - frame.size.width - 10;
	NSString *frameString4 = NSStringFromCGRect(frame);
	frame.origin.y = height - frame.size.height - 10;
	frame.origin.x = (width - frame.size.width) / 2;
	NSString *frameString5 = NSStringFromCGRect(frame);
	frame.origin.y = 10;
	frame.origin.x = (width - frame.size.width) / 2;
	NSString *frameString6 = NSStringFromCGRect(frame);
	NSArray *framesArray = @[frameString1, frameString2, frameString3, frameString4, frameString5, frameString6];
	_currentMainView.frame =_videoContent.frame;  // set to actual video aspect

	_currentMainView.backgroundColor = [UIColor clearColor];
	NSInteger frameIndex = 0;
	for (MyAVPlayerView *pipView in _pipViews) {
		if (!pipView.isCurrentMainView) {
			[self removePipGestureRecognizers:pipView];
			[self addPipGestureRecognizers:pipView];
			if (frameIndex >= framesArray.count)
				frameIndex = 0;
			CGRect aFrame = CGRectFromString(framesArray[frameIndex++]);
			pipView.frame = aFrame;
			pipView.smallHeight = aFrame.size.height;
			pipView.smallWidth = aFrame.size.width;
		}
		[_videoContent addSubview:pipView];
		pipView.bigHeight = height;
		pipView.bigWidth = width;
	}

	NSArray *timeOffsets = @[@(5.0),
							 @(10.0),
							 @(12.5),
							 @(20.0),
							 @(25.0),
							 @(30.0),
							 @(32.75),
							 @(40.5),
							 @(58),
							 @(56),
							 @(60),
							 @(68),
							 @(76),
							 @(84.0),
							 @(92.5),
							 @(100.0),
							 @(104.0),
							 @(110.0),
							 @(116.0),
							 @(122.75),
							 @(130.5),
							 @(135.0),
							 @(142),
							 @(150),
							 @(158.0),
							 @(167.0),
							 @(176.0),
							 @(180),
							 @(185.0),
							 @(190),
							 ];
	captions = @[
				 @"This is a title.",
				 @"These titles will appear once in a while",
				 @"at different timecodes (as specified in an array)",
				 @"and they will disappear",
				 @"at different timecodes",
				 @"the timing isn't frame perfect",
				 @"they are based on time not frames",
				 @"frames get dropped and compression alters frame rate",
				 @"but despite that they still show up",
				 @"and disappear, pretty much on schedule.",
				 @"They can be anywhere on the screen if we want,",
				 @"and do multiple lines with two fonts (or more)",
				 @"We can even do a number of fancy transitions",
				 ];
	__weak id weakSelf = self;
	timeObserver = [_masterPlayer addBoundaryTimeObserverForTimes:timeOffsets queue:dispatch_get_main_queue() usingBlock:^{
		[weakSelf handleCaptionAction];
	}];
	
	[self removeConstraintsAndMakeMain];
	for (MyAVPlayerView *pipView in _pipViews) {
		if (!pipView.isCurrentMainView) {
			[self makeConstraints:pipView];
			[pipView makeBorder];
			[self mutePlayer:pipView.player mute:YES];
		}
	}
	//    [self mute:YES];
	UIAlertView *alert = [UIAlertView.alloc initWithTitle:@"instructions" message:
						  @"•Tap on main vid makes it play/pause\r"
						  "•Double-tap on main vid makes it rewind\r"
						  "•Drag PIP to reposition, Pinch PIP to resize\r"
						  "•Double-tap on PIP to switch it to main\r"
						  "New:\r"
						  "•Two finger tap on any to toggle mute\r"
						  "•Tap-drag on main vid to scrub\r"
												 delegate:self cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
	[alert show];
}


- (void)loadMovieFromCameraRoll
{
	
//	if ([self.popover isPopoverVisible]) {
//		[self.popover dismissPopoverAnimated:YES];
//	}
	// Initialize UIImagePickerController to select a movie from the camera roll.
	UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
	videoPicker.delegate = self;
	videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
	videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie];
	videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
//	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//		self.modal = [[UIViewController alloc] init:videoPicker];
//		self.popover.delegate = self;
////		[self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
//		[self.popover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//	}
//	else {
	{
		[self presentViewController:videoPicker animated:YES completion:nil];
	}
}



-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//	[self loadMovieFromCameraRoll];
	[self togglePlay];

}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
-(void)dealloc
{
	for (MyAVPlayerView *pipView in _pipViews) {
		[pipView.player removeObserver:self
							forKeyPath:@"status"];

	}
	[_masterPlayer removeTimeObserver:timeObserver];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}
- (MyAVPlayerView *)newPlayerWithURL:(NSURL *)url {
	MyAVPlayerView *aPlayerView = [MyAVPlayerView.alloc init];
	AVPlayer *player = [AVPlayer playerWithURL:url];
	[player addObserver:self
			 forKeyPath:@"status"
				options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
				context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];

	_notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		if (player == _masterPlayer)
			[self resetCaptioning];
		[[player currentItem] seekToTime:kCMTimeZero];
		[player play];
	}];
	aPlayerView.player = player;
	return aPlayerView;
}
#pragma mark Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//		[self.modal dismissPopoverAnimated:YES];
//	}
//	else {
	{
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	
	NSURL *url = info[UIImagePickerControllerReferenceURL];
	AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	// Make sure playback is resumed from any interruption.
}

# pragma mark Popover Controller Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	// Make sure playback is resumed from any interruption.
}

#pragma mark - AutoLayout

- (void)removeConstraintsAndMakeMain
{
	[_currentMainView removeConstraints:_currentMainView.constraints];
	[_videoContent removeConstraints:_videoContent.constraints];
	[_currentMainView makeStandardConstraints];
	currentCenterXConstraint = [NSLayoutConstraint constraintWithItem:_currentMainView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_videoContent attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
	currentCenterYConstraint = [NSLayoutConstraint constraintWithItem:_currentMainView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_videoContent attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
	[_videoContent addConstraints:@[currentCenterXConstraint, currentCenterYConstraint]];
	
	CGFloat height, width;
	height = MIN(_videoContent.frame.size.width, _videoContent.frame.size.height);
	width = MAX(_videoContent.frame.size.width, _videoContent.frame.size.height);;
	//	[_currentMainView addConstraint:[NSLayoutConstraint constraintWithItem:_currentMainView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width]];
	//	[_currentMainView addConstraint:[NSLayoutConstraint constraintWithItem:_currentMainView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
	
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
	//	NSDictionary *views = @{@"captionLabel":captionLabel};
	//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=30-[captionLabel(<=600@500)]->=30-|" options:0 metrics:nil views:views]];
	//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=30-[captionLabel(==50@500)]->=30-|" options:0 metrics:nil views:views]];
	
}
- (void)makeConstraints:(MyAVPlayerView *)aPipView
{
	[aPipView removeConstraints:aPipView.constraints];
	[aPipView makeStandardConstraints];
	//	NSDictionary *views = @{@"main":_mainView};
	//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[main]-|" options:0 metrics:nil views:views]];
	//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[main]-|" options:0 metrics:nil views:views]];
	
	//	NSLayoutConstraint *pipWidthConstraint = [NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:aPipView.pipRect.size.width];
	//	[aPipView addConstraint:pipWidthConstraint];
	//	aPipView.pipWidthConstraint = pipWidthConstraint;
	//	[aPipView addConstraint:[NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:aPipView attribute:NSLayoutAttributeWidth multiplier:9.0/16.0 constant:0.0f]];
	
	aPipView.pipCenterXConstraint = [NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_videoContent attribute:NSLayoutAttributeLeft multiplier:1.0 constant:aPipView.center.x];
	aPipView.pipCenterYConstraint = [NSLayoutConstraint constraintWithItem:aPipView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_videoContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:aPipView.center.y];
	[_videoContent addConstraints: @[aPipView.pipCenterYConstraint, aPipView.pipCenterXConstraint]];
	//	[_videoContent layoutIfNeeded];
}


#pragma mark - Gestures
- (void)removePipGestureRecognizers:(MyAVPlayerView *)aPipView {
	[aPipView removeGestureRecognizer:aPipView.swapTap];
	[aPipView removeGestureRecognizer:aPipView.twoFingerTap];
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
	aPipView.twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
	aPipView.twoFingerTap.numberOfTouchesRequired = 2;
	[aPipView addGestureRecognizer:aPipView.twoFingerTap];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
	[self togglePlay];
	
	//	[yourPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:queue usingBlock:^(CMTime time)
	//	{
	//		yourLabel.text = @"your string".
	//	}
	
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
	[self rewind];
}

- (IBAction)handleTwoFingerTap:(UITapGestureRecognizer *)recognizer
{
	AVPlayer *player;
	if (recognizer.view == _videoContent)
		player = _masterPlayer;
	else
		player = ((MyAVPlayerView *)recognizer.view).player;
	[self toggleMutePlayer:player];
}

- (void)handleSwapTap:(UIGestureRecognizer *)gesture
{
	
	MyAVPlayerView *aPipView = (MyAVPlayerView *)gesture.view;
	
	CGRect origFrame = aPipView.frame;
	
	if (_videoContent.subviews[1] != aPipView) {
		NSInteger index = [_videoContent.subviews indexOfObject:aPipView];
		[_videoContent exchangeSubviewAtIndex:1 withSubviewAtIndex:index];
		[self.view layoutIfNeeded];
	}
	
	[aPipView removeBorder];
	[UIView animateWithDuration:0.25 animations:^{
		// TODO: this frame assumes all vids are the same aspect ratio
		aPipView.frame = _currentMainView.frame;
	} completion:^(BOOL finished) {
		MyAVPlayerView *bPipView = aPipView;
		MyAVPlayerView *aView = _currentMainView;
		_currentMainView.isCurrentMainView = NO;
		_currentMainView = aPipView;
		_currentMainView.isCurrentMainView = YES;
		bPipView = aView;
		bPipView.smallWidth = origFrame.size.width;
		bPipView.smallHeight = origFrame.size.height;
		bPipView.frame = origFrame;
		bPipView.alpha = 0;
		
		[_videoContent sendSubviewToBack:_currentMainView];
		[self removeConstraintsAndMakeMain];
		for (MyAVPlayerView *pipView in _pipViews) {
			if (!pipView.isCurrentMainView) {
				[self makeConstraints:pipView];
				[self mutePlayer:pipView.player mute:YES];
			}
			else
				[self mutePlayer:pipView.player mute:NO];

		}
		[bPipView makeBorder];
		[UIView animateWithDuration:0.25 animations:^{
			bPipView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[self addPipGestureRecognizers:(MyAVPlayerView *) bPipView];
			[self removePipGestureRecognizers:_currentMainView];
			
		}];
	}];
}

- (IBAction)handleMainPanDrag:(UIPanGestureRecognizer *)recognizer
{
	
	CGPoint translation = [recognizer translationInView:_videoContent];
	[recognizer setTranslation:CGPointMake(0, 0) inView:_videoContent];
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	CGFloat maxHeight, maxWidth;
	maxHeight = MIN(_videoContent.frame.size.width, _videoContent.frame.size.height);
	maxWidth = MAX(_videoContent.frame.size.width, _videoContent.frame.size.height);;

	currentCenterYConstraint.constant += translation.y ;
	if (currentCenterYConstraint.constant < (_currentMainView.frame.size.height - maxHeight) / 2)
		currentCenterYConstraint.constant = (_currentMainView.frame.size.height - maxHeight) / 2;
	if (currentCenterYConstraint.constant > (maxHeight - _currentMainView.frame.size.height) / 2)
		currentCenterYConstraint.constant = (maxHeight - _currentMainView.frame.size.height) / 2;

	currentCenterXConstraint.constant += translation.x ;
	if (currentCenterXConstraint.constant < (_currentMainView.frame.size.width - maxWidth) / 2)
		currentCenterXConstraint.constant = (_currentMainView.frame.size.width - maxWidth) / 2;
	if (currentCenterXConstraint.constant > (maxWidth - _currentMainView.frame.size.width) / 2)
		currentCenterXConstraint.constant = (maxWidth - _currentMainView.frame.size.width) / 2;
	[CATransaction commit];
}

- (IBAction)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
	CGPoint translation = [recognizer translationInView:_videoContent];
	
//	recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
//										 recognizer.view.center.y + translation.y);
	[recognizer setTranslation:CGPointMake(0, 0) inView:_videoContent];
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	//	self.pipView.center = CGPointMake(self.pipView.center.x - translation.x * 1.0,
	//												self.pipView.center.y - translation.y * 1.0);
	CGFloat maxHeight, maxWidth;
	maxHeight = MIN(_videoContent.frame.size.width, _videoContent.frame.size.height);
	maxWidth = MAX(_videoContent.frame.size.width, _videoContent.frame.size.height);;
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
	else if (gesture.state == UIGestureRecognizerStateChanged)
	{
		// Apply the scale of the gesture to get the new scale
		CGFloat width = MAX(_videoContent.frame.size.height, _videoContent.frame.size.width);
		pipWidthConstraint.constant = scaleStart * gesture.scale;
		if (pipWidthConstraint.constant > 2 * width / 3)
			pipWidthConstraint.constant = 2 * width / 3;
		if (pipWidthConstraint.constant < width / 5)
			pipWidthConstraint.constant = width / 5;
		CGPoint translation = [gesture locationInView:nil];
		
		
	}
	else if (gesture.state == UIGestureRecognizerStateEnded)
	{
//		aPipView.pipRect = aPipView.frame;
		aPipView.smallWidth = aPipView.frame.size.width;
		aPipView.smallHeight = aPipView.frame.size.height;
	}
}

- (IBAction)handleScrubDrag:(UIPanGestureRecognizer *)gesture
{
	static BOOL scrubHasBegun = NO;
	static CGPoint pressStart;
	static float savedRate = 0;
	static 	UILabel *scrubHUD;
	
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		savedRate = _masterPlayer.rate;
		scrubHasBegun = YES;
		// Take an snapshot of the initial scale
		pressStart = [gesture locationInView:gesture.view];
		scrubHUD = [UILabel.alloc init];
		scrubHUD.translatesAutoresizingMaskIntoConstraints = NO;
		scrubHUD.textColor = [UIColor whiteColor];
		scrubHUD.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.75];
		[self.view addSubview:scrubHUD];
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:scrubHUD attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:scrubHUD attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-40]];
		scrubHUD.text = [NSString stringWithFormat:@"%.3fx", _masterPlayer.rate];
		[scrubHUD sizeToFit];
		[scrubHUD layoutIfNeeded];
		[scrubHUD updateConstraintsIfNeeded];
	}
	else if (gesture.state == UIGestureRecognizerStateChanged)
	{
		// Apply the scale of the gesture to get the new scale
		CGFloat width = MAX(_videoContent.frame.size.height, _videoContent.frame.size.width);
		CGFloat delta = [gesture locationInView:gesture.view].x - pressStart.x;
		[self setRate:delta / 200];
		scrubHUD.text = [NSString stringWithFormat:@"%0.3fx", _masterPlayer.rate];
		[scrubHUD sizeToFit];
		[scrubHUD layoutIfNeeded];
		[scrubHUD updateConstraintsIfNeeded];
	}
	else if (gesture.state == UIGestureRecognizerStateEnded)
	{
		if (scrubHasBegun) {
			[self setRate:savedRate];
			[scrubHUD removeFromSuperview];
			scrubHUD = nil;
		}
	}
}
#pragma mark - KVO

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
				
				[player prerollAtRate:3.0 completionHandler:^(BOOL finished) {
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

#pragma mark - Video Transport
- (void)rewind
{
	[self resetCaptioning];
	// future: each player has its own start time
	for (MyAVPlayerView *pipView in _pipViews) {
		[[pipView.player currentItem] seekToTime:kCMTimeZero];
	}
	
}

- (void)play {
	// future: not all players start at the same time
	for (MyAVPlayerView *pipView in _pipViews) {
		[pipView.player play];
	}
}

- (void)togglePlay {
	if ([self isPlaying]) {
		for (MyAVPlayerView *pipView in _pipViews) {
			[pipView.player pause];
		}
	}
	else {
		for (MyAVPlayerView *pipView in _pipViews) {
			[pipView.player play];
		}
	}
}
- (void)setRate:(float)rate
{
	for (MyAVPlayerView *pipView in _pipViews) {
		pipView.player.rate = rate;
	}
}
- (void)toggleMutePlayer:(AVPlayer *)player
{
	player.muted = !player.isMuted;
}
- (void)mutePlayer:(AVPlayer *)player mute:(BOOL)mute
{
	player.muted = mute;
}

- (void)toggleMute {
	for (MyAVPlayerView *pipView in _pipViews) {
		pipView.player.muted = !pipView.player.isMuted;
	}
}
- (void)mute:(BOOL)mute {
	for (MyAVPlayerView *pipView in _pipViews) {
		pipView.player.muted = mute;
	}
}
- (BOOL)isPlaying
{
	return /**mRestoreAfterScrubbingRate != 0.f ||**/ [_masterPlayer rate] != 0.f;
}


#pragma mark - Video Location

NSString *GetDocumentsDirectory()
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}


#define kVideoFilesDirectory @"VideoFiles"

- (NSArray *)getVideoFilesIn:(MZVideoFileLocation)aLocation
{
	NSString *dir;
	if (aLocation == kLibrary) {
		return nil;
	}
	else {
		
		if (aLocation == kDocuments) {
			dir = [GetDocumentsDirectory() stringByAppendingPathComponent:kVideoFilesDirectory];
		}
		else if (aLocation == kBundle) {
			NSBundle *mainBundle = [NSBundle mainBundle];
			dir = [NSString stringWithFormat:@"%@/%@", [mainBundle resourcePath], kVideoFilesDirectory];
		}
		else if (aLocation == kTempFolder) {
			dir = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), kVideoFilesDirectory];
		}
		NSFileManager *filemanager = [NSFileManager defaultManager];
		NSArray *listing = [filemanager contentsOfDirectoryAtPath:dir error:nil];
		NSMutableArray *newListing = [NSMutableArray arrayWithCapacity:listing.count];
		for (NSString *fileName in listing) {
			BOOL isDirectory;
			NSString *path = [dir stringByAppendingPathComponent:fileName];
			[filemanager fileExistsAtPath:path isDirectory:&isDirectory];
			if (!isDirectory)
				[newListing addObject:path];
		}
		return newListing.copy;
	}
	return nil;
}

#pragma mark - Captioning

- (void)resetCaptioning
{
	captionIndex = 0;
	captionLabel.hidden = YES;
}
- (void)handleCaptionAction {
	if (captionLabel.hidden) {
		captionLabel.text = captions[captionIndex++];
		[captionLabel sizeToFit];
		
		if (captionIndex >= captions.count)
			captionIndex = 0;
		captionLabel.alpha = 0;
		captionLabel.hidden = NO;
		[UIView animateWithDuration:.75 animations:^{
			captionLabel.alpha = 1.0;
		}];
	}
	else {
		[UIView animateWithDuration:1.0 animations:^{
			captionLabel.alpha = 0;
		} completion:^(BOOL finished) {
			captionLabel.hidden = YES;
		}];
	}
}

@end

@implementation MyLabelWithPadding
- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:(CGRect)frame];
	if (self) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.textAlignment = NSTextAlignmentCenter;
		self.textColor = [UIColor whiteColor];
		self.clipsToBounds = YES;
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
		self.layer.cornerRadius = 3.0;
		self.layer.borderColor = [UIColor whiteColor].CGColor;
		self.layer.borderWidth = 3.0;
		self.text = @"-------------";
		self.numberOfLines = 0;
		CGRect frame = UIScreen.mainScreen.applicationFrame;
		self.preferredMaxLayoutWidth = 2.0 * MAX(frame.size.height, frame.size.width) / 3.0;
		self.hidden = YES;
		self.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:36];
		//		[self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
		//		[self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisVertical];
		//		[self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
		//		[self setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
		
	}
	return self;
}

-(CGSize)intrinsicContentSize
{
	CGSize contentSize = [super intrinsicContentSize];
	return CGSizeMake(contentSize.width + 80, contentSize.height + 50);
}

@end
