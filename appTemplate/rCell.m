//
//  rCell.m
//  appTemplate
//
//  Created by Mac on 2014/4/17.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "rCell.h"

@implementation rCell
@synthesize icon;
@synthesize stopLabel;
@synthesize timeLabel;

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
