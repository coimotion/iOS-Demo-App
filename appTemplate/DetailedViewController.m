//
//  DetailedViewController.m
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "DetailedViewController.h"

@interface DetailedViewController ()

@end

@implementation DetailedViewController

@synthesize summaryText = _summaryText;
@synthesize addrText = _addrText;
@synthesize bodyText = _bodyText;
@synthesize data = _data;
@synthesize detailURL = _detailURL;
@synthesize connection = _connection;

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
    
    _addrText.layer.borderColor = [UIColor grayColor].CGColor;
    _addrText.layer.borderWidth = 1.0f;
    _addrText.layer.cornerRadius = 5.0f;
    
    _summaryText.layer.borderColor = [UIColor grayColor].CGColor;
    _summaryText.layer.borderWidth = 1.0f;
    _summaryText.layer.cornerRadius = 5.0f;
    
    _bodyText.layer.borderColor = [UIColor grayColor].CGColor;
    _bodyText.layer.borderWidth = 1.0f;
    _bodyText.layer.cornerRadius = 5.0f;
    
    self.title = [_data valueForKey:coiResParams.title];
    
    _detailURL = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", coiBaseURL, coiAppCode, coiDetailURI, [_data objectForKey:coiResParams.geID]];
    NSString *param = [[NSString alloc] initWithFormat:@"%@=%@&%@=1", coiReqParams.token, [[appUtil sharedUtil] token], coiReqParams.detail];
    NSURLRequest *cdetailReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodGet toURL:_detailURL useData:param];
    _connection = [[NSURLConnection alloc] initWithRequest:cdetailReq delegate:self];
    [_connection setAccessibilityLabel:DETAIL_CONNECTION_LABEL];
    // Do any additional setup after loading the view from its nib.
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] != 200) {
        [[[UIAlertView alloc] initWithTitle:DETAIL_ERROR
                                    message:[[NSString alloc] initWithFormat:@"%d",[httpResponse statusCode]]
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    if ([[_connection accessibilityLabel] isEqualToString:DETAIL_CONNECTION_LABEL]) {
        NSDictionary *detailInfoDic = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        if ([[detailInfoDic objectForKey:coiResParams.errCode] integerValue] == 0) {
            NSDictionary *doc = [[detailInfoDic objectForKey:coiResParams.value] objectForKey:coiResParams.doc];
            if (doc != nil) {
                _addrText.text = [[detailInfoDic objectForKey:coiResParams.value] objectForKey:coiResParams.addr];
                
                _summaryText.text = [doc objectForKey:coiResParams.summary] != nil ? [doc objectForKey:coiResParams.summary] : @"N/A";
                
                _bodyText.text = [doc objectForKey:coiResParams.body] != nil ? [doc objectForKey:coiResParams.body] : @"N/A";
            }
            else {
                [[[UIAlertView alloc] initWithTitle:DETAIL_ERROR
                                            message:@"No detailed information!"
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }
        }
        else if (([[detailInfoDic objectForKey:coiResParams.errCode] integerValue] == -2)){
            [[[UIAlertView alloc] initWithTitle:DETAIL_ERROR
                                        message:[detailInfoDic objectForKey:coiResParams.message]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
        else {
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
