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
#import "DetailedViewController.h"
#import "LoginViewController.h"

@interface MapListingViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (nonatomic,retain)CLLocationManager* locationManager;
@property (nonatomic, retain)NSMutableArray *annotaions;
@property (nonatomic, retain)NSURLConnection *connection;
@property (strong, nonatomic) NSString *searchURL;
@property int index;
@end
