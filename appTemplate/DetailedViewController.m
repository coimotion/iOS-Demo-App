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
    self.title = [_data valueForKey:coiResParams.title];
    _detailURL = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", coiBaseURL, coiAppCode, coiDetailURI, [_data objectForKey:coiResParams.geID]];
    NSLog(@"url: %@", _detailURL);
    NSString *param = [[NSString alloc] initWithFormat:@"%@=%@&%@=1", coiReqParams.token, [[appUtil sharedUtil] token], coiReqParams.detail];
    NSURLRequest *cdetailReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodGet toURL:_detailURL useData:param];
    if (_connection) {
        [_connection cancel];
    }
    _connection = [[NSURLConnection alloc] initWithRequest:cdetailReq delegate:self];
    [_connection setAccessibilityLabel:DETAIL_CONNECTION_LABEL];
    // Do any additional setup after loading the view from its nib.
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] != 200) {
        [[[UIAlertView alloc] initWithTitle:SEARCH_ERROR
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
                int top, left, width, height, shift;
                top = 10;
                left = 10;
                width = self.view.frame.size.width - 20;
                height = 40;
                shift = height + 10;
                
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(top, left, width, height)];
                NSString *title = [[NSString alloc] init];
                title = [doc objectForKey:coiResParams.title] != nil ? [doc objectForKey:coiResParams.title] : @"N/A";
                titleLabel.text = title;
                
                UILabel *addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(left,top + shift, width, height)];
                addrLabel.text = [[detailInfoDic objectForKey:coiResParams.value] objectForKey:coiResParams.addr];
                
                UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(left,top + 2 * shift, width, height)];
                NSString *summary = [[NSString alloc] init];
                summary = [doc objectForKey:coiResParams.summary] != nil ? [doc objectForKey:coiResParams.summary] : @"N/A";
                telLabel.text = summary;
                
                [view addSubview:titleLabel];
                [view addSubview:addrLabel];
                [view addSubview:telLabel];
                [view setBackgroundColor:[UIColor whiteColor]];
                self.view = view;
            }
            else {
                
            }
        }
        else if (([[detailInfoDic objectForKey:coiResParams.errCode] integerValue] == -2)){
            [[[UIAlertView alloc] initWithTitle:LOGIN_ERROR
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
