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
@synthesize searchURL = _searchURL;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

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
    _searchURL = [[NSString alloc] initWithFormat:@"%@/%@/%@",coiBaseURL, coiAppCode, coiSearchURI];
    
    _dataArray = [[NSMutableArray alloc] init];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
    /*
        add pull to refresh
        with refreshingView function to trigger search
     */
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
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
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    [self.tableView setSeparatorColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f]];
    
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
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
    cell.textLabel.text = [_dataArray[indexPath.row] objectForKey:coiResParams.title];
    cell.textLabel.textColor = [UIColor whiteColor];
    //  setting subtitle of the row
    cell.detailTextLabel.text = [_dataArray[indexPath.row] valueForKey:coiResParams.addr];
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

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *) incomingData
{
    /*
        modifying refresh controller
     */
    
    //  stop refreshing state
    [[self refreshControl] endRefreshing];
    //  showing updated time on it
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];

    /*
        processing data recieved by different connections (telled by connection's accesibilityLabel
     */
    if ([[_connection accessibilityLabel] isEqualToString:SEARCH_CONNECTION_LABEL]) {
        //  parse JSON string data into a dictionary
        NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        //  successed get data (errCode is 0)
        if ([[searchInfo objectForKey:coiResParams.errCode] integerValue] == 0) {
            //  if data has token, renew the token
            if ([searchInfo objectForKey:coiResParams.token] != nil) {
                [[appUtil sharedUtil] setToken:[searchInfo objectForKey:coiResParams.token]];
                [[appUtil sharedUtil] saveObject:[searchInfo objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist];
            }
            //  renew _dataArray for TableView displaying
            [_dataArray removeAllObjects];
            NSArray *list = [[searchInfo objectForKey:coiResParams.value] objectForKey:coiResParams.list];
            for (int i = 0; i < [list count]; i++) {
                [_dataArray addObject:list[i]];
            }
            [self.tableView reloadData];
        }
        //  failed to get data (errCode is not 0)
        else {
            //  an alert window displays error message
            [[[UIAlertView alloc] initWithTitle:SEARCH_ERROR
                                        message:[searchInfo objectForKey:coiResParams.message]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            if ([[searchInfo objectForKey:coiResParams.errCode] intValue] == -2) {
                [[appUtil sharedUtil] logout];
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
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [_locationManager startUpdatingLocation];
}

- (void)searchList
{
    NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@&%@=%@", coiReqParams.lat, _latitude, coiReqParams.lng, _longitude, coiReqParams.token, [[appUtil sharedUtil] token]];
    NSURLRequest *searchReq = [[appUtil sharedUtil] getHttpRequestByMethod:coiMethodGet
                                                                     toURL:_searchURL
                                                                   useData:parameters];
    _connection = [[NSURLConnection alloc] initWithRequest:searchReq delegate:self];
    [_connection setAccessibilityLabel:SEARCH_CONNECTION_LABEL];
}

- (void)logout
{
    [[appUtil sharedUtil] logout];
}

@end