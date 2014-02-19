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
@property (strong) NSArray *roleArray;
@property (strong) NSString *passString;
@property (nonatomic,retain)CLLocationManager* locationManager;
@end
