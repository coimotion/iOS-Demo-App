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

@interface TableListingViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (nonatomic,retain)CLLocationManager* locationManager;
@property (nonatomic, retain)NSURLConnection *connection;
@property (strong, nonatomic) NSString *searchURL;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@end
