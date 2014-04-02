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

int stopIndex;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"站牌清單";
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
    _dataArray = [NSMutableArray new];
    _routes = [NSMutableArray new];
    NSLog(@"# stops: %d", [_tsIDs count]);
    stopIndex = 0;
    [self searchIthTSID:0];
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]]];
    /*
        add pull to refresh
        with refreshingView function to trigger search
     
    UIRefreshControl *refresh = [UIRefreshControl new];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
    
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh!!" attributes:attributes];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
    
    [refresh setTintColor:[UIColor whiteColor]];
    [refresh addTarget:self action:@selector(refreshingView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    */
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
    return [_routes count];
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
        cell.textLabel.text = [_routes objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //  generating a detailedView and passing data to it
    NSString *brID = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"brID"];
    NSLog(@"brID: %@", brID);
    RouteViewController *VC = [RouteViewController new];
    VC.brID = brID;
    [VC setTitle:[_routes objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:VC animated:YES];
    //[self.navigationController pushViewController:detailedVC animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = _routes[indexPath.row];
}

/*
    NSURLConnection events
        didReceiveData: the connection recieves data, process the data to display
*/

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

- (void)coimConnection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    /*
        modifying refresh controller
     */
    NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"data: %@", searchInfo);
    if ([[_connection accessibilityLabel] isEqualToString:@"routeSearch"]) {
        if ([[searchInfo objectForKey:coimResParams.errCode] integerValue] == 0) {
            NSArray *list = [[searchInfo objectForKey:@"value"] objectForKey:@"list"];
            NSLog(@"list length: %d", [list count]);
            for (int i = 0; i <[list count]; i++) {
                NSLog(@"%d rtName: %@",i, [list[i] objectForKey:@"rtName"]
                      );
                NSLog(@"%d", [_routes containsObject:[list[i] objectForKey:@"rtName"]]);
                if(![_routes containsObject:[list[i] objectForKey:@"rtName"]]) {
                    [_routes addObject:[list[i] objectForKey:@"rtName"]];
                    [_dataArray addObject:list[i]];
                }
            }
            NSLog(@"# routes: %d", [_routes count]);
            NSLog(@"# datas: %d", [_dataArray count]);
            [self.tableView reloadData];
            if(++stopIndex < [_tsIDs count]) {
                [self searchIthTSID:stopIndex];
            }
        }
        else {
        }
    }
}

@end