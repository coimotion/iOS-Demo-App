//
//  MainViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LoginViewController.h"
#define CHECK_TOKEN_CONNECTION_LABEL @"checkTokenConn"

@interface MainViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSString *checkTokenURL;
@end
