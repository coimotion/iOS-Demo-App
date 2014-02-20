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
#import "appUtil.h"

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;
@property (strong, nonatomic) NSURLConnection *connection;

- (IBAction)login:(id)sender;

@end
