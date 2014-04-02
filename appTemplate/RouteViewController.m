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
//NSMutableArray *dataArray;
//NSMutableData *myData;
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
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]]];
    [self searchBus];
    
    /*
     add pull to refresh
     with refreshingView function to trigger search
    */
    UIRefreshControl *refresh = [UIRefreshControl new];
     
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
     
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh!!" attributes:attributes];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
     
    [refresh setTintColor:[UIColor redColor]];
    [refresh addTarget:self action:@selector(refreshingView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
     
}

- (void)refreshingView
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];  //title text color :optional
    NSAttributedString *aTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..." attributes:attributes];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:aTitle];
    [self searchBus];
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
    cell.textLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"stName"];
    cell.detailTextLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"arvTime"];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        [[cell textLabel] setTextColor:[UIColor blackColor]];
        [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    // Configure the cell...
    
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
    NSLog(@"URL: %@", relativeURL);
    _connection = [coimSDK sendTo:relativeURL withParameter:nil delegate:self];
    [_connection setAccessibilityLabel:@"routeSearch"];
}

- (void)coimConnection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    if(data != nil){
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [_myData appendData:data];
    }
    else {
        [conn cancel];
    }
    
}

- (void)coimConnection:(NSURLConnection *)conn didFailWithError:(NSError *)err
{
    NSLog(@"err: %@", err);
}

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_myData options:0 error:&err];
    NSLog(@"finish data: %@", dic);
    NSLog(@"finish err: %@", err);
    [[self refreshControl] endRefreshing];
    if([[dic objectForKey:@"errCode"] integerValue] == 0) {

        //[_dataArray removeAllObjects];
        _dataArray = [[dic objectForKey:@"value"] objectForKey:@"list"];
        [[self tableView] reloadData];
        
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
