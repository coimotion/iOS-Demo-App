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
        NSString *token = [[appUtil sharedUtil] readObjectForKey:coiResParams.token fromPlist:coiPlist];
        [[appUtil sharedUtil] setToken:token];
        NSLog(@"read token: %@", token);
        _checkTokenURL = [[NSString alloc] initWithFormat:@"%@/%@/%@", coiBaseURL, coiAppCode, coiCheckTokenURI];
        NSString *param = [[NSString alloc] initWithFormat:@"%@=%@", coiReqParams.token, token];
        NSURLRequest *checkTokenReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodGet toURL:_checkTokenURL useData:param];
        if (!_connection) {
            _connection = [[NSURLConnection alloc] initWithRequest:checkTokenReq delegate:self];
        }
        else {
            [_connection cancel];
            _connection = [[NSURLConnection alloc] initWithRequest:checkTokenReq delegate:self];
        }
        [_connection setAccessibilityLabel:CHECK_TOKEN_CONNECTION_LABEL];
    }
    return self;
}

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    if ([[_connection accessibilityLabel] isEqualToString:CHECK_TOKEN_CONNECTION_LABEL]) {
        NSDictionary *checkTokenInfoDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        if (![[[checkTokenInfoDic objectForKey:coiResParams.value] objectForKey:coiResParams.dspName] isEqual:@"Guest"]) {
            if ([checkTokenInfoDic objectForKey:coiResParams.token] != nil) {
                [[appUtil sharedUtil] setToken:[checkTokenInfoDic objectForKey:coiResParams.token]];
                [[appUtil sharedUtil] saveObject:[checkTokenInfoDic objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist];
            }
            [[appUtil sharedUtil] enterApp];
            /*TableListingViewController *tableListVC = [[TableListingViewController alloc] init];
            UINavigationController *naviVC1 = [[UINavigationController alloc] initWithRootViewController:tableListVC];
            MapListingViewController *mapListVC = [[MapListingViewController alloc] init];
            UINavigationController *naviVC2 = [[UINavigationController alloc] initWithRootViewController:mapListVC];
            UITabBarController *tbc = [[UITabBarController alloc] init];
            [tbc setViewControllers:[[NSArray alloc] initWithObjects:naviVC1, naviVC2, nil]];
            [[appUtil sharedUtil] setRootWindowView:tbc];*/
        }
        else {
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
