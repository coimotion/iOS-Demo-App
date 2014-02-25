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
@synthesize searchURL = _searchURL;
@synthesize index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = MAP_TITLE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _searchURL = [[NSString alloc] initWithFormat:@"%@/%@/%@", coiBaseURL, coiAppCode, coiSearchURI];
    
    _dataArray = [[NSMutableArray alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    MKCoordinateRegion region;
    region.center.latitude = ((CLLocation *)locations[0]).coordinate.latitude;
    region.center.longitude = ((CLLocation *)locations[0]).coordinate.longitude;
    region.span.latitudeDelta = 0.003;
    region.span.longitudeDelta = 0.003;
    [_mapView setRegion:region];
    [_locationManager stopUpdatingLocation];
    NSString *lat = [[NSString alloc] initWithFormat:@"%f", region.center.latitude];
    NSString *lng = [[NSString alloc] initWithFormat:@"%f", region.center.longitude];
    [self searchAtLat:lat Lng:lng];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKAnnotationView* annotationView = [mapView viewForAnnotation:view.annotation];
    UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [calloutButton addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = calloutButton;
    index = ((mapAnnotaion *)view.annotation).ind;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSString *lat = [[NSString alloc] initWithFormat:@"%f", mapView.region.center.latitude];
    NSString *lng = [[NSString alloc] initWithFormat:@"%f", mapView.region.center.longitude];
    [self searchAtLat:lat Lng:lng];
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSDictionary *data = _dataArray[index];
    DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    detailedVC.data = data;
    if (self.navigationController)
        [self.navigationController pushViewController:detailedVC animated:YES];
}

- (void)searchAtLat:(NSString *)lat Lng:(NSString *)lng
{
    NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@&%@=%@", coiReqParams.lat, lat,
                                                                                  coiReqParams.lng, lng,
                                                                                  coiReqParams.token, [[appUtil sharedUtil] token]];
    NSURLRequest *searchReq = [[appUtil sharedUtil] getHttpConnectionByMethod:coiMethodGet
                                                                        toURL:_searchURL
                                                                      useData:parameters];
    if (!_connection) {
        _connection = [[NSURLConnection alloc] initWithRequest:searchReq delegate:self];
    }
    else {
        [_connection cancel];
        _connection = [[NSURLConnection alloc] initWithRequest:searchReq delegate:self];
    }
    [_connection setAccessibilityLabel:SEARCH_CONNECTION_LABEL];
}

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    if ([[_connection accessibilityLabel] isEqualToString:SEARCH_CONNECTION_LABEL]) {
        NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        if ([[searchInfo objectForKey:coiResParams.errCode] integerValue] == 0) {
            if ([searchInfo objectForKey:coiResParams.token] != nil) {
                [[appUtil sharedUtil] setToken:[searchInfo objectForKey:coiResParams.token]];
                [[appUtil sharedUtil] saveObject:[searchInfo objectForKey:coiResParams.token] forKey:coiResParams.token toPlist:coiPlist];
            }
            [_mapView removeAnnotations:_mapView.annotations];
            [_dataArray removeAllObjects];
            NSArray *list = [[searchInfo objectForKey:coiResParams.value] objectForKey:coiResParams.list];
            for (int i = 0; i < [list count]; i++) {
                CLLocationCoordinate2D pinCenter;
                pinCenter.latitude = [[list[i] objectForKey:coiResParams.latitude] doubleValue];
                pinCenter.longitude = [[list[i] objectForKey:coiResParams.longitude] doubleValue];
                mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
                annotation.title = [list[i] objectForKey:coiResParams.title];
                annotation.subtitle = [list[i] objectForKey:coiResParams.summary];
                annotation.ind = i;
                [_mapView addAnnotation:annotation];
                [_dataArray addObject:list[i]];
            }
        }
        else {
            [[[UIAlertView alloc] initWithTitle:SEARCH_ERROR
                                        message:[searchInfo objectForKey:coiResParams.message]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            
            if ([[searchInfo objectForKey:coiResParams.errCode] intValue] == -2) {
                [[appUtil sharedUtil] logout];
            }
        }
    }
}

@end
