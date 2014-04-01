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

NSArray *pickerValue;
UILabel *titleLabel;
int selectedPeriod;
NSMutableData *myData;

NSMutableDictionary *dic;

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
    myData = [NSMutableData new];
    pickerValue = [[NSArray alloc] initWithObjects:@"一週活動",  @"兩週活動",  @"三週活動", @"四週活動", nil];
    [_pickerView setHidden:YES];
    [_table registerNib:[UINib nibWithNibName:@"myCell" bundle:nil]
         forCellReuseIdentifier:@"coimCell"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    dic = [NSMutableDictionary new];
    
    _dataArray = [NSMutableArray new];
    
    self.navigationController.navigationBar.translucent = YES;
    /*
     set logout button on right of navigationBar
     */
    selectedPeriod = 0;
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 44.0f)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:@"一週活動"];
    [tmpView addSubview:titleLabel];

    UITapGestureRecognizer *singleFingerTap1 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(dismissPicker)];
    UITapGestureRecognizer *singleFingerTap2 =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(dismissPicker)];
    [tmpView addGestureRecognizer:singleFingerTap1];
    [_dismissView addGestureRecognizer:singleFingerTap2];
    [self.navigationItem setTitleView:tmpView];
    
    /*
     set background image
     */
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    _table.backgroundColor = background;
    
    [self searchList];
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
    [mCell.label setTextColor:[UIColor whiteColor]];
    mCell.label.text = [_dataArray[indexPath.row] objectForKey:coimResParams.title];
    [mCell.seconLabel setTextColor:[UIColor whiteColor]];
    mCell.seconLabel.text =[_dataArray[indexPath.row] objectForKey:@"time"];
    UIImage *image = [UIImage imageNamed:@"def_image.png"];
    [mCell.image setImage:image];
    
}

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finish loading:");
    NSLog(@"myData: %@", [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding]);
    NSError *err = nil;
    NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:myData options:0 error:&err];
    
    NSLog(@"ERR: %@", [err localizedDescription]);
    if ([[searchInfo objectForKey:coimResParams.errCode] integerValue] == 0) {
        //  renew _dataArray for TableView displaying
        [_dataArray removeAllObjects];
        NSArray *list = [[searchInfo objectForKey:coimResParams.value] objectForKey:coimResParams.list];
        for (int i = 0; i < [list count]; i++) {
            [_dataArray addObject:list[i]];
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
    [myData appendData:data];
}

- (void)searchList
{
    NSLog(@"search list");
    NSDate *today = [NSDate new];
    NSDateFormatter *dFormater = [NSDateFormatter new];
    [dFormater setDateFormat:@"yyyy-MM-dd"];
    NSDate *endDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(1+ selectedPeriod) * (7 * 24 * 60 * 60)];
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"1", @"cat",
                                (NSString *)[dFormater stringFromDate:today], @"fromTm",
                                (NSString *)[dFormater stringFromDate:endDate], @"toTm",
                                nil];
    if(_connection != nil) {
        [_connection cancel];
        _connection = nil;
        myData = [NSMutableData new];
    }
    _connection = [coimSDK sendTo:@"twShow/show/byCity/15" withParameter:parameters delegate:self];
    
}

- (void)logout
{
    [coimSDK logoutFrom:coimLogoutURI delegate:self];
    [appUtil enterLogin];
}

- (void)dismissPicker
{
    if(_pickerView.isHidden) {
        [_pickerView setHidden:NO];
    }
    else {
        [_pickerView setHidden:YES];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerValue count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [pickerValue objectAtIndex:row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

- (IBAction)check:(id)sender {
    if (selectedPeriod != [_picker selectedRowInComponent:0]) {
        NSLog(@"check");
        selectedPeriod = [_picker selectedRowInComponent:0];
        titleLabel.text = [pickerValue objectAtIndex:selectedPeriod];
        myData = [NSMutableData new];
        [self searchList];
    }
    [_pickerView setHidden: YES];
}

- (IBAction)cancel:(id)sender {
    [_picker selectRow:selectedPeriod inComponent:0 animated:YES];
    [_pickerView setHidden:YES];
}
@end
