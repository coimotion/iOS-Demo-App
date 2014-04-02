//
//  ViewController.m
//  appTemplate
//
//  Created by Mac on 2014/3/28.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize dataArray = _dataArray;
@synthesize locationManager = _locationManager;
@synthesize connection = _connection;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize table = _table;
@synthesize pickerView = _pickerView;
@synthesize picker = _picker;
@synthesize dismissView = _dismissView;
@synthesize catID = _catID;
@synthesize catFlag = _catFlag;
@synthesize pickerValue = _pickerValue;
@synthesize titleLabel = _titleLabel;
@synthesize selectedPeriod = _selectedPeriod;
@synthesize myData = _myData;
@synthesize dic = _dic;
@synthesize catPickerValue = _catPickerValue;
@synthesize catIDArray = _catIDArray;
//NSArray *pickerValue;
//UILabel *titleLabel;
//int selectedPeriod;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
/*
 view life cycle
 viewDidLoad: initializing components of the view while loading the view
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    _catFlag = NO;
    _myData = [NSMutableData new];
    _pickerValue = [[NSArray alloc] initWithObjects:@"一週活動",  @"兩週活動",  @"三週活動", @"四週活動", nil];
    _catPickerValue = [[NSArray alloc] initWithObjects:@"音樂表演",  @"戲劇表演",  @"舞蹈表演", @"親子活動", @"展覽活動", @"講座", @"電影", @"演唱會", @"其它資訊", nil];
    _catIDArray = [[NSArray alloc] initWithObjects:@"1",  @"2",  @"3", @"4", @"6", @"7", @"8", @"17", @"15", nil];
    [_pickerView setHidden:YES];
    [_table registerNib:[UINib nibWithNibName:@"myCell" bundle:nil]
         forCellReuseIdentifier:@"coimCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _dic = [NSMutableDictionary new];
    
    _dataArray = [NSMutableArray new];
    
    self.navigationController.navigationBar.translucent = YES;
    /*
     set logout button on right of navigationBar
     */
    _selectedPeriod = 0;
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 44.0f)];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 60.0f)];
    [imgView setImage:[UIImage imageNamed:@"title_bg.png"]];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 140.0f, 44.0f)];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setText:@"一週活動"];
    [tmpView addSubview:imgView];
    [tmpView addSubview:_titleLabel];
    
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Trend"]];

    UITapGestureRecognizer *singleFingerTap1 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(datePicker)];
    UITapGestureRecognizer *singleFingerTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(dismissPicker)];
    [tmpView addGestureRecognizer:singleFingerTap1];
    [_dismissView addGestureRecognizer:singleFingerTap2];
    [self.navigationItem setTitleView:tmpView];
    
    /*
     set background image
     */
    //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    //_table.backgroundColor = background;
    [_table setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self searchListForCat:_catID andWeeks:_selectedPeriod];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:[_catPickerValue objectAtIndex:[_catIDArray indexOfObject:_catID]] style:UIBarButtonItemStylePlain target:self action:@selector(catPicker)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

/*
 TableViewController events
 numberOfRowsInSection: return # of sections of the table
 cellForRowAtIndexPath: return format of cell in section n of the table
 didSelectRowAtIndexPath: click on a row
 willDisplayCell: display content on the cell
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    myCell *cell = (myCell *)[tableView dequeueReusableCellWithIdentifier:@"coimCell"];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  generating a detailedView and passing data to it
    NSDictionary *data = _dataArray[indexPath.row];
    NSLog(@"data: %@", data);
    DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    detailedVC.data = data;
    [self.navigationController pushViewController:detailedVC animated:YES];
    [_table deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  setting title of a row
    
    myCell *mCell =((myCell *)cell);
    [mCell.label setTextColor:[UIColor blackColor]];
    mCell.label.text = [_dataArray[indexPath.row] objectForKey:coimResParams.title];
    [mCell.seconLabel setTextColor:[UIColor blackColor]];
    mCell.seconLabel.text =[_dataArray[indexPath.row] objectForKey:@"time"];
    if([[_dataArray[indexPath.row] objectForKey:@"imgURL"] isEqualToString:@""]) {
        UIImage *image = [UIImage imageNamed:@"img.png"];
        [mCell.image setImage:image];
    }
    else {
        [mCell.image setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_dataArray[indexPath.row] objectForKey:@"imgURL"]]]]];
    }
}

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finish loading:");
    NSLog(@"label: %@", [_connection accessibilityLabel]);
    NSError *err = nil;
    NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:_myData options:0 error:&err];
    if ([[_connection accessibilityLabel] isEqualToString:@"logout"]) {
        
        [appUtil enterLogin];
    }
    NSLog(@"ERR: %@", [err localizedDescription]);
    if ([[searchInfo objectForKey:coimResParams.errCode] integerValue] == 0) {
        //  renew _dataArray for TableView displaying
        [_dataArray removeAllObjects];
        NSArray *list = [[searchInfo objectForKey:coimResParams.value] objectForKey:coimResParams.list];
        NSMutableString *tmp = [NSMutableString new];
        for (int i = 0; i < [list count]; i++) {
            if (![[[list objectAtIndex:i] objectForKey:@"title"] isEqualToString:tmp]) {
                tmp = [[list objectAtIndex:i] objectForKey:@"title"];
                [_dataArray addObject:list[i]];
            }
        }
        [_table reloadData];
    }
    else {
        //  an alert window displays error message
        [[[UIAlertView alloc] initWithTitle:SEARCH_ERROR
                                    message:[searchInfo objectForKey:coimResParams.message]
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        if ([[searchInfo objectForKey:coimResParams.errCode] intValue] == -2) {
            [self logout];
        }
    }
}

/*
 NSURLConnection events
 didReceiveData: the connection recieves data, process the data to display
 */

