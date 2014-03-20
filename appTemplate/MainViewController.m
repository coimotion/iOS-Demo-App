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
@synthesize checkTokenURL = _checkTokenURL;

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
    //  get token from property list
    NSString *token = [[appUtil sharedUtil] readObjectForKey:coiResParams.token fromPlist:coiPlist];
    //  set to singleton object for using through whole app
    [[appUtil sharedUtil] setToken:token];
    //  prepare URL for API to check token's validility
    _checkTokenURL = [[NSString alloc] initWithFormat:@"%@/%@/%@", coiBaseURL, coiAppCode, coiCheckTokenURI];
    //  parameter to API
    NSString *param = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@",
                       coiReqParams.token, token,
                       coiReqParams.appKey, coiAppKey];
    //  get request object
    NSURLRequest *checkTokenReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodGet toURL:_checkTokenURL useData:param];
    //  create connection to validate token
    _connection = [[NSURLConnection alloc] initWithRequest:checkTokenReq delegate:self];
    [_connection setAccessibilityLabel:CHECK_TOKEN_CONNECTION_LABEL];
}

/*
    get result of token validation
 */

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    NSDictionary *checkTokenInfoDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
    if ([[_connection accessibilityLabel] isEqualToString:CHECK_TOKEN_CONNECTION_LABEL]) {
        //  parse JSON to dictionary
        
        //  valid token is not belongs to a guest
        if (![[[checkTokenInfoDic objectForKey:coiResParams.value] objectForKey:coiResParams.dspName] isEqual:@"Guest"]) {
            //  a new token is presented, set it to singleton object and property list
            if ([checkTokenInfoDic objectForKey:coiResParams.token] != nil) {
                [[appUtil sharedUtil] setToken:[checkTokenInfoDic objectForKey:coiResParams.token]];
                [[appUtil sharedUtil] saveObject:[checkTokenInfoDic objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist];
            }
            //  then enter app
            [[appUtil sharedUtil] enterApp];
        }
        else {
            // invalid token, open login view
            [[appUtil sharedUtil] logout];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
