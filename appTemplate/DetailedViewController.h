//
//  DetailedViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"

@interface DetailedViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *summaryText;
@property (strong, nonatomic) IBOutlet UITextView *addrText;
@property (strong, nonatomic) IBOutlet UITextView *bodyText;
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSString *detailURL;
@property (strong, nonatomic) NSURLConnection *connection;
@end
