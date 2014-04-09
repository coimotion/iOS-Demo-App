//
//  TableListingViewController.m
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "RouteListViewController.h"

@interface RouteListViewController ()

@end

@implementation RouteListViewController
@synthesize tsIDs = _tsIDs;
@synthesize connection = _connection;
@synthesize routes = _routes;
@synthesize dataArray = _dataArray;
@synthesize stopIndex = _stopIndex;

#pragma mark - view control flows
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"路線清單";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //  initializing
    _dataArray = [NSMutableArray new];
    _routes = [NSMutableArray new];
    _stopIndex = 0;
    [self.tableView setBackgroundColor:[[UIColor alloc] initWithRed:239.0f/255.0f green:235.0f/255.0f blue:232.0f/255.0f alpha:1.0f]];
    [self.navigationController.navigationBar setBarTintColor:[[UIColor alloc] initWithRed:239.0f/255.0f green:235.0f/255.0f blue:232.0f/255.0f alpha:1.0f]];
    //  set bar on navigation item

    //  start search routes for tsIDs
    [self searchIthTSID:0];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.translucent = NO;
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
    return [_routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  setting cell style from xib
    static NSString *CellIdentifier = CELL_IDENTIFIER;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //  cell generated with UITableViewCellStyleSubtitle
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [_routes objectAtIndex:indexPath.row];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  enter Route list for stops around location
    NSLog(@"#dataArray: %d", [_dataArray count]);
    NSString *brID = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"brID"];
    RouteViewController *VC = [RouteViewController new];
    NSLog(@"brID: %@", brID);
    VC.brID = brID;
    [VC setTitle:[_routes objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:VC animated:YES];
}

#pragma mark - coimotion delegate

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
                              withData:(NSDictionary *)responseData
{
    /*
        modifying refresh controller
     */
    //NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //NSLog(@"data: %@", responseData);
    if ([[_connection accessibilityLabel] isEqualToString:@"routeSearch"]) {
        //if ([[searchInfo objectForKey:coimResParams.errCode] integerValue] == 0) {
            NSArray *list = [[responseData objectForKey:@"value"] objectForKey:@"list"];
            //NSLog(@"list length: %d", [list count]);
            //[_routes removeAllObjects];
            for (int i = 0; i <[list count]; i++) {
                
                if(![_routes containsObject:[list[i] objectForKey:@"rtName"]]) {
                    
                    
                    [_routes addObject:[list[i] objectForKey:@"rtName"]];
                    [_dataArray addObject:list[i]];
                    NSLog(@"%d rtName: %@, brID: %@",[_routes count], [list[i] objectForKey:@"rtName"], [[_dataArray objectAtIndex:[_dataArray count]-1] objectForKey:@"brID"]);
                }
            }
            NSLog(@"# routes: %d", [_routes count]);
            NSLog(@"# datas: %d", [_dataArray count]);
            [self.tableView reloadData];
            if(++_stopIndex < [_tsIDs count]) {
                [self searchIthTSID:_stopIndex];
            }
            else {
            }
        //}
    }
}

- (void)coimConnection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error
{
    NSLog(@"err: %@", [error localizedDescription]);
}

#pragma mark - subfunctions

- (void)searchIthTSID:(int)i
{
    //  create connection
    if(_connection != nil){
        //  if connection exists, cancel it and restart connection
        [_connection cancel];
        _connection = nil;
    }
    NSString *relativeURL = [NSString stringWithFormat:@"twCtBus/busStop/routes/%@", _tsIDs[i]];
    _connection = [coimSDK sendTo:relativeURL withParameter:nil delegate:self];
    [_connection setAccessibilityLabel:@"routeSearch"];
    
}


@end