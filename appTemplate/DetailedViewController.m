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

@synthesize saleText = _saleText;
@synthesize saleImg = _saleImg;
@synthesize locationText = _locationText;
@synthesize descText = _descText;
@synthesize data = _data;
@synthesize detailURL = _detailURL;
@synthesize docURL = _docURL;
@synthesize connection = _connection;
@synthesize showTitle = _showTitle;
@synthesize periodText = _periodText;
@synthesize pickerView = _pickerView;
@synthesize dismissPickerView = _dismissPickerView;
@synthesize picker = _picker;
@synthesize freeImg = _freeImg;
@synthesize timeLabel = _timeLabel;

NSMutableDictionary *dic;
NSString *saleURL;
NSArray *showInfos;
int selected;

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
    
    NSLog(@"data: %@", _data);
    selected = 0;
    //  init addrText component
    _locationText.layer.borderColor = [UIColor grayColor].CGColor;
    _locationText.layer.borderWidth = 1.0f;
    _locationText.layer.cornerRadius = 5.0f;
    
    //  init summaryText component
    _saleText.layer.borderColor = [UIColor grayColor].CGColor;
    _saleText.layer.borderWidth = 1.0f;
    _saleText.layer.cornerRadius = 5.0f;
    
    //  init bodyText component
    _descText.layer.borderColor = [UIColor grayColor].CGColor;
    _descText.layer.borderWidth = 1.0f;
    _descText.layer.cornerRadius = 5.0f;
    
    //  init bodyText component
    _periodText.layer.borderColor = [UIColor grayColor].CGColor;
    _periodText.layer.borderWidth = 1.0f;
    _periodText.layer.cornerRadius = 5.0f;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(showPicker)];
    [_dismissPickerView addGestureRecognizer:tap];
    [_pickerView setHidden:YES];
    //  set title of the view
    
    self.title = @"活動資訊";
    _showTitle.text = [_data valueForKey:coimResParams.title];
    //  prepare URL for detail info API
    _detailURL = [[NSString alloc] initWithFormat:@"twShow/show/info/%@", [_data objectForKey:@"spID"]];
    NSLog(@"detail url: %@", _detailURL);
    //  prepare parameter of detail info API
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", coimReqParams.detail, nil];
    
    //  create connection of the API
    _connection = [coimSDK sendTo:_detailURL withParameter:param delegate:self];
    [_connection setAccessibilityLabel:DETAIL_CONNECTION_LABEL];
}
/*
    receive data from connection
 */
- (void)coimConnection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    //  parse JSON string to a dictionary
    NSDictionary *detailInfoDic = [[NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil] objectForKey:@"value"];
    NSLog(@"data: %@", detailInfoDic);
    if ([[_connection accessibilityLabel] isEqualToString:DETAIL_CONNECTION_LABEL]) {
        //  process data from detail info connection
        if ([[detailInfoDic objectForKey:coimResParams.errCode] integerValue] == 0) {
            //  get data successed, check if detail info exists
            //  filled in addr
            showInfos =[detailInfoDic objectForKey:@"showInfo"];
            [_picker reloadAllComponents];
            NSLog(@"# showinfos %d",[showInfos count] );
            NSDictionary *showInfo = [showInfos objectAtIndex:0];
            if([showInfos count] > 1) {
                /*
                 set logout button on right of navigationBar
                 */
                UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"場次" style:UIBarButtonItemStylePlain target:self action:@selector(showPicker)];
                self.navigationItem.rightBarButtonItem = rightButton;

            }
            NSString *location = [NSString stringWithFormat:@"地點：%@\n地址：%@", [showInfo objectForKey:@"placeName"], [showInfo objectForKey:@"addr"]];
            _locationText.text = location;
            
            _descText.text = ([[detailInfoDic objectForKey:@"descTx"] isEqualToString:@""])?@"未提供":[detailInfoDic  objectForKey:@"descTx"];
            if([[showInfo objectForKey:@"isFree"] integerValue] == 0) {
                NSString *infoSrc = ([[detailInfoDic objectForKey:@"infoSrc"] isEqualToString:@""])?@"N/A":[detailInfoDic objectForKey:@"infoSrc"];
                NSString *price = ([[showInfo objectForKey:@"priceInfo"] isEqualToString:@""])?@"N/A":[showInfo objectForKey:@"priceInfo"];
                NSString *priceInfo = [NSString stringWithFormat:@"售票單位：%@\n票價：%@", infoSrc, price];
                _saleText.text = priceInfo;
                saleURL = [detailInfoDic objectForKey:@"saleURL"];
                if([saleURL isEqualToString:@""]) {
                    [_saleImg setHidden:YES];
                }
            }
            else {
                [_freeImg setHidden:NO];
                [_saleImg setHidden:YES];
                [_saleText setHidden:YES];
            }
            
            [_timeLabel setText:[showInfo objectForKey:@"time"]];
            
            NSString *periodStr = [NSString stringWithFormat:@"表演/展出期間： %@ - %@ ", [detailInfoDic objectForKey:@"startDate"], [detailInfoDic objectForKey:@"endDate"]];
            _periodText.text = periodStr;
            dic = [[NSMutableDictionary alloc]initWithDictionary:showInfo copyItems:YES];
        }
        else {
            //  failed to get data, alert a message
            [[[UIAlertView alloc] initWithTitle:DETAIL_ERROR
                                        message:[detailInfoDic objectForKey:coimResParams.message]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openMapView:(id)sender {
    MapListingViewController *mapView = [MapListingViewController new];
    mapView.data = dic;
    [self.navigationController pushViewController:mapView animated:YES];
}

- (IBAction)buyTicket:(id)sender {
    NSLog(@"open saleURL");
    [[UIApplication sharedApplication]openURL:[[NSURL alloc] initWithString:saleURL]];
}

- (IBAction)check:(id)sender {
    [self showPicker];
    selected = [_picker selectedRowInComponent:0];
    dic = [showInfos objectAtIndex:selected];
    [_timeLabel setText:[dic objectForKey:@"time"]];
    NSString *location = [NSString stringWithFormat:@"地點：%@\n地址：%@", [dic objectForKey:@"placeName"], [dic objectForKey:@"addr"]];
    _locationText.text = location;
}

- (IBAction)cancel:(id)sender {
    [self showPicker];
    [_picker selectRow:selected inComponent:0 animated:NO];
    NSDictionary *d = [showInfos objectAtIndex:selected];
    [_timeLabel setText:[d objectForKey:@"time"]];
    NSString *location = [NSString stringWithFormat:@"地點：%@\n地址：%@", [d objectForKey:@"placeName"], [d objectForKey:@"addr"]];
    _locationText.text = location;
}

-(void) showPicker
{
    NSLog(@"show picker, %d", [_pickerView isHidden]);
    if([_pickerView isHidden]) {
        [_pickerView setHidden: NO];
    }
    else {
        [_pickerView setHidden:YES];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //selected = [_picker selectedRowInComponent:0];
    NSDictionary *d = [showInfos objectAtIndex:[_picker selectedRowInComponent:0]];
    [_timeLabel setText:[d objectForKey:@"time"]];
    NSString *location = [NSString stringWithFormat:@"地點：%@\n地址：%@", [d objectForKey:@"placeName"], [d objectForKey:@"addr"]];
    _locationText.text = location;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"# rows in component %d", [showInfos count]);
    return [showInfos count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [[showInfos objectAtIndex:row] objectForKey:@"placeName"];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    return attString;
    
}

@end
