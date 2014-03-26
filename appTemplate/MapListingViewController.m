//
//  MapListingViewController.m
//  appTemplate
//
//  Created by Mac on 14/2/21.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "MapListingViewController.h"

@interface MapListingViewController ()

@end

@implementation MapListingViewController
@synthesize dataArray = _dataArray;
@synthesize annotaions = _annotaions;
@synthesize locationManager = _locationManager;
@synthesize mapView = _mapView;
@synthesize connection = _connection;
@synthesize index;

NSMutableDictionary *dic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = MAP_TITLE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dic = [NSMutableDictionary new];
    
    //  init dataArray to store searched results
    _dataArray = [NSMutableArray new];
    
    //  init location manager's setting
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    
    //  start updating location
    [_locationManager startUpdatingLocation];
    
    //  create a button to logout
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RIGHT_BUTTON_TITLE_MAP style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    //  set the button as rightBarButton
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //  create a button to go back current location, and set as leftBarButton
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:LEFT_BUTTON_TITLE_MAP style:UIBarButtonItemStylePlain target:self action:@selector(currentLocation)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
/*
    locationManager event
        didUpdateLocations: get location while calling locationManager.startUpdatingLocation
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    
    //  set mapview's center to current location
    MKCoordinateRegion region;
    region.center.latitude = ((CLLocation *)locations[0]).coordinate.latitude;
    region.center.longitude = ((CLLocation *)locations[0]).coordinate.longitude;
    region.span.latitudeDelta = 0.003;
    region.span.longitudeDelta = 0.003;
    [_mapView setRegion:region];
    
    //  search information of current location
    double lat = [[[NSString alloc] initWithFormat:@"%f", region.center.latitude] doubleValue];
    double lng = [[[NSString alloc] initWithFormat:@"%f", region.center.longitude] doubleValue];
    [self searchAtLat:lat Lng:lng];
}
/*
    mapView events
        didSelectAnnotationView: click on an annotation's deatil
        regionDidChangeAnimated: map's region changed
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //  get annotationview of clicked annotaion
    MKAnnotationView *annotationView = [mapView viewForAnnotation:view.annotation];
    
    //  create a button to show the detailed information of the annotation
    UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [calloutButton addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //  set the button to rightCalloutAccessoryView of the annotation view
    annotationView.rightCalloutAccessoryView = calloutButton;
    
    //  get index of annotation for retriving data from dataArray
    index = ((mapAnnotaion *)view.annotation).ind;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //  get new lat/lng of current mapview's center
    double lat = [[[NSString alloc] initWithFormat:@"%f", mapView.region.center.latitude] doubleValue];
    double lng = [[[NSString alloc] initWithFormat:@"%f", mapView.region.center.longitude] doubleValue];
    
    //  search the location
    if(lat !=0.0f && lng != 0.0f)
        [self searchAtLat:lat Lng:lng];
}
/*
    connection recieves data
 */
- (void)coimConnection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
    if ([[_connection accessibilityLabel] isEqualToString:SEARCH_CONNECTION_LABEL]) {
        //  search successed
        if ([[searchInfo objectForKey:coimResParams.errCode] integerValue] == 0) {
            //  clear old annotations
            [_mapView removeAnnotations:_mapView.annotations];
            
            //  clear _dataArray
            [_dataArray removeAllObjects];
            
            //  get searched list
            NSArray *list = [[searchInfo objectForKey:coimResParams.value] objectForKey:coimResParams.list];
            
            //  generating new annotations and dataArray for displaying
            for (int i = 0; i < [list count]; i++) {
                CLLocationCoordinate2D pinCenter;
                pinCenter.latitude = [[list[i] objectForKey:coimResParams.latitude] doubleValue];
                pinCenter.longitude = [[list[i] objectForKey:coimResParams.longitude] doubleValue];
                mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
                annotation.title = [list[i] objectForKey:coimResParams.title];
                annotation.ind = i;
                [_mapView addAnnotation:annotation];
                [_dataArray addObject:list[i]];
            }
        }
        else {
            //  search failed, alert message
            [[[UIAlertView alloc] initWithTitle:SEARCH_ERROR
                                        message:[searchInfo objectForKey:coimResParams.message]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            
            if ([[searchInfo objectForKey:coimResParams.errCode] intValue] == -2) {
                //  errCode is no permission, go login view
                [ReqUtil logoutFrom:coimLogoutURI delegate:self progressTable:dic];
                [appUtil enterLogin];
            }
        }
    }
}
/*
    sub functions
        logout: go login view
        currentLocation: move map view to currenlocation
        searchAtLat:lng: search information based on lat and lng
        checkButtonTapped: 
 */
- (void)logout
{
    [ReqUtil logoutFrom:@"drinks/account/logout" delegate:self progressTable:dic];
    [appUtil enterLogin];
}

- (void)currentLocation
{
    [_locationManager startUpdatingLocation];
}

- (void)searchAtLat:(double)lat Lng:(double)lng
{
    //  prepare parameters for search
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys: [NSString stringWithFormat:@"%f", lat], coimReqParams.lat, [NSString stringWithFormat:@"%f", lng], coimReqParams.lng, nil];
    
    //  create connection
    if(_connection != nil){
        //  if connection exists, cancel it and restart connection
        [_connection cancel];
        _connection = nil;
    }
    _connection = [ReqUtil sendTo:coimSearchURI withParameter:parameters delegate:self progressTable:dic];
    [_connection setAccessibilityLabel:SEARCH_CONNECTION_LABEL];
    
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSDictionary *data = _dataArray[index];
    DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    detailedVC.data = data;
    if (self.navigationController)
        [self.navigationController pushViewController:detailedVC animated:YES];
}

@end
