//
//  TableListingViewController.m
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "TableListingViewController.h"

@interface TableListingViewController ()

@end

@implementation TableListingViewController
@synthesize dataArray = _dataArray;
@synthesize locationManager = _locationManager;
@synthesize connection = _connection;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

NSMutableDictionary *dic;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = LIST_TITLE;
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
    dic = [NSMutableDictionary new];
    
    _dataArray = [NSMutableArray new];

    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
    
    /*
        add pull to refresh
        with refreshingView function to trigger search
     */
    UIRefreshControl *refresh = [UIRefreshControl new];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
    
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh!!" attributes:attributes];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
    
    [refresh setTintColor:[UIColor whiteColor]];
    [refresh addTarget:self action:@selector(refreshingView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    /*
        set logout button on right of navigationBar
     */
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RIGHT_BUTTON_TITLE_LIST style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    /*
        set background image
     */
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.tableView.backgroundColor = background;
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
    //  setting cell style from xib
    static NSString *CellIdentifier = CELL_IDENTIFIER;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {//  no defined cell, using dynamic generated cell
        //  cell generated with UITableViewCellStyleSubtitle
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  generating a detailedView and passing data to it
    NSDictionary *data = _dataArray[indexPath.row];
    DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    detailedVC.data = data;

    // check navigationController
    if (self.navigationController)
        //  push detailedView to navigationController
        [self.navigationController pushViewController:detailedVC animated:YES];
    else
        //  present a modal detailedView
        [self presentViewController:detailedVC animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  setting title of a row
    cell.textLabel.text = [_dataArray[indexPath.row] objectForKey:coimResParams.title];
    cell.textLabel.textColor = [UIColor whiteColor];
    //  setting subtitle of the row
    cell.detailTextLabel.text = [_dataArray[indexPath.row] valueForKey:coimResParams.addr];
    UIColor *color = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
    cell.detailTextLabel.textColor = color;
}

/*
    locationManager events
        didUpdateLocations: get locations of calling locationManage.startUpdatingLocation
            save current locatioin's latitude and longitude, then use searchList to get 
            information around
 */

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    _latitude = [[NSString alloc] initWithFormat:@"%f", ((CLLocation *)[locations objectAtIndex:0]).coordinate.latitude];
    _longitude = [[NSString alloc] initWithFormat:@"%f", ((CLLocation *)[locations objectAtIndex:0]).coordinate.longitude];
    [self searchList];
}

/*
    NSURLConnection events
        didReceiveData: the connection recieves data, process the data to display
 */

- (void)coimConnection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    /*
        modifying refresh controller
     */
    
    //  stop refreshing state
    [[self refreshControl] endRefreshing];
    //  showing updated time on it
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:lastUpdated attributes:attributes];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
    /*
        processing data recieved by different connections (telled by connection's accesibilityLabel
    */
    if ([[_connection accessibilityLabel] isEqualToString:SEARCH_CONNECTION_LABEL]) {
        //  parse JSON string data into a dictionary
        NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        //  successed get data (errCode is 0)
        if ([[searchInfo objectForKey:coimResParams.errCode] integerValue] == 0) {
            //  renew _dataArray for TableView displaying
            [_dataArray removeAllObjects];
            NSArray *list = [[searchInfo objectForKey:coimResParams.value] objectForKey:coimResParams.list];
            for (int i = 0; i < [list count]; i++) {
                [_dataArray addObject:list[i]];
            }
            [self.tableView reloadData];
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
}
/*
    sub functions
        refreshingView: renew current location
        searchList: query information around current location
        logout: logout
 */
- (void)refreshingView
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..." attributes:attributes];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
    [_locationManager startUpdatingLocation];
}

- (void)searchList
{
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                _latitude, coimReqParams.lat,
                                _longitude, coimReqParams.lng, nil];
    _connection = [ReqUtil sendTo:coimSearchURI withParameter:parameters delegate:self progressTable:dic];
    [_connection setAccessibilityLabel:SEARCH_CONNECTION_LABEL];
}

- (void)logout
{
    [ReqUtil logoutFrom:coimLogoutURI delegate:self progressTable:dic];
    [appUtil enterLogin];
}

@end