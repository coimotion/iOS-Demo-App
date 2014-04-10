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
@synthesize mapView = _mapView;
@synthesize connection = _connection;
@synthesize data = _data;
@synthesize selected = _selected;
@synthesize targetDic = _targetDic;
@synthesize stopRouteList = _stopRouteList;
@synthesize rightButton = _rightButton;
@synthesize tmpAnnView = _tmpAnnView;

#pragma mark - view control flows

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"活動地點";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  init dataArray to store searched results
    _dataArray = [NSMutableArray new];
    _stopRouteList = [NSMutableArray new];
    _rightButton = [[UIBarButtonItem alloc] initWithTitle:@"路線清單" style:UIBarButtonItemStylePlain target:self action:@selector(listStopRoutes)];

    [self.navigationController.navigationBar setBarTintColor: [[UIColor alloc] initWithRed:239.0f/255.0f green:235.0f/255.0f blue:232.0f/255.0f alpha:1.0f]];
    
    //  set the button as rightBarButton
    MKCoordinateRegion region;
    region.center.latitude = [[_data objectForKey:@"latitude"] floatValue];
    region.center.longitude = [[_data objectForKey:@"longitude"] floatValue];
    region.span.latitudeDelta = 0.007;
    region.span.longitudeDelta = 0.007;
    [_mapView setRegion:region];
    // set target pin
    _targetDic = [[NSDictionary alloc] initWithObjectsAndKeys:
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.translucent = NO;
}


#pragma mark - map view delegate
/*
    didSelectAnnotationView: click on an annotation's deatil
    regionDidChangeAnimated: map's region changed
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //  get annotationview of clicked annotaion
    
    if([view.annotation subtitle] == nil) {
        _tmpAnnView = [mapView viewForAnnotation:view.annotation];
        _selected = ((mapAnnotaion *)view.annotation).ind;
        [self searchRouteForStop:[[_dataArray objectAtIndex:_selected] objectForKey:@"tsID"]];
        NSLog(@"tsID: %@", [[_dataArray objectAtIndex:_selected] objectForKey:@"tsID"]);
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc]
                                 initWithAnnotation:annotation reuseIdentifier:nil];
    pinView.animatesDrop=YES;
    pinView.canShowCallout=YES;
    if ([[annotation title] isEqualToString:[_targetDic objectForKey:@"title"]]) {
        NSLog(@"view for annotation green");
        pinView.pinColor = MKPinAnnotationColorGreen;
        return pinView;
    }
    pinView.pinColor = MKPinAnnotationColorRed;
    return pinView;
}

#pragma mark - subfunctions

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

- (void)listStopRoutes
{
    RouteListViewController *VC = [RouteListViewController new];
    VC.tsIDs = _stopRouteList;
    [[self navigationController] pushViewController:VC animated:YES];
    
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
    _connection = [coimSDK sendTo:@"twCtBus/busStop/search" withParameter:parameters delegate:self];
    [_connection setAccessibilityLabel:SEARCH_CONNECTION_LABEL];
    
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSLog(@"click button on pin");
}

#pragma mark - coimotion delegate
- (void)coimConnection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", [error localizedDescription]);
}

- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
                              withData:(NSDictionary *)responseData
{
    //NSDictionary *searchInfo = [NSJSONSerialization JSONObjectWithData:incomingData options:0 error:nil];
    if ([[_connection accessibilityLabel] isEqualToString:SEARCH_CONNECTION_LABEL]) {
        //  search successed
        [_mapView removeAnnotations:_mapView.annotations];
        
        //  clear _dataArray
        [_dataArray removeAllObjects];
        
        //  get searched list
        NSMutableArray *list = [[responseData objectForKey:coimResParams.value] objectForKey:coimResParams.list];
        
        //  generating new annotations and dataArray for displaying
        NSLog(@"target Dic: %@", _targetDic);
        [_dataArray addObject:_targetDic];
        {
            CLLocationCoordinate2D pinCenter;
            pinCenter.latitude = [[_targetDic objectForKey:@"lat"] doubleValue];
            pinCenter.longitude = [[_targetDic objectForKey:@"lng"] doubleValue];
            mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
            annotation.title = [_targetDic objectForKey:coimResParams.title];
            annotation.ind = 0;
            [_mapView addAnnotation:annotation];
        }
        NSLog(@"data length : %d", [list count]);
        for (int i = 0; i < [list count]; i++) {
            NSLog(@"list %d: %@", i, list[i]);
            NSString *stopName = [NSString stringWithFormat:@"%@(%@)",[list[i] objectForKey:@"stName"], [list[i] objectForKey:@"stCode"]];
            //[stopRouteList setObject:[NSMutableArray new] forKey:[list[i] objectForKey:stopName]];
            //NSMutableDictionary *d = [NSMutableDictionary new];
            
            //[d setObject:[NSMutableArray new] forKey:stopName];
            [_stopRouteList addObject:[list[i] objectForKey:@"tsID"]];
            
            CLLocationCoordinate2D pinCenter;
            pinCenter.latitude = [[list[i] objectForKey:coimResParams.latitude] doubleValue];
            pinCenter.longitude = [[list[i] objectForKey:coimResParams.longitude] doubleValue];
            mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
            annotation.title = stopName;
            annotation.ind = i + 1;
            [_mapView addAnnotation:annotation];
            [_dataArray addObject:list[i]];
        }
        NSLog(@"stop route list: %d", [_stopRouteList count]);
        if([list count] > 1)
            self.navigationItem.rightBarButtonItem = _rightButton;
    }
    
    if([[_connection accessibilityLabel] isEqualToString:@"routeSearch"]) {
        NSLog(@"%@", responseData);
        NSArray *routes = [[responseData objectForKey:@"value"] objectForKey:@"list"];
        NSMutableString *routeStr = [NSMutableString new];
        for(int i = 0; i<[routes count]; i++) {
            if(i > 0) {
                [routeStr appendString:@", "];
            }
            [routeStr appendString:[[routes objectAtIndex:i] objectForKey:@"rtName"]];
        }
        NSLog(@"routes: %@", routeStr);
        NSLog(@"routes: %d", _selected);
        [(mapAnnotaion *)_tmpAnnView.annotation setSubtitle:routeStr];
    }
}

@end
