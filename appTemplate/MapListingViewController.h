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

@interface MapListingViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong) NSMutableArray *roleArray;
@property (nonatomic,retain)CLLocationManager* locationManager;
@property int index;
@end
