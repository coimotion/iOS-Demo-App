//
//  RouteViewController.h
//  appTemplate
//
//  Created by Mac on 2014/4/2.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteViewController : UITableViewController
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSString *brID;
@property (strong, nonatomic) NSMutableData *myData;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end
