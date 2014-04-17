//
//  rCell.h
//  appTemplate
//
//  Created by Mac on 2014/4/17.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UILabel *stopLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end
