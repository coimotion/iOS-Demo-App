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
        NSString *title = [[NSString alloc] initWithFormat:@"%@, %@",[_dataArray[indexPath.row] valueForKey:coiResParams.title], [_dataArray[indexPath.row] valueForKey:coiResParams.summary]];
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    NSString *lat = [[NSString alloc] initWithFormat:@"%f", ((CLLocation *)[locations objectAtIndex:0]).coordinate.latitude];
    NSString *lng = [[NSString alloc] initWithFormat:@"%f", ((CLLocation *)[locations objectAtIndex:0]).coordinate.longitude];
    [self searchAtLat:lat Lng:lng];
}

- (void)searchAtLat:(NSString *)lat Lng:(NSString *)lng
{
    NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@&%@=%@", coiReqParams.lat, lat, coiReqParams.lng, lng, coiReqParams.token, [[appUtil sharedUtil] token]];
    NSURLRequest *searchReq = [[appUtil sharedUtil] getHttpConnectionByMethod:coiMethodGet
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

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
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
/*
- (void)getContent
{
    {//7745-7744
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"鹽埕店" forKey:@"branch"];
        [dic setObject:@"高雄市鹽埕區七賢三路138號" forKey:@"addr"];
        [dic setObject:@"07-5218988" forKey:@"tel"];
        [dic setObject:@"22.626295" forKey:@"lat"];
        [dic setObject:@"120.282424" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7747-7746
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"臨海店" forKey:@"branch"];
        [dic setObject:@"高雄市鼓山區臨海二路41號" forKey:@"addr"];
        [dic setObject:@"07-5512998" forKey:@"tel"];
        [dic setObject:@"22.623241" forKey:@"lat"];
        [dic setObject:@"120.272051" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7748-7764
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"苓雅店" forKey:@"branch"];
        [dic setObject:@"高雄市苓雅區苓雅二路72號" forKey:@"addr"];
        [dic setObject:@"07-3384515" forKey:@"tel"];
        [dic setObject:@"22.618131" forKey:@"lat"];
        [dic setObject:@"120.299968" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7749-7763
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"青年店" forKey:@"branch"];
        [dic setObject:@"高雄市苓雅區青年一路1792號" forKey:@"addr"];
        [dic setObject:@"07-5376229" forKey:@"tel"];
        [dic setObject:@"22.621657" forKey:@"lat"];
        [dic setObject:@"120.307256" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7750-7762
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"2" forKey:@"id"];
        [dic setObject:@"南傳鮮奶" forKey:@"name"];
        [dic setObject:@"建工店" forKey:@"branch"];
        [dic setObject:@"高雄市三民區建工路522號" forKey:@"addr"];
        [dic setObject:@"07-3858595" forKey:@"tel"];
        [dic setObject:@"22.65101" forKey:@"lat"];
        [dic setObject:@"120.326034" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7752-7757
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"2" forKey:@"id"];
        [dic setObject:@"南傳鮮奶" forKey:@"name"];
        [dic setObject:@"復興店" forKey:@"branch"];
        [dic setObject:@"高雄市前鎮區復興三路152號" forKey:@"addr"];
        [dic setObject:@"07-3343611" forKey:@"tel"];
        [dic setObject:@"22.612281" forKey:@"lat"];
        [dic setObject:@"120.311305" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7753-7758
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"2" forKey:@"id"];
        [dic setObject:@"南傳鮮奶" forKey:@"name"];
        [dic setObject:@"西子灣店" forKey:@"branch"];
        [dic setObject:@"高雄市鼓山區臨海二路34號" forKey:@"addr"];
        [dic setObject:@"07-5310900" forKey:@"tel"];
        [dic setObject:@"22.623122" forKey:@"lat"];
        [dic setObject:@"120.272403" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7754-7761
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"3" forKey:@"id"];
        [dic setObject:@"鮮茶道" forKey:@"name"];
        [dic setObject:@"鹽埕七賢店" forKey:@"branch"];
        [dic setObject:@"高雄市鹽埕區七賢三路130號" forKey:@"addr"];
        [dic setObject:@"07-5316718" forKey:@"tel"];
        [dic setObject:@"22.626306" forKey:@"lat"];
        [dic setObject:@"120.282418" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7755-7760
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"3" forKey:@"id"];
        [dic setObject:@"鮮茶道" forKey:@"name"];
        [dic setObject:@"高雄鼎山店" forKey:@"branch"];
        [dic setObject:@"高雄市三民區鼎山街555號" forKey:@"addr"];
        [dic setObject:@"07-3945736" forKey:@"tel"];
        [dic setObject:@"22.651908" forKey:@"lat"];
        [dic setObject:@"120.318245" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {//7756-7759
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"3" forKey:@"id"];
        [dic setObject:@"鮮茶道" forKey:@"name"];
        [dic setObject:@"高雄西子灣店" forKey:@"branch"];
        [dic setObject:@"高雄市鼓山區臨海二路47號" forKey:@"addr"];
        [dic setObject:@"07-5336018" forKey:@"tel"];
        [dic setObject:@"22.623018" forKey:@"lat"];
        [dic setObject:@"120.271809" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    [self.tableView reloadData];
}
*/
@end
