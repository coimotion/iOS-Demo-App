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
#define TOP_OF_BUTTON 236
#define TOP_OF_CONFIRM 198

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *confirmText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSString *loginURL;
@property bool regMode;

- (IBAction)login:(id)sender;
- (IBAction)segChange:(id)sender;

@end
