//
//  MainViewController.m
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    bool isLogin = YES;
    if (isLogin) {
        TableListingViewController *tableListVC = [[TableListingViewController alloc] init];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:tableListVC];
        [self setRootViewController:naviVC];
    }
    else {
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self setRootViewController:loginVC];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRootViewController:(UIViewController *)VC
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    app.window.rootViewController = VC;
    [app.window makeKeyAndVisible];
}

@end
