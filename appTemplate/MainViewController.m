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
@synthesize activityIndicator = _activityIndicator;
@synthesize connection = _connection;

// used to save progress information
NSMutableDictionary *dic;
#pragma mark - view control flows
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
    //  init COIMSDK
    [coimSDK initSDK:^(NSError *err){
        if(err)
            NSLog(@"err: %@", [err localizedDescription]);
    }];
    //  parameter to API
    /*
        start with token validation
     */
    _connection = [coimSDK sendTo:coimCheckTokenURI withParameter:nil delegate:self];
    [_connection setAccessibilityLabel:CHECK_TOKEN_CONNECTION_LABEL];
    
    /*
        start with app itself
     */
    //[appUtil  enterApp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - coimotion delegate
/*
    get result of token validation
*/
- (void)coimConnection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    //  parse JSON to dictionary
    NSDictionary *checkTokenInfoDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
    if ([[_connection accessibilityLabel] isEqualToString:CHECK_TOKEN_CONNECTION_LABEL]) {
        //  valid token is not belongs to a guest
        if (![[[checkTokenInfoDic objectForKey:coimResParams.value] objectForKey:coimResParams.dspName] isEqual:@"Guest"]) {
            [appUtil  enterApp];
        }
        else {
            [appUtil enterLogin];
        }
    }
}

@end
