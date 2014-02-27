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
@synthesize confirmText = _confirmText;
@synthesize loginURL = _loginURL;
@synthesize registerURL = _registerURL;
@synthesize activateURL = _activateURL;
@synthesize regMode = _regMode;
@synthesize segControl = _segControl;

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
    NSLog(@"view did load");
    _loginURL = [[NSString alloc] initWithFormat:@"%@/%@/%@", coiBaseURL,
                                                              coiAppCode,
                                                              coiLoginURI];
    _registerURL = [[NSString alloc] initWithFormat:@"%@/%@/%@", coiBaseURL,
                                                                 coiAppCode,
                                                                 coiRegisterURI];
    [_loginIndicator stopAnimating];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self setLoginMode];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    if(_regMode) {
        NSLog(@"Register the user");
        NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@&%@=%@", coiReqParams.accName, _usernameText.text,
                                                                                      coiReqParams.passwd, _passwordText.text,
                                                                                      coiReqParams.passwd2, _confirmText.text];
        NSLog(@"parameters: %@", parameters);
        NSURLRequest *registerReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodPost toURL:_registerURL useData:parameters];
        _connection = [[NSURLConnection alloc] initWithRequest:registerReq delegate:self];
        [_connection setAccessibilityLabel:REGISTER_CONNECTION_LABEL];
        [self setDisable];
    }
    else {
        NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@", coiReqParams.accName, _usernameText.text,
                                                                                coiReqParams.passwd, _passwordText.text];
        NSURLRequest *loginReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodPost toURL:_loginURL useData:parameters];
        _connection = [[NSURLConnection alloc] initWithRequest:loginReq delegate:self];
        [_connection setAccessibilityLabel:LOGIN_CONNECTION_LABEL];
        [self setDisable];
    }
}

- (IBAction)segChange:(id)sender {
    switch ([_segControl selectedSegmentIndex]) {
        case 0:
            [self setLoginMode];
            break;
        case 1:
            [self setRegisterMode];
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] != 200) {
        [[[UIAlertView alloc] initWithTitle:LOGIN_ERROR
                                    message:[[NSString alloc] initWithFormat:@"%d",[httpResponse statusCode]]
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    NSLog(@"received: %@", [[NSString alloc] initWithData:incomingData encoding:NSUTF8StringEncoding]);
    NSDictionary *receivedDataDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
    int erroCode = [[receivedDataDic objectForKey:coiResParams.errCode] integerValue];
    if ([[_connection accessibilityLabel] isEqualToString:ACTIVATE_CONNECTION_LABEL]) {
        if (erroCode == 0) {
            [[appUtil sharedUtil] setToken:[receivedDataDic objectForKey:coiResParams.token]];
            [[appUtil sharedUtil] saveObject:[receivedDataDic objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist];
            [[appUtil sharedUtil] enterApp];}
    }
    
    if ([[_connection accessibilityLabel] isEqualToString:REGISTER_CONNECTION_LABEL]) {
        if (erroCode == 0) {
            NSString *actID = [[receivedDataDic objectForKey:coiResParams.value] objectForKey:coiResParams.actID];
            _activateURL = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", coiBaseURL,
                            coiAppCode,
                            coiActivateURI,
                            actID];
            NSURLRequest *activateReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodPost toURL:_activateURL useData:@""];
            _connection = [[NSURLConnection alloc] initWithRequest:activateReq delegate:self];
            [_connection setAccessibilityLabel:ACTIVATE_CONNECTION_LABEL];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:LOGIN_ERROR
                                        message:[receivedDataDic objectForKey:coiResParams.message]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }
    
    if ([[_connection accessibilityLabel] isEqualToString:LOGIN_CONNECTION_LABEL]) {
        if (erroCode == 0) {
            [[appUtil sharedUtil] setToken:[receivedDataDic objectForKey:coiResParams.token]];
            [[appUtil sharedUtil] saveObject:[receivedDataDic objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist]; 
            [[appUtil sharedUtil] enterApp];
        }
        else if (erroCode == -2){
            _passwordText.text = @"";
            [[[UIAlertView alloc] initWithTitle:LOGIN_ERROR
                                       message:[receivedDataDic objectForKey:coiResParams.message]
                                      delegate:nil
                             cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
        else { //unregistered user go register mode
            [self setRegisterMode];
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

- (void)setRegisterMode
{
    [_confirmText setHidden:NO];
    [_loginButton setTitle:@"註冊" forState:UIControlStateNormal];
    _regMode = YES;
    [_segControl setSelectedSegmentIndex:1];
    CGRect loginButtonFrame = _loginButton.frame;
    _loginButton.frame = CGRectMake(loginButtonFrame.origin.x, TOP_OF_BUTTON, loginButtonFrame.size.width, loginButtonFrame.size.height);
}

- (void)setLoginMode
{
    [_confirmText setHidden:YES];
    [_loginButton setTitle:@"登入" forState:UIControlStateNormal];
    _regMode = NO;
    [_segControl setSelectedSegmentIndex:0];
    CGRect loginButtonFrame = _loginButton.frame;
    _loginButton.frame = CGRectMake(loginButtonFrame.origin.x, TOP_OF_CONFIRM, loginButtonFrame.size.width, loginButtonFrame.size.height);
}

- (void)dismissKeyboard
{
    [_usernameText resignFirstResponder];
    [_passwordText resignFirstResponder];
    [_confirmText resignFirstResponder];
}

@end
