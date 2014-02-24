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
@synthesize loginURL;

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
    NSDictionary *plist = [[NSDictionary alloc] init];
    plist = [[appUtil sharedUtil] getSettingsFrom:@"coimotion"];
    loginURL = [[NSString alloc] initWithFormat:@"%@/%@/%@",[plist objectForKey:[[appUtil sharedUtil] baseURLKey]],
                                                            [plist objectForKey:[[appUtil sharedUtil] appCodeKey]],
                                                            [plist objectForKey:[[appUtil sharedUtil] loginURIKey]]];
    [loginIndicator stopAnimating];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@", [[appUtil sharedUtil] accNamePraram], username.text, [[appUtil sharedUtil] passwordParam], password.text];
    NSURLRequest *loginReq = [[appUtil sharedUtil] getHttpConnectionByMethod:@"POST" toURL:loginURL useData:parameters];
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
        NSDictionary *loginInfoDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        if ([[loginInfoDic objectForKey:@"errCode"] integerValue] == 0) {
            [[appUtil sharedUtil] setToken:[loginInfoDic objectForKey:@"token"]];
            
            NSMutableDictionary *plist = [[appUtil sharedUtil] getPlistFrom:@"/app.plist"];
            [plist setObject:[loginInfoDic objectForKey:@"token"] forKey:@"token"];
            [[appUtil sharedUtil] setPlist:plist to:@"/app.plist"];
            
            TableListingViewController *tableListVC = [[TableListingViewController alloc] init];
            UINavigationController *naviVC1 = [[UINavigationController alloc] initWithRootViewController:tableListVC];
            [naviVC1 setTitle:@"Table"];
            MapListingViewController *mapListVC = [[MapListingViewController alloc] init];
            UINavigationController *naviVC2 = [[UINavigationController alloc] initWithRootViewController:mapListVC];
            [naviVC2 setTitle:@"Map"];
            UITabBarController *tbc = [[UITabBarController alloc] init];
            [tbc setViewControllers:[[NSArray alloc] initWithObjects:naviVC1, naviVC2, nil]];
            [[appUtil sharedUtil] setRootWindowView:tbc];
        }
        else {
            password.text = @"";
            [[[UIAlertView alloc] initWithTitle:@"Login Error"
                                       message:[loginInfoDic objectForKey:@"message"]
                                      delegate:nil
                             cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }
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