- (void)coimConnection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [_myData appendData:data];
}

- (void)searchListForCat:(NSString *)catID andWeeks:(int)nWeek
{
    NSLog(@"search list: cat %@, nWeek: %d", catID, nWeek);
    NSDate *today = [NSDate new];
    NSDateFormatter *dFormater = [NSDateFormatter new];
    [dFormater setDateFormat:@"yyyy-MM-dd"];
    NSDate *endDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(nWeek+1) * (7 * 24 * 60 * 60)];
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                catID, @"cat",
                                (NSString *)[dFormater stringFromDate:today], @"fromTm",
                                (NSString *)[dFormater stringFromDate:endDate], @"toTm",
                                nil];
    if(_connection != nil) {
        [_connection cancel];
        _connection = nil;
        _myData = [NSMutableData new];
    }
    _connection = [coimSDK sendTo:@"twShow/show/byCity/15" withParameter:parameters delegate:self];
    
}

- (void) showLogoutAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"豋出"
                                                    message:@"確定要登出嗎？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"確定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //將按鈕的Title當作判斷的依據
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"確定"]) {
        [self logout];
    }
}

- (void)logout
{
    if(_connection != nil) {
        [_connection cancel];
        _connection = nil;
        _myData = [NSMutableData new];
    }
    _connection = [coimSDK logoutFrom:coimLogoutURI delegate:self];
    [_connection setAccessibilityLabel:@"logout"];
}

- (void)dismissPicker
{
    if(_pickerView.isHidden) {
        [_pickerView setHidden:NO];
        [self.navigationController setNavigationBarHidden:YES];
        
    }
    else {
        [_picker selectRow:_selectedPeriod inComponent:0 animated:YES];
        [_pickerView setHidden:YES];
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(_catFlag)
        return [_catPickerValue count];
    else
        return [_pickerValue count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSAttributedString *attString;
    if(_catFlag) {
        NSString *title = [_catPickerValue objectAtIndex:row];
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
    else {
        NSString *title = [_pickerValue objectAtIndex:row];
        attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
    return attString;
    
}

- (void)catPicker
{
    _catFlag = YES;
    
    [_picker selectRow:[_catIDArray indexOfObject:_catID] inComponent:0 animated:NO];
    [_picker reloadAllComponents];
    [self dismissPicker];
}

- (void)datePicker
{
    _catFlag = NO;

    [_picker selectRow:_selectedPeriod inComponent:0 animated:NO];
    [_picker reloadAllComponents];
    [self dismissPicker];
}

- (IBAction)check:(id)sender {
    if(_catFlag){
        if(_catID != [_catIDArray objectAtIndex:[_picker selectedRowInComponent:0]])
        {
            NSLog(@"check cat");
            _catID = [_catIDArray objectAtIndex:[_picker selectedRowInComponent:0]];
            [[[self navigationItem] rightBarButtonItem] setTitle:[_catPickerValue objectAtIndex:[_picker selectedRowInComponent:0]]];
            _titleLabel.text = [_pickerValue objectAtIndex:0];
            _myData = [NSMutableData new];
            _selectedPeriod = 0;
            [self searchListForCat:_catID andWeeks:0];
        }
        [self.navigationController setNavigationBarHidden:NO];
    }
    else {
        if (_selectedPeriod != [_picker selectedRowInComponent:0]) {
            NSLog(@"check");
            _selectedPeriod = [_picker selectedRowInComponent:0];
            _titleLabel.text = [_pickerValue objectAtIndex:_selectedPeriod];
            _myData = [NSMutableData new];
            [self searchListForCat:_catID andWeeks:_selectedPeriod];
        }
        [self.navigationController setNavigationBarHidden:NO];
    }
    [_pickerView setHidden: YES];
}

- (IBAction)cancel:(id)sender {
    
    [_picker selectRow:_selectedPeriod inComponent:0 animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
    [_pickerView setHidden:YES];
}

@end
