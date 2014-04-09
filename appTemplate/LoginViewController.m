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
@synthesize regMode = _regMode;
@synthesize segControl = _segControl;

#pragma mark - view control flow
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  init loginIndicator's state
    [_loginIndicator stopAnimating];
    
    //  add tap gesture for dismisskeyboard while tapping outside of editable components
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //  init with login mode
    [self setLoginMode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions
/*
    action of "touch up inside" for login button
 */
- (IBAction)login:(id)sender {
    if ([_usernameText.text isEqual:@""] || [_passwordText.text isEqual:@""] || (![_confirmText isHidden] && [_confirmText.text isEqual:@""])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登入/註冊錯誤"
                                                        message:@"帳號或密碼不得為空"
                                                       delegate:nil
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        if(_regMode) {
            NSLog(@"Register the user");
            //  prepare parameters to register
            NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        _usernameText.text, coimReqParams.accName,
                                        _passwordText.text, coimReqParams.passwd,
                                        _confirmText.text, coimReqParams.passwd2,
                                        nil];
            NSLog(@"_pass: %@", _passwordText.text );
            NSLog(@"_pass2: %@", _confirmText.text );
            //  create connection to register API
            _connection = [coimSDK registerWithParameter:parameters delegate:self];
            [_connection setAccessibilityLabel:REGISTER_CONNECTION_LABEL];
            
            //  disable UI util receive results
            [self setDisable];
        }
        else {
            //  prepare parameters to login
            NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        _usernameText.text, coimReqParams.accName,
                                        _passwordText.text, coimReqParams.passwd,
                                        nil];
            
            //  create connection to login API
            NSLog(@"_pass: %@", _passwordText.text );
            _connection = [coimSDK loginTo:coimLoginURI withParameter:parameters delegate:self];
            [_connection setAccessibilityLabel:LOGIN_CONNECTION_LABEL];
            
            //  disable UI util receive results
            [self setDisable];
        }
    }
}
/*
    action of "value change" for segment controller
 */
- (IBAction)segChange:(id)sender {
    //  change the mode between login/register
    switch ([_segControl selectedSegmentIndex]) {
        case 0:
            [_loginButton setTitle:@"登入" forState:UIControlStateNormal];
            [self setLoginMode];
            
            break;
        case 1:
            [_loginButton setTitle:@"註冊" forState:UIControlStateNormal];
            [self setRegisterMode];
            break;
        default:
            break;
    }
}

#pragma mark - coimotion delegate
/*
    connection receives data
 */
- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
                              withData:(NSDictionary *)responseData
{
    //  check accessibilityLabel to tell data comes from which API
    if ([[_connection accessibilityLabel] isEqualToString:REGISTER_CONNECTION_LABEL]) {
        //  register connection
        [appUtil enterApp];
    }
    else if ([[_connection accessibilityLabel] isEqualToString:LOGIN_CONNECTION_LABEL]) {
        //  login connection
        [appUtil enterApp];
    }
    [self setEnable];
}

- (void)coimConnection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error
{
    NSLog(@"err: %@", [error localizedDescription]);
    NSLog(@"err: %d", [error code]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登入/註冊錯誤"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"確定"
                                          otherButtonTitles:nil];
    [alert show];
    [self setEnable];
}

#pragma mark - subfunctions
/*
    setDisable: UI changes to disabled
    setEnable: UI changes to enabled
    setRegisterMode: UI changes to register mode
    setLoginMode: UI changes to login mode
    dismissKeyboard: dismiss keyboard while tapping outside editable components
 */
- (void)setDisable
{
    [_usernameText setEnabled:NO];
    [_passwordText setEnabled:NO];
    [_loginButton setEnabled:NO];
    [_loginButton setBackgroundColor:[UIColor clearColor]];
    [_loginIndicator startAnimating];
}

- (void)setEnable
{
    [_usernameText setEnabled:YES];
    [_passwordText setEnabled:YES];
    [_loginButton setEnabled:YES];
    [_loginButton setBackgroundColor:[UIColor clearColor]];
    [_loginIndicator stopAnimating];
}

- (void)setRegisterMode
{
    NSLog(@"set to reg");
    [_confirmText setHidden:NO];
    [_loginButton setTitle:@"註冊" forState:UIControlStateNormal];
    _regMode = YES;
    [_segControl setSelectedSegmentIndex:1];
    CGRect loginButtonFrame = _loginButton.frame;
    _loginButton.frame = CGRectMake(loginButtonFrame.origin.x, TOP_OF_BUTTON, loginButtonFrame.size.width, loginButtonFrame.size.height);
    CGRect indicatorFrame = _loginIndicator.frame;
    _loginIndicator.frame = CGRectMake(indicatorFrame.origin.x, TOP_OF_INDICATOR, indicatorFrame.size.width, indicatorFrame.size.height);
}

- (void)setLoginMode
{
    NSLog(@"set to login");
    [_confirmText setHidden:YES];
    [_loginButton setTitle:@"登入" forState:UIControlStateNormal];
    _regMode = NO;
    [_segControl setSelectedSegmentIndex:0];
    CGRect loginButtonFrame = _loginButton.frame;
    _loginButton.frame = CGRectMake(loginButtonFrame.origin.x, TOP_OF_BUTTON - SHIFT, loginButtonFrame.size.width, loginButtonFrame.size.height);
    CGRect indicatorFrame = _loginIndicator.frame;
    _loginIndicator.frame = CGRectMake(indicatorFrame.origin.x, TOP_OF_INDICATOR - SHIFT, indicatorFrame.size.width, indicatorFrame.size.height);
}

- (void)dismissKeyboard
{
    [_usernameText resignFirstResponder];
    [_passwordText resignFirstResponder];
    [_confirmText resignFirstResponder];
}

@end
