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
@synthesize roleArray = _roleArray;
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
        self.title = @"Map View";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *plist = [[NSDictionary alloc] init];
    plist = [[appUtil sharedUtil] getSettingsFrom:@"coimotion"];
    _searchURL = [[NSString alloc] initWithFormat:@"%@/%@/%@",[plist objectForKey:[[appUtil sharedUtil] baseURLKey]],
                  [plist objectForKey:[[appUtil sharedUtil] appCodeKey]],
                  [plist objectForKey:[[appUtil sharedUtil] searchURIKey]]];
    
    _roleArray = [[NSMutableArray alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:22.626295 longitude:120.282424];//[locations objectAtIndex:0];
    
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
    NSDictionary *data = _roleArray[index];
    DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    detailedVC.data = data;
    if (self.navigationController)
        [self.navigationController pushViewController:detailedVC animated:YES];
}

- (void)searchAtLat:(NSString *)lat Lng:(NSString *)lng
{
    NSString *parameters = [[NSString alloc] initWithFormat:@"%@=%@&%@=%@&%@=%@", [[appUtil sharedUtil] latParam], lat, [[appUtil sharedUtil] lngParam], lng, [[appUtil sharedUtil] tokenParam], [[appUtil sharedUtil] token]];
    NSURLRequest *searchReq = [[appUtil sharedUtil] getHttpConnectionByMethod:@"POST"
                                                                        toURL:_searchURL
                                                                      useData:parameters];
    if (!_connection) {
        _connection = [[NSURLConnection alloc] initWithRequest:searchReq delegate:self];
    }
    else {
        [_connection cancel];
        _connection = [[NSURLConnection alloc] initWithRequest:searchReq delegate:self];
    }
    [_connection setAccessibilityLabel:@"search"];
}

- (void)connection:(NSURLConnection *)conn didReceiveData: (NSData *) incomingData
{
    if ([[_connection accessibilityLabel] isEqualToString:@"search"]) {
        //parse json, save token;
        NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
        if ([[searchInfo objectForKey:@"errCode"] integerValue] == 0) {
            if ([searchInfo objectForKey:@"token"] != nil) {
                [[appUtil sharedUtil] setToken:[searchInfo objectForKey:@"token"]];
                NSMutableDictionary *plist = [[appUtil sharedUtil] getPlistFrom:@"/app.plist"];
                [plist setObject:[searchInfo objectForKey:@"token"] forKey:@"token"];
                [[appUtil sharedUtil] setPlist:plist to:@"/app.plist"];
            }
            
            [_mapView removeAnnotations:_mapView.annotations];
            [_roleArray removeAllObjects];
            NSArray *list = [[searchInfo objectForKey:@"value"] objectForKey:@"list"];
            for (int i = 0; i < [list count]; i++) {
                NSDictionary *item = [list objectAtIndex:i];
                CLLocationCoordinate2D pinCenter;
                pinCenter.latitude = [[item objectForKey:@"latitude"] doubleValue];
                pinCenter.longitude = [[item objectForKey:@"longitude"] doubleValue];
                mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
                annotation.title = [item objectForKey:@"title"];
                annotation.subtitle = [item objectForKey:@"summary"];
                annotation.ind = i;
                [_mapView addAnnotation:annotation];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:[item objectForKey:@"title"] forKey:@"name"];
                [dic setObject:[item objectForKey:@"summary"] forKey:@"branch"];
                [dic setObject:[item objectForKey:@"addr"] forKey:@"addr"];
                [dic setObject:[item objectForKey:@"latitude"] forKey:@"lat"];
                [dic setObject:[item objectForKey:@"longitude"] forKey:@"lng"];
                if ([[item objectForKey:@"title"] isEqual:@"50嵐"]) {
                    [dic setObject:@"1" forKey:@"id"];
                }
                else if ([[item objectForKey:@"title"] isEqual:@"南傳鮮奶"]) {
                    [dic setObject:@"2" forKey:@"id"];
                }
                else if ([[item objectForKey:@"title"] isEqual:@"鮮茶道"]) {
                    [dic setObject:@"3" forKey:@"id"];
                }
                [_roleArray addObject:dic];
            }
            
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Search Error"
                                        message:[searchInfo objectForKey:@"message"]
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            [[appUtil sharedUtil] setRootWindowView:loginVC];
        }
    }
}

@end
