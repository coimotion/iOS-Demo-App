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

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *loginButton;
- (IBAction)login:(id)sender;

@end
