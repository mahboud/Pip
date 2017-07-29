//
//  ItemSelectionTableView.m
//
//  Created by mahboud on 1/14/15.
//

#import "ItemSelectionTableView.h"

@implementation ItemSelectionTableView {
  BOOL thumbViewIsVisible;
  CGSize sizeOfTable;
  CGFloat sizeOfthumbArea;
}

@dynamic tableViewDataSource;
@dynamic tableViewDelegate;

- (void)setTableViewDataSource:(id<UITableViewDataSource>)tableViewDataSource {
  _tableView.dataSource = tableViewDataSource;
}

- (void)setTableViewDelegate:(id<UITableViewDelegate>)tableViewDelegate {
  _tableView.delegate = tableViewDelegate;
}

- (void)awakeFromNib {
  self.backgroundColor = UIColor.clearColor;
  self.tableView.backgroundColor =
      [self.tableView.backgroundColor colorWithAlphaComponent:0.75];
  sizeOfTable.width = self.tableView.frame.size.width;
  sizeOfTable.height = self.tableView.frame.size.height;
  sizeOfthumbArea = self.frame.size.width - sizeOfTable.width;
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(handleThumbTap:)];
  [self.thumb addGestureRecognizer:tapRecognizer];
  UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(handleThumbViewSwipe:)];
  [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
  [self addGestureRecognizer:swipeRecognizer];
  swipeRecognizer = [[UISwipeGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(handleThumbViewSwipe:)];
  [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
  [self addGestureRecognizer:swipeRecognizer];
  self.tableView.bounces = NO;

  [self.tableView registerNib:[UINib nibWithNibName:@"VideoComponentCell"
                                             bundle:nil]
       forCellReuseIdentifier:@"Cell"];

  //
  //	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
  //initWithTarget:self action:@selector(handleTabPan:)];
  //	panRecognizer.maximumNumberOfTouches = 1;
  //	[self addGestureRecognizer:panRecognizer];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                         owner:self
                                       options:0]
               .firstObject;
  }
  return self;
}

- (void)resizeToFit {
  CGRect frame;

  frame = self.superview.frame;

  self.frame =
      CGRectMake(-sizeOfTable.width, frame.size.height - sizeOfTable.height,
                 sizeOfthumbArea + sizeOfTable.width, sizeOfTable.height);
  [self shadow:NO];
}

- (void)shadow:(BOOL)yes {
  self.thumb.layer.shadowColor = [UIColor blackColor].CGColor;
  self.thumb.layer.shadowOpacity = 0.5;
  self.thumb.layer.shadowRadius = 3.0;
  self.thumb.layer.shadowOffset = CGSizeMake(2, 1);
  //	self.thumb.layer.shadowPath = [UIBezierPath
  //bezierPathWithRect:self.thumb.frame].CGPath;

  [self.tableView.layer setShadowColor:[[UIColor blackColor] CGColor]];
  [self.tableView.layer setShadowOpacity:0.5];

  if (yes) {
    [self.tableView.layer setShadowRadius:3.0];
    [self.tableView.layer setShadowOffset:CGSizeMake(2, 1)];
    self.tableView.clipsToBounds = NO;
  } else {
    [self.tableView.layer setShadowRadius:0.0];
    [self.tableView.layer setShadowOffset:CGSizeZero];
    self.tableView.clipsToBounds = YES;
  }
}

- (void)flutter {
}
- (void)handleThumbViewSwipe:(UISwipeGestureRecognizer *)recognizer {

  //    CGPoint location = [recognizer locationInView:self.view];
  //    [self showImageWithText:@"tap" atPoint:location];
  //
  //    [UIView beginAnimations:nil context:NULL];
  //    [UIView setAnimationDuration:0.5];
  //    imageView.alpha = 0.0;
  //    [UIView commitAnimations];
  //	CGPoint startPoint = [recognizer locationOfTouch: 0 inView:self.view];

  // NSLog(@"handle swipe, swipe direction %d number of touches: %d  and
  // startPoint: %@",recognizer.direction, [recognizer numberOfTouches],
  // NSStringFromCGPoint(startPoint));

  if (!thumbViewIsVisible) {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
      [self pullOpen];
    }
  } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
    [self pushClosed];
  }
}

