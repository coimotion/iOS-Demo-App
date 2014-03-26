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

//  progress table
NSMutableDictionary *dic;

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
    //  progress table
    dic = [NSMutableDictionary new];

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
/*
    action of "touch up inside" for login button
 */
- (IBAction)login:(id)sender {
    if(_regMode) {
        NSLog(@"Register the user");
        //  prepare parameters to register
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    _usernameText.text, coimReqParams.accName,
                                    _passwordText.text, coimReqParams.passwd,
                                    _confirmText.text, coimReqParams.passwd2,
                                    nil];
        
        //  create connection to register API
        _connection = [ReqUtil registerWithParameter:parameters delegate:self progressTable:dic];
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
        _connection = [ReqUtil loginTo:coimLoginURI withParameter:parameters delegate:self progressTable:dic];
        [_connection setAccessibilityLabel:LOGIN_CONNECTION_LABEL];
        
        //  disable UI util receive results
        [self setDisable];
    }
}
/*
    action of "value change" for segment controller
 */
- (IBAction)segChange:(id)sender {
    //  change the mode between login/register
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
/*
    connection receives data
 */
- (void)coimConnection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    //  parse JSON string to a dictionary
    NSDictionary *receivedDataDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
    if(receivedDataDic != nil){
        int erroCode = [[receivedDataDic objectForKey:coimResParams.errCode] integerValue];
        //  check accessibilityLabel to tell data comes from which API
        if ([[_connection accessibilityLabel] isEqualToString:REGISTER_CONNECTION_LABEL]) {
            //  register connection
            if (erroCode == 0) {
                [appUtil enterApp];
            }
            else {
                //  register failed, alert message
                [[[UIAlertView alloc] initWithTitle:LOGIN_ERROR
                                            message:[receivedDataDic objectForKey:coimResParams.message]
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }
        }
        
        if ([[_connection accessibilityLabel] isEqualToString:LOGIN_CONNECTION_LABEL]) {
            //  login connection
            if (erroCode == 0) {
                [appUtil enterApp];
            }
            else if (erroCode == -2){
                //  no permission, alert message
                _passwordText.text = @"";
                [[[UIAlertView alloc] initWithTitle:LOGIN_ERROR
                                           message:[receivedDataDic objectForKey:coimResParams.message]
                                          delegate:nil
                                 cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }
            else { //unregistered user go register mode
                [self setRegisterMode];
            }
        }
    }
    [self setEnable];
}
/*
    sub functions
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
