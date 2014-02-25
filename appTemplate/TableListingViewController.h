//
//  TableListingViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DetailedViewController.h"

#define CELL_IDENTIFIER @"cell"
#define SEARCH_CONNECTION_LABEL @"searchConn"
#define LIST_TITLE @"列表顯示"
#define SEARCH_ERROR @"搜尋錯誤"

@interface TableListingViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (strong) NSMutableArray *dataArray;
@property (nonatomic,retain)CLLocationManager* locationManager;
@property (nonatomic, retain)NSURLConnection *connection;
@property (strong) NSString *searchURL;
@property (strong) NSString *latitude;
@property (strong) NSString *longitude;

@end
