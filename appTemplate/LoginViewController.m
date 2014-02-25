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

@synthesize connection = _connection;
@synthesize loginIndicator = _loginIndicator;
@synthesize loginButton = _loginButton;
@synthesize usernameText = _usernameText;
@synthesize passwordText = _passwordText;
@synthesize loginURL = _loginURL;

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
    _loginURL = [[NSString alloc] initWithFormat:@"%@/%@/%@", coiBaseURL,
                                                              coiAppCode,
                                                              coiLoginURI];
    [_loginIndicator stopAnimating];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@", coiReqParams.accName, _usernameText.text,
                                                                            coiReqParams.passwd, _passwordText.text];
    NSURLRequest *loginReq = [[appUtil sharedUtil] getHttpConnectionByMethod:coiMethodPost toURL:_loginURL useData:parameters];
    if (!_connection) {
        _connection = [[NSURLConnection alloc] initWithRequest:loginReq delegate:self];
    }
    else {
        [_connection cancel];
        _connection = [[NSURLConnection alloc] initWithRequest:loginReq delegate:self];
    }
    [_connection setAccessibilityLabel:LOGIN_CONNECTION_LABEL];
    [self setDisable];
}

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    if ([[_connection accessibilityLabel] isEqualToString:LOGIN_CONNECTION_LABEL]) {
        NSDictionary *loginInfoDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        if ([[loginInfoDic objectForKey:coiResParams.errCode] integerValue] == 0) {
            [[appUtil sharedUtil] setToken:[loginInfoDic objectForKey:coiResParams.token]];
            [[appUtil sharedUtil] saveObject:[loginInfoDic objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist]; 
            
            TableListingViewController *tableListVC = [[TableListingViewController alloc] init];
            UINavigationController *naviVC1 = [[UINavigationController alloc] initWithRootViewController:tableListVC];
            MapListingViewController *mapListVC = [[MapListingViewController alloc] init];
            UINavigationController *naviVC2 = [[UINavigationController alloc] initWithRootViewController:mapListVC];
            UITabBarController *tbc = [[UITabBarController alloc] init];
            [tbc setViewControllers:[[NSArray alloc] initWithObjects:naviVC1, naviVC2, nil]];
            [[appUtil sharedUtil] setRootWindowView:tbc];
        }
        else {
            _passwordText.text = @"";
            [[[UIAlertView alloc] initWithTitle:LOGIN_ERROR
                                       message:[loginInfoDic objectForKey:coiResParams.message]
                                      delegate:nil
                             cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }
    [self setEnable];
}

- (void)setDisable
{
    [_usernameText setEnabled:NO];
    [_passwordText setEnabled:NO];
    [_loginButton setEnabled:NO];
    [_loginIndicator startAnimating];
    [_loginButton setBackgroundColor:[UIColor grayColor]];
}

- (void)setEnable
{
    [_usernameText setEnabled:YES];
    [_passwordText setEnabled:YES];
    [_loginButton setEnabled:YES];
    [_loginIndicator stopAnimating];
    [_loginButton setBackgroundColor:[UIColor whiteColor]];
}

@end
