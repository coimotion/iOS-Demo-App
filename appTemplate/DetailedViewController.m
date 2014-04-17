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
@synthesize placeLabel = _placeLabel;
@synthesize addrLabel = _addrLabel;
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
@synthesize descScrollImage = _descScrollImage;
@synthesize priceScrollImage = _priceScrollImage;
@synthesize orgLabel = _orgLabel;
@synthesize srcInfoLabel = _srcInfoLabel;

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
    _selected = 0;
    [_saleText setBackgroundColor:[UIColor clearColor]];
    [_descText setBackgroundColor:[UIColor clearColor]];
    
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
}
#pragma mark - IBActions
/*
    open map to show location of activity
 */
- (IBAction)openMapView:(id)sender {
    MapListingViewController *mapView = [MapListingViewController new];
    mapView.data = _dic;
    [self.navigationController pushViewController:mapView animated:YES];
}
/*
    open browser to ticket site
 */
- (IBAction)buyTicket:(id)sender {
    [[UIApplication sharedApplication]openURL:[[NSURL alloc] initWithString:_saleURL]];
}
/*
    check the selection
 */
- (IBAction)check:(id)sender {
    [self showPicker];
    _selected = [_picker selectedRowInComponent:0];
    _dic = [_showInfos objectAtIndex:_selected];
    NSString *timeLabel = [_dic objectForKey:@"time"];
    timeLabel = [timeLabel stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    [_timeLabel setText: [NSString stringWithFormat:@"場次: %@", [timeLabel substringToIndex:[timeLabel length]-3]]];
    
    _placeLabel.text = [NSString stringWithFormat:@"地點：%@", [_dic objectForKey:@"placeName"]];
    _addrLabel.text = [NSString stringWithFormat:@"地址：%@", [_dic objectForKey:@"addr"]];
    
    NSString *price = ([[_dic objectForKey:@"priceInfo"] isEqualToString:@""])?@"N/A":[_dic objectForKey:@"priceInfo"];
    NSString *priceInfo = [NSString stringWithFormat:@"票價：\n%@", price];
    _saleText.text = priceInfo;
}
/*
    cancel the selection
 */
- (IBAction)cancel:(id)sender {
    [self showPicker];
    [_picker selectRow:_selected inComponent:0 animated:NO];
    NSDictionary *d = [_showInfos objectAtIndex:_selected];
    NSString *timeLabel = [d objectForKey:@"time"];
    timeLabel = [timeLabel stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    [_timeLabel setText: [NSString stringWithFormat:@"場次: %@", [timeLabel substringToIndex:[timeLabel length]-3]]];
    _placeLabel.text = [NSString stringWithFormat:@"地點：%@", [d objectForKey:@"placeName"]];
    _addrLabel.text = [NSString stringWithFormat:@"地址：%@", [d objectForKey:@"addr"]];
    
    NSString *price = ([[d objectForKey:@"priceInfo"] isEqualToString:@""])?@"N/A":[d objectForKey:@"priceInfo"];
    NSString *priceInfo = [NSString stringWithFormat:@"票價：\n%@", price];
    _saleText.text = priceInfo;
}
#pragma mark - subfunctions
/*
    Show picker
 */
-(void) showPicker
{
    if([_pickerView isHidden]) {
        [_pickerView setHidden: NO];
        [self.navigationController setNavigationBarHidden:YES];    // it hides
    }
    else {
        [_pickerView setHidden:YES];
        [self.navigationController setNavigationBarHidden:NO];    // it shows
    }
}

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

#pragma mark - picker delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *d = [_showInfos objectAtIndex:[_picker selectedRowInComponent:0]];
    
    NSString *price = ([[d objectForKey:@"priceInfo"] isEqualToString:@""])?@"N/A":[d objectForKey:@"priceInfo"];
    NSString *priceInfo = [NSString stringWithFormat:@"票價：\n%@", price];
    _saleText.text = priceInfo;
    
    NSString *timeLabel = [d objectForKey:@"time"];
    timeLabel = [timeLabel stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
    [_timeLabel setText: [NSString stringWithFormat:@"場次: %@", [timeLabel substringToIndex:[timeLabel length]-3]]];
    _placeLabel.text = [NSString stringWithFormat:@"地點：%@", [d objectForKey:@"placeName"]];
    _addrLabel.text = [NSString stringWithFormat:@"地址：%@", [d objectForKey:@"addr"]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_showInfos count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [[_showInfos objectAtIndex:row] objectForKey:@"time"];
    title = [title stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
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
    _showInfos = [[responseData objectForKey:@"value"] objectForKey:@"showInfo"];
    if ([[_connection accessibilityLabel] isEqualToString:DETAIL_CONNECTION_LABEL]) {
        [_picker reloadAllComponents];
        NSDictionary *showInfo = [_showInfos objectAtIndex:0];
        //  show right nav button if shows more than 1
        if([_showInfos count] > 1) {
            /*
             set logout button on right of navigationBar
             */
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"場次" style:UIBarButtonItemStylePlain target:self action:@selector(showPicker)];
            self.navigationItem.rightBarButtonItem = rightButton;
            
        }
        //  displaying information
        _placeLabel.text = [NSString stringWithFormat:@"地點：%@", [showInfo objectForKey:@"placeName"]];
        _addrLabel.text = [NSString stringWithFormat:@"地址：%@", [showInfo objectForKey:@"addr"]];
        _descText.text = ([[[responseData objectForKey:@"value"] objectForKey:@"descTx"] isEqualToString:@""])?@"未提供":[[responseData objectForKey:@"value"]  objectForKey:@"descTx"];
        
        NSString *infoSrc = ([[[responseData objectForKey:@"value"] objectForKey:@"infoSrc"] isEqualToString:@""])?@"N/A":[[responseData objectForKey:@"value"] objectForKey:@"infoSrc"];
        _srcInfoLabel.text = [NSString stringWithFormat:@"售票：%@", infoSrc];
        
        _orgLabel.text = [NSString stringWithFormat:@"主辦：%@", [[responseData objectForKey:@"value"] objectForKey:@"organizer"]];
        if([self textViewHeightForAttributedText:[_descText attributedText] andWidth:_descText.frame.size.width] > _descText.frame.size.height){
            [_descScrollImage setHidden:NO];
        }
        
        if([[showInfo objectForKey:@"isFree"] integerValue] == 0) {
            
            
            
            NSString *price = ([[showInfo objectForKey:@"priceInfo"] isEqualToString:@""])?@"N/A":[showInfo objectForKey:@"priceInfo"];
            NSString *priceInfo = [NSString stringWithFormat:@"票價：\n%@", price];
            _saleText.text = priceInfo;
            if([self textViewHeightForAttributedText:[_saleText attributedText] andWidth:_saleText.frame.size.width] > _saleText.frame.size.height){
                [_priceScrollImage setHidden:NO];
            }
            
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
        [_timeLabel setText:[NSString stringWithFormat:@"場次：%@", [timeLabel substringToIndex:[timeLabel length]-3]]];
        NSString *t1 = [[responseData objectForKey:@"value"] objectForKey:@"startDate"], *t2 = [[responseData objectForKey:@"value"] objectForKey:@"endDate"];
        t1 = [t1 stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        t2 = [t2 stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        _periodText.text = [NSString stringWithFormat:@"期間：%@ - %@", t1 , t2];
        _dic = [[NSMutableDictionary alloc]initWithDictionary:showInfo copyItems:YES];
    }
}
@end
