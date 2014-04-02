//
//  LoginViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "RouteListViewController.h"
#import "MapListingViewController.h"

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *confirmText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;
@property (strong, nonatomic) NSURLConnection *connection;
@property bool regMode;

- (IBAction)login:(id)sender;
- (IBAction)segChange:(id)sender;

@end
