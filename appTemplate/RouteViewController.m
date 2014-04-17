//
//  RouteViewController.m
//  appTemplate
//
//  Created by Mac on 2014/4/2.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "RouteViewController.h"

@interface RouteViewController ()

@end

@implementation RouteViewController
@synthesize connection = _connection;
@synthesize brID = _brID;
@synthesize myData = _myData;
@synthesize dataArray = _dataArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *emptyRow = [[NSDictionary alloc] initWithObjectsAndKeys:@"資料讀取中",@"stName", nil];
    _dataArray = [NSMutableArray new];
    [_dataArray addObject:emptyRow];
    _myData = [NSMutableData new];
    [self searchBus];
    [self.tableView setBackgroundColor:[[UIColor alloc] initWithRed:239.0f/255.0f green:235.0f/255.0f blue:232.0f/255.0f alpha:1.0f]];
    [self.navigationController.navigationBar setBarTintColor: [[UIColor alloc] initWithRed:239.0f/255.0f green:235.0f/255.0f blue:232.0f/255.0f alpha:1.0f]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"rCell" bundle:nil] forCellReuseIdentifier:@"rCell"];
    
    /*
     add pull to refresh
     with refreshingView function to trigger search
    */
    UIRefreshControl *refresh = [UIRefreshControl new];
     
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
     
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh!!" attributes:attributes];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
     
    [refresh setTintColor:[UIColor redColor]];
    
    [refresh addTarget:self action:@selector(refreshingView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
     
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
    // Dispose of any resources that can be recreated.
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    rCell *rcell = (rCell *)cell;
    
    if([[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"isInBd"] integerValue] == 0){
        [rcell.icon setImage:[UIImage imageNamed:@"go.png"]];
        
        rcell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"bg_pink.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        
    }
    else {
        [rcell.icon setImage:[UIImage imageNamed:@"back.png"]];
        rcell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"bg_green.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    }
    rcell.stopLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"stName"];
    rcell.timeLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"arvTime"];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"rCell";
    rCell *cell = (rCell *)[tableView dequeueReusableCellWithIdentifier:@"rCell"];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)searchBus
{
    [[self refreshControl] endRefreshing];
    _myData = [NSMutableData new];
    if(_connection != nil){
        //  if connection exists, cancel it and restart connection
        [_connection cancel];
        _connection = nil;
    }
    NSString *relativeURL = [NSString stringWithFormat:@"twCtBus/busRoute/next/%@", _brID];
    _connection = [coimSDK sendTo:relativeURL withParameter:nil delegate:self];
    [_connection setAccessibilityLabel:@"routeSearch"];
}

#pragma mark - coimotion delegate
- (void)coimConnection:(NSURLConnection *)conn didFailWithError:(NSError *)err
{
    NSLog(@"err: %@", err);
}

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection withData:(NSDictionary *)responseData
{
    NSLog(@"finish");
    [[self refreshControl] endRefreshing];
    if([[responseData objectForKey:@"errCode"] integerValue] == 0) {
        _dataArray = [[responseData objectForKey:@"value"] objectForKey:@"list"];
        [[self tableView] reloadData];
        
    }
}

#pragma mark - subfunctions

- (void)refreshingView
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..." attributes:attributes];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
    [self searchBus];
}
@end
