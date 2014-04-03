//
//  TableListingViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RouteViewController.h"

@interface RouteListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic)NSURLConnection *connection;
@property (strong, nonatomic)NSMutableArray *tsIDs;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (strong, nonatomic)NSMutableArray *routes;
@property int stopIndex;
@end
