//
//  SegmentCell.m
//  WakeMeUp
//
//  Created by Milo Gosnell on 5/12/14.
//  Copyright (c) 2014 Milo Gosnell. All rights reserved.
//

#import "SegmentCell.h"

@implementation SegmentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
