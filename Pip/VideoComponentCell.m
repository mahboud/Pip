//
//  VideoComponentCell.m
//
//  Created by mahboud on 1/14/15.
//

#import "VideoComponentCell.h"

@implementation VideoComponentCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)prepareForReuse
{
	_dragOutGesture = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