- (void)handleTabPan:(UIPanGestureRecognizer *)recognizer {
  static float thumbOffset;
  static BOOL stretched = NO, intentToOpen;
  static float thumbTabPosition;

  switch (recognizer.state) {
  case UIGestureRecognizerStateBegan:
    //			[self startCloseTimer: NO];
    thumbViewIsVisible = YES;
    thumbTabPosition = [recognizer locationInView:self].x;
    thumbOffset = thumbTabPosition - (self.frame.origin.x + sizeOfTable.width);
    break;
  case UIGestureRecognizerStateChanged: {
    CGPoint panPoint = [recognizer locationInView:self];
    float newOffset = panPoint.x - thumbTabPosition;

    if (newOffset <= (sizeOfTable.width + 2)) {
      if (stretched)
        self.transform = CGAffineTransformIdentity;

      //			NSLog(@"newOffset + thumbViewTab.frame.origin.x
      //= %f, newOffset %f thumbViewTab.frame.origin.x %f", newOffset +
      //thumbViewTab.frame.origin.x, [recognizer locationInView: self.view].x,
      //thumbOffset);

      intentToOpen = thumbTabPosition < panPoint.x;
      thumbTabPosition = panPoint.x; //[recognizer locationInView: self.view].x;
      self.frame =
          CGRectMake(self.frame.origin.x + newOffset,
                     self.superview.frame.size.height - sizeOfTable.height,
                     sizeOfTable.width, self.frame.size.height);
      //				thumbGhostView.frame =
      //CGRectMake(thumbGhostView.frame.origin.x + newOffset,
      //thumbGhostView.frame.origin.y, thumbGhostView.frame.size.width,
      //thumbGhostView.frame.size.height);
      stretched = NO;
    } else {
      //				thumbTabPosition = [recognizer
      //locationInView: self.view].x;
      self.transform = CGAffineTransformMakeScale(
          (thumbTabPosition - thumbOffset) / sizeOfTable.width, 1.0);
      self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                              self.frame.size.width, self.frame.size.height);

      //				thumbGhostView.frame =
      //CGRectMake(thumbGhostView.frame.origin.x + newOffset,
      //thumbGhostView.frame.origin.y, thumbGhostView.frame.size.width,
      //thumbGhostView.frame.size.height);
      stretched = YES;
    }
  } break;
  case UIGestureRecognizerStateCancelled:
  case UIGestureRecognizerStateEnded:
    if (stretched) {
      stretched = NO;
      //				[UIView animateWithDuration:0.25f
      //delay:0 options:UIViewAnimationOptionCurveEaseInOut
      //								 animations:^{
      //									 thumbView.transform
      //= CGAffineTransformIdentity;
      //									 thumbView.frame
      //= CGRectMake(-((thumbTabPosition - thumbOffset)/ kThumbViewWidth) * 20,
      //0, kThumbViewWidth, thumbView.frame.size.height);
      //									 thumbGhostView.frame
      //= CGRectMake(thumbView.frame.origin.x + kThumbViewWidth +
      //kThumbViewBorderWidth, thumbGhostView.frame.origin.y,
      //thumbGhostView.frame.size.width, thumbGhostView.frame.size.height);
      //								 }
      //								 completion:^(BOOL
      //finished) {
      //									 [self
      //showThumbsView: thumbView];
      //								 }];
      //				[UIView animateWithDuration:0.25f
      //delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0
      //options:UIViewAnimationOptionCurveEaseInOut animations:^{
      [UIView animateWithDuration:0.25f
          delay:0
          usingSpringWithDamping:0.5
          initialSpringVelocity:0
          options:UIViewAnimationOptionCurveEaseInOut
          animations:^{
            self.transform = CGAffineTransformIdentity;
            self.frame = CGRectMake(
                -((thumbTabPosition - thumbOffset) / sizeOfTable.width) * 0, 0,
                sizeOfTable.width, self.frame.size.height);
            //					thumbGhostView.frame =
            //CGRectMake(thumbView.frame.origin.x + kThumbViewWidth +
            //kThumbViewBorderWidth, thumbGhostView.frame.origin.y,
            //thumbGhostView.frame.size.width,
            //thumbGhostView.frame.size.height);
          }
          completion:^(BOOL finished) {
            [self pullOpen];
          }];

    } else {
      if (intentToOpen) {
        [self pullOpen];
      } else {
        [self pushClosed];
      }
    }
    break;
  default:
    break;
  }
}

- (void)handleThumbTap:(UITapGestureRecognizer *)recognizer {

  if (!thumbViewIsVisible) {
    [self pullOpen];
  } else {
    [self pushClosed];
  }
}
//- (void)fluttterThumbsView
//{
//	if (thumbViewIsVisible)
//		return;
//	if (thumbView == nil)
//		[self initializeThumbsView];
//	thumbViewIsVisible = YES;
//	//	[UIView animateWithDuration:0.125f delay:0
//options:UIViewAnimationOptionCurveEaseInOut
//	//					 animations:^{
//	[UIView animateWithDuration:0.125f delay:0 usingSpringWithDamping:0.5
//initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut
//animations:^{
//		thumbView.frame = CGRectMake(8 - kThumbViewWidth, -2,
//kThumbViewWidth, thumbView.frame.size.height);
//		thumbGhostView.frame = CGRectMake(8 - 1,
//thumbGhostView.frame.origin.y, thumbGhostView.frame.size.width,
//thumbGhostView.frame.size.height);
//	}
//					 completion:^(BOOL finished) {
//						 [self
//putAwayThumbsView:thumbView];
//					 }];
//
//}

- (void)pullOpen {
  thumbViewIsVisible = YES;

  [UIView animateWithDuration:0.5f
                        delay:0
       usingSpringWithDamping:0.65
        initialSpringVelocity:0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     //		thumbViewTab.alpha = kButtonAlpha;

                     self.frame = CGRectMake(0, self.frame.origin.y,
                                             self.frame.size.width,
                                             self.frame.size.height);
                     [self shadow:YES];
                   }
                   completion:^(BOOL finished){
                       //						 [thumbView
                       //startCloseTimer: YES];
                   }];
}
- (void)pushClosed {
  if (!thumbViewIsVisible)
    return;
  thumbViewIsVisible = NO;
  [UIView animateWithDuration:0.5f
                        delay:0
       usingSpringWithDamping:0.5
        initialSpringVelocity:0
                      options:UIViewAnimationOptionCurveEaseInOut |
                              UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     self.frame = CGRectMake(
                         -sizeOfTable.width, self.frame.origin.y,
                         self.frame.size.width, self.frame.size.height);
                     [self shadow:NO];
                   }
                   completion:^(BOOL finished){
                   }];
}

//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	[self setNeedsLayout];
//	[self startCloseTimer: YES];
//}
//
//- (void)startCloseTimer: (BOOL) yesNo
//{
//	[NSObject cancelPreviousPerformRequestsWithTarget:self
//selector:@selector(callClose) object:nil];
//	if (yesNo)
//		[self performSelector:@selector(callClose) withObject:nil
//afterDelay:8.0];
//
//}
//- (void) callClose
//{
//	[delegate putAwayThumbsView:self];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
