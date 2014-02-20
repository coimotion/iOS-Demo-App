//
//  LoginViewController.m
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize connection;
@synthesize loginIndicator;
@synthesize loginButton;
@synthesize username, password;

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
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] init];
    plist = [[appUtil sharedUtil] getPlistfrom:@"/demo.plist"];
    if ([plist objectForKey:@"appCode"] == nil) {
        [plist setValue:@"demoApp" forKey:@"appCode"];
    }
    [loginIndicator stopAnimating];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    NSString *URL = @"http://192.168.1.190:3000/demoApp/core/user/login";
    NSString *parameters = [[NSString alloc] initWithFormat:@"accName=%@&passwd=%@", username.text, password.text];
    NSLog(@"%@", parameters);
    NSURLRequest *loginReq = [[appUtil sharedUtil] getHttpConnectionByMethod:@"POST" toURL:URL useData:parameters];
    if (!connection) {
        connection = [[NSURLConnection alloc] initWithRequest:loginReq delegate:self];
    }
    else {
        [connection cancel];
        connection = [[NSURLConnection alloc] initWithRequest:loginReq delegate:self];
    }
    [connection setAccessibilityLabel:@"login"];
    [self setDisable];
}

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    if ([[connection accessibilityLabel] isEqualToString:@"login"]) {
        //parse json, save token;
        NSDictionary *loginInfoDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        NSLog(@"recieved: %@", [[NSString alloc] initWithData:incomingData encoding:NSUTF8StringEncoding]);
        if ([loginInfoDic objectForKey:@"token"] != nil) {
            [[appUtil sharedUtil] setToken:[loginInfoDic objectForKey:@"token"]];
            TableListingViewController *tableListVC = [[TableListingViewController alloc] init];
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:tableListVC];
            [[appUtil sharedUtil] setRootWindowView:naviVC];
        }
    }
    //[NSThread sleepForTimeInterval:2];
    [self setEnable];
}

- (void)setDisable
{
    [username setEnabled:NO];
    [password setEnabled:NO];
    [loginButton setEnabled:NO];
    [loginIndicator startAnimating];
    [loginButton setBackgroundColor:[UIColor grayColor]];
}

- (void)setEnable
{
    [username setEnabled:YES];
    [password setEnabled:YES];
    [loginButton setEnabled:YES];
    [loginIndicator stopAnimating];
    [loginButton setBackgroundColor:[UIColor whiteColor]];
}

@end
