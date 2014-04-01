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
@synthesize data = _data;

int selected;
NSDictionary *targetDic;

MKAnnotationView *tmpAnnView;

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
    
    //  init dataArray to store searched results
    _dataArray = [NSMutableArray new];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:LEFT_BUTTON_TITLE_MAP style:UIBarButtonItemStylePlain target:self action:@selector(currentLocation)];
    //self.navigationItem.leftBarButtonItem = leftButton;
    //UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RIGHT_BUTTON_TITLE_MAP style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    //  set the button as rightBarButton
    self.navigationItem.rightBarButtonItem = leftButton;
    
    
    
    MKCoordinateRegion region;
    region.center.latitude = [[_data objectForKey:@"latitude"] floatValue];
    region.center.longitude = [[_data objectForKey:@"longitude"] floatValue];
    region.span.latitudeDelta = 0.007;
    region.span.longitudeDelta = 0.007;
    [_mapView setRegion:region];
    // set target pin
    targetDic = [[NSDictionary alloc] initWithObjectsAndKeys:
    [_data objectForKey:@"latitude"] ,@"lat",
    [_data objectForKey:@"longitude"] ,@"lng",
    [_data objectForKey:@"placeName"] ,@"title", nil];
    // search bus stops
    [self searchAtLat:[[_data objectForKey:@"latitude"] doubleValue] Lng:[[_data objectForKey:@"longitude"] doubleValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
    mapView events
        didSelectAnnotationView: click on an annotation's deatil
        regionDidChangeAnimated: map's region changed
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //  get annotationview of clicked annotaion
    
    if([view.annotation subtitle] == nil) {
        tmpAnnView = [mapView viewForAnnotation:view.annotation];
        selected = ((mapAnnotaion *)view.annotation).ind;
        [self searchRouteForStop:[[_dataArray objectAtIndex:selected] objectForKey:@"tsID"]];
        NSLog(@"tsID: %@", [[_dataArray objectAtIndex:selected] objectForKey:@"tsID"]);
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation

{
    
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc]
                                 initWithAnnotation:annotation reuseIdentifier:nil];
    pinView.animatesDrop=YES;
    pinView.canShowCallout=YES;
    if ([[annotation title] isEqualToString:[targetDic objectForKey:@"title"]]) {
        NSLog(@"view for annotation green");
        pinView.pinColor = MKPinAnnotationColorGreen;
        return pinView;
    }
    pinView.pinColor = MKPinAnnotationColorRed;
    return pinView;
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
            NSMutableArray *list = [[searchInfo objectForKey:coimResParams.value] objectForKey:coimResParams.list];
            
            //  generating new annotations and dataArray for displaying
            NSLog(@"target Dic: %@", targetDic);
            [_dataArray addObject:targetDic];
            {
                CLLocationCoordinate2D pinCenter;
                pinCenter.latitude = [[targetDic objectForKey:@"lat"] doubleValue];
                pinCenter.longitude = [[targetDic objectForKey:@"lng"] doubleValue];
                mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
                annotation.title = [targetDic objectForKey:coimResParams.title];
                annotation.ind = 0;
                [_mapView addAnnotation:annotation];
            }
            NSLog(@"data length : %d", [_dataArray count]);
            for (int i = 0; i < [list count]; i++) {
                NSLog(@"list i: %@", list[i]);
                CLLocationCoordinate2D pinCenter;
                pinCenter.latitude = [[list[i] objectForKey:coimResParams.latitude] doubleValue];
                pinCenter.longitude = [[list[i] objectForKey:coimResParams.longitude] doubleValue];
                mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
                annotation.title = [NSString stringWithFormat:@"%@(%@)",[list[i] objectForKey:@"stName"], [list[i] objectForKey:@"stCode"]];
                annotation.ind = i + 1;
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
                //[ReqUtil logoutFrom:coimLogoutURI delegate:self progressTable:dic];
                [coimSDK logoutFrom:coimLogoutURI delegate:self];
                [appUtil enterLogin];
            }
        }
    }

    if([[_connection accessibilityLabel] isEqualToString:@"routeSearch"]) {
        NSLog(@"%@", searchInfo);
        NSArray *routes = [[searchInfo objectForKey:@"value"] objectForKey:@"list"];
        NSMutableString *routeStr = [NSMutableString new];
        for(int i = 0; i<[routes count]; i++) {
            if(i > 0) {
                [routeStr appendString:@", "];
            }
            [routeStr appendString:[[routes objectAtIndex:i] objectForKey:@"rtName"]];
        }
        NSLog(@"routes: %@", routeStr);
        NSLog(@"routes: %d", selected);
        [(mapAnnotaion *)tmpAnnView.annotation setSubtitle:routeStr];
//        NSLog(@"annotation: %@", [(mapAnnotaion *)tmpAnnView.annotation subtitle]);
        
    }
}

- (void)searchRouteForStop:(NSString *)tsID
{
    //  create connection
    if(_connection != nil){
        //  if connection exists, cancel it and restart connection
        [_connection cancel];
        _connection = nil;
    }
    NSString *relativeURL = [NSString stringWithFormat:@"twCtBus/busStop/routes/%@", tsID];
    _connection = [coimSDK sendTo:relativeURL withParameter:nil delegate:self];
    [_connection setAccessibilityLabel:@"routeSearch"];
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
    //[ReqUtil logoutFrom:@"drinks/account/logout" delegate:self progressTable:dic];
    [coimSDK logoutFrom:coimLogoutURI delegate:self];
    [appUtil enterLogin];
}

- (void)currentLocation
{
    MKCoordinateRegion region;
    region.center.latitude = [[_data objectForKey:@"latitude"] floatValue];
    region.center.longitude = [[_data objectForKey:@"longitude"] floatValue];
    region.span.latitudeDelta = 0.003;
    region.span.longitudeDelta = 0.003;
    [_mapView setRegion:region];
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
    _connection = [coimSDK sendTo:coimSearchURI withParameter:parameters delegate:self];
    [_connection setAccessibilityLabel:SEARCH_CONNECTION_LABEL];
    
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    //NSDictionary *data = _dataArray[index];
    //DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    //detailedVC.data = data;
    //if (self.navigationController)
        //[self.navigationController pushViewController:detailedVC animated:YES];
    NSLog(@"click button on pin");
}

@end
