//
//  MapListingViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/21.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "mapAnnotaion.h"
#import "RouteListViewController.h"

@interface MapListingViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (nonatomic, retain) NSMutableArray *annotaions;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableDictionary *data;
@property (nonatomic, retain) NSDictionary *targetDic;
@property (nonatomic, retain) NSMutableArray *stopRouteList;
@property (nonatomic, retain) UIBarButtonItem *rightButton;
@property (nonatomic, retain) MKAnnotationView *tmpAnnView;
@property int selected;
@end
