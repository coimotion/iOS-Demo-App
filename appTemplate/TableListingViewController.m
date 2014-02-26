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
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(refreshingView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    //UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RIGHT_BUTTON_TITLE_LIST style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    //self.navigationItem.rightBarButtonItem = rightButton;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_IDENTIFIER;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        NSString *title = [[NSString alloc] initWithFormat:@"%@",[_dataArray[indexPath.row] valueForKey:coiResParams.title]];
        cell.textLabel.text = title;
        cell.detailTextLabel.text = [_dataArray[indexPath.row] valueForKey:coiResParams.addr];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = _dataArray[indexPath.row];
    DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    detailedVC.data = data;

    if (self.navigationController)
        [self.navigationController pushViewController:detailedVC animated:YES];
    else
        [self presentViewController:detailedVC animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [_dataArray[indexPath.row] objectForKey:coiResParams.title];
    cell.detailTextLabel.text = [_dataArray[indexPath.row] valueForKey:coiResParams.addr];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    _latitude = [[NSString alloc] initWithFormat:@"%f", ((CLLocation *)[locations objectAtIndex:0]).coordinate.latitude];
    _longitude = [[NSString alloc] initWithFormat:@"%f", ((CLLocation *)[locations objectAtIndex:0]).coordinate.longitude];
    [self searchList];
}

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
    if (!_connection) {
        _connection = [[NSURLConnection alloc] initWithRequest:searchReq delegate:self];
    }
    else {
        [_connection cancel];
        _connection = [[NSURLConnection alloc] initWithRequest:searchReq delegate:self];
    }
    [_connection setAccessibilityLabel:SEARCH_CONNECTION_LABEL];
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

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *) incomingData
{
    [[self refreshControl] endRefreshing];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    if ([[_connection accessibilityLabel] isEqualToString:SEARCH_CONNECTION_LABEL]) {
        NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        if ([[searchInfo objectForKey:coiResParams.errCode] integerValue] == 0) {
            if ([searchInfo objectForKey:coiResParams.token] != nil) {
                [[appUtil sharedUtil] setToken:[searchInfo objectForKey:coiResParams.token]];
                [[appUtil sharedUtil] saveObject:[searchInfo objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist];
            }
            [_dataArray removeAllObjects];
            NSArray *list = [[searchInfo objectForKey:coiResParams.value] objectForKey:coiResParams.list];
            for (int i = 0; i < [list count]; i++) {
                [_dataArray addObject:list[i]];
            }
            [self.tableView reloadData];
        }
        else {
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

- (void)logout
{
    [[appUtil sharedUtil] logout];
}

@end