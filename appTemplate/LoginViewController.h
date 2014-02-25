//
//  LoginViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TableListingViewController.h"
#import "MapListingViewController.h"

#define LOGIN_CONNECTION_LABEL @"loginConn"
#define LOGIN_ERROR @"登入錯誤"

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSString *loginURL;

- (IBAction)login:(id)sender;

@end
