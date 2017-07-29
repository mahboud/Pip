//
//  ItemSelectionTableView.h
//
//  Created by mahboud on 1/14/15.
//

#import <UIKit/UIKit.h>

@interface ItemSelectionTableView : UIView
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet UIImageView *thumb;

@property(nonatomic, assign) id<UITableViewDataSource> tableViewDataSource;
@property(nonatomic, assign) id<UITableViewDelegate> tableViewDelegate;

- (void)resizeToFit;
- (void)flutter;
- (void)hideThumb;
- (void)showThumb;
- (void)autoShowHideThumb:(BOOL)autoOn;
- (void)autoClose:(BOOL)autoOn;
- (void)pullOpen;
- (void)pushClosed;

@end
