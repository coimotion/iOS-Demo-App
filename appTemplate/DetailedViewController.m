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
@synthesize dic = _dic;
@synthesize saleURL = _saleURL;
@synthesize showInfos = _showInfos;
@synthesize selected = _selected;

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
    
    NSLog(@"data: %@", _data);
    _selected = 0;
    /*
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
    */
    [_locationText setBackgroundColor:[UIColor clearColor]];
    [_saleText setBackgroundColor:[UIColor clearColor]];
    [_descText setBackgroundColor:[UIColor clearColor]];
    [_periodText setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(showPicker)];
    [_dismissPickerView addGestureRecognizer:tap];
    [_pickerView setHidden:YES];
    //  set title of the view
    [self setTitle:@"活動資訊"];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"=======memory warning=========");
}
#pragma mark - IBActions
- (IBAction)openMapView:(id)sender {
    MapListingViewController *mapView = [MapListingViewController new];
    mapView.data = _dic;
    [self.navigationController pushViewController:mapView animated:YES];
}

- (IBAction)buyTicket:(id)sender {
    NSLog(@"open saleURL");
    [[UIApplication sharedApplication]openURL:[[NSURL alloc] initWithString:_saleURL]];
}

- (IBAction)check:(id)sender {
    [self showPicker];
    _selected = [_picker selectedRowInComponent:0];
    _dic = [_showInfos objectAtIndex:_selected];
    NSString *timeLabel = [_dic objectForKey:@"time"];
    timeLabel = [timeLabel stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    [_timeLabel setText: [NSString stringWithFormat:@"場次: %@", [timeLabel substringToIndex:[timeLabel length]-3]]];
    NSString *location = [NSString stringWithFormat:@"地點：%@\n地址：%@", [_dic objectForKey:@"placeName"], [_dic objectForKey:@"addr"]];
    _locationText.text = location;
}

- (IBAction)cancel:(id)sender {
    [self showPicker];
    [_picker selectRow:_selected inComponent:0 animated:NO];
    NSDictionary *d = [_showInfos objectAtIndex:_selected];
    NSString *timeLabel = [d objectForKey:@"time"];
    timeLabel = [timeLabel stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    [_timeLabel setText: [NSString stringWithFormat:@"場次: %@", [timeLabel substringToIndex:[timeLabel length]-3]]];
    NSString *location = [NSString stringWithFormat:@"地點：%@\n地址：%@", [d objectForKey:@"placeName"], [d objectForKey:@"addr"]];
    _locationText.text = location;
}
#pragma mark - subfunctions
-(void) showPicker
{
    NSLog(@"show picker, %d", [_pickerView isHidden]);
    if([_pickerView isHidden]) {
        [_pickerView setHidden: NO];
        [self.navigationController setNavigationBarHidden:YES];    // it hides
    }
    else {
        [_pickerView setHidden:YES];
        [self.navigationController setNavigationBarHidden:NO];    // it shows
    }
}

#pragma mark - picker delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //selected = [_picker selectedRowInComponent:0];
    NSDictionary *d = [_showInfos objectAtIndex:[_picker selectedRowInComponent:0]];
    NSString *timeLabel = [d objectForKey:@"time"];
    timeLabel = [timeLabel stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
    [_timeLabel setText: [NSString stringWithFormat:@"場次: %@", [timeLabel substringToIndex:[timeLabel length]-3]]];
    NSString *location = [NSString stringWithFormat:@"地點：%@\n地址：%@", [d objectForKey:@"placeName"], [d objectForKey:@"addr"]];
    _locationText.text = location;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"# rows in component %d", [_showInfos count]);
    return [_showInfos count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [[_showInfos objectAtIndex:row] objectForKey:@"time"];
    title = [title stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    //[title substringToIndex:([title length]-3)];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[title substringToIndex:([title length]-3)] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    return attString;
    
}
#pragma mark - coimotion delegate

- (void)coimConnection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error
{
    NSLog(@"!!!!error: %@!!!", [error localizedDescription]);
}

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
                              withData:(NSDictionary *)responseData
{
    NSLog(@"response Data: %@", responseData);
    _showInfos = [[responseData objectForKey:@"value"] objectForKey:@"showInfo"];
    if ([[_connection accessibilityLabel] isEqualToString:DETAIL_CONNECTION_LABEL]) {
        [_picker reloadAllComponents];
        NSLog(@"# showinfos %d",[_showInfos count] );
        NSDictionary *showInfo = [_showInfos objectAtIndex:0];
        if([_showInfos count] > 1) {
            /*
             set logout button on right of navigationBar
             */
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"場次" style:UIBarButtonItemStylePlain target:self action:@selector(showPicker)];
            self.navigationItem.rightBarButtonItem = rightButton;
            
        }
        _locationText.text = [NSString stringWithFormat:@"地點：%@\n地址：%@", [showInfo objectForKey:@"placeName"], [showInfo objectForKey:@"addr"]];
        _descText.text = ([[[responseData objectForKey:@"value"] objectForKey:@"descTx"] isEqualToString:@""])?@"未提供":[[responseData objectForKey:@"value"]  objectForKey:@"descTx"];

        if([[showInfo objectForKey:@"isFree"] integerValue] == 0) {
            NSString *infoSrc = ([[[responseData objectForKey:@"value"] objectForKey:@"infoSrc"] isEqualToString:@""])?@"N/A":[[responseData objectForKey:@"value"] objectForKey:@"infoSrc"];
            NSString *price = ([[showInfo objectForKey:@"priceInfo"] isEqualToString:@""])?@"N/A":[showInfo objectForKey:@"priceInfo"];
            NSString *priceInfo = [NSString stringWithFormat:@"售票單位：%@\n票價：%@", infoSrc, price];
            _saleText.text = priceInfo;
            _saleURL = [[responseData objectForKey:@"value"] objectForKey:@"saleURL"];
            if([_saleURL isEqualToString:@""]) {
                [_saleImg setHidden:YES];
            }
        }
        else {
            [_freeImg setHidden:NO];
            [_saleImg setHidden:YES];
            [_saleText setHidden:YES];
        }
        NSString *timeLabel = [[showInfo objectForKey:@"time"] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        NSLog(@"time: %@", timeLabel);
        [_timeLabel setText:[NSString stringWithFormat:@"場次: %@", [timeLabel substringToIndex:[timeLabel length]-3]]];
        NSString *t1 = [[responseData objectForKey:@"value"] objectForKey:@"startDate"], *t2 = [[responseData objectForKey:@"value"] objectForKey:@"endDate"];
        t1 = [t1 stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        t2 = [t2 stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        _periodText.text = [NSString stringWithFormat:@"表演/展出期間： %@ - %@ ", t1 , t2];
        _dic = [[NSMutableDictionary alloc]initWithDictionary:showInfo copyItems:YES];
        
        //}
    }
}
@end
