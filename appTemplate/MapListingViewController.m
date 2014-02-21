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
@synthesize locationManager = _locationManager;
@synthesize mapView = _mapView;
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
    _roleArray = [[NSMutableArray alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_locationManager startUpdatingLocation];
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
    region.center.latitude = 22.626295;
    region.center.longitude = 120.282424;
    region.span.latitudeDelta = 0.003;
    region.span.longitudeDelta = 0.003;
    [_mapView setRegion:region];
    [_locationManager stopUpdatingLocation];
    [self getContent];
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
    NSLog(@"map region changed");
}

- (void)checkButtonTapped:(id)sender event:(id)event{
    
    //UIAlertView *tmp= [[UIAlertView alloc] initWithTitle:@"訊息！" message:@"Callout測試" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[tmp show];
    NSDictionary *data = _roleArray[index];
    DetailedViewController *detailedVC = [[DetailedViewController alloc] initWithNibName:@"DetailedViewController" bundle:nil];
    detailedVC.data = data;
    
    if (self.navigationController)
        [self.navigationController pushViewController:detailedVC animated:YES];
    NSLog(@"%d", index);
}

- (void)getContent
{
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.626295;
        pinCenter.longitude = 120.282424;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"50嵐";
        annotation.subtitle = @"鹽埕店";
        annotation.ind = 0;
        
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"鹽埕店" forKey:@"branch"];
        [dic setObject:@"高雄市鹽埕區七賢三路138號" forKey:@"addr"];
        [dic setObject:@"07-5218988" forKey:@"tel"];
        [dic setObject:@"22.626295" forKey:@"lat"];
        [dic setObject:@"120.282424" forKey:@"lng"];
        [_roleArray addObject:dic];
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.623241;
        pinCenter.longitude = 120.272051;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"50嵐";
        annotation.subtitle = @"臨海店";
        annotation.ind = 1;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"臨海店" forKey:@"branch"];
        [dic setObject:@"高雄市鼓山區臨海二路41號" forKey:@"addr"];
        [dic setObject:@"07-5512998" forKey:@"tel"];
        [dic setObject:@"22.623241" forKey:@"lat"];
        [dic setObject:@"120.272051" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.618131;
        pinCenter.longitude = 120.299968;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"50嵐";
        annotation.subtitle = @"苓雅店";
        annotation.ind = 2;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"苓雅店" forKey:@"branch"];
        [dic setObject:@"高雄市苓雅區苓雅二路72號" forKey:@"addr"];
        [dic setObject:@"07-3384515" forKey:@"tel"];
        [dic setObject:@"22.618131" forKey:@"lat"];
        [dic setObject:@"120.299968" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.621657;
        pinCenter.longitude = 120.307256;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"50嵐";
        annotation.subtitle = @"青年店";
        annotation.ind = 3;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"1" forKey:@"id"];
        [dic setObject:@"50嵐" forKey:@"name"];
        [dic setObject:@"青年店" forKey:@"branch"];
        [dic setObject:@"高雄市苓雅區青年一路1792號" forKey:@"addr"];
        [dic setObject:@"07-5376229" forKey:@"tel"];
        [dic setObject:@"22.621657" forKey:@"lat"];
        [dic setObject:@"120.307256" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.65101;
        pinCenter.longitude = 120.326034;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"南傳鮮奶";
        annotation.subtitle = @"建工店";
        annotation.ind = 4;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"2" forKey:@"id"];
        [dic setObject:@"南傳鮮奶" forKey:@"name"];
        [dic setObject:@"建工店" forKey:@"branch"];
        [dic setObject:@"高雄市三民區建工路522號" forKey:@"addr"];
        [dic setObject:@"07-3858595" forKey:@"tel"];
        [dic setObject:@"22.65101" forKey:@"lat"];
        [dic setObject:@"120.326034" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.612281;
        pinCenter.longitude = 120.311305;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"南傳鮮奶";
        annotation.subtitle = @"復興店";
        annotation.ind = 5;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"2" forKey:@"id"];
        [dic setObject:@"南傳鮮奶" forKey:@"name"];
        [dic setObject:@"復興店" forKey:@"branch"];
        [dic setObject:@"高雄市前鎮區復興三路152號" forKey:@"addr"];
        [dic setObject:@"07-3343611" forKey:@"tel"];
        [dic setObject:@"22.612281" forKey:@"lat"];
        [dic setObject:@"120.311305" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.623122;
        pinCenter.longitude = 120.272403;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"南傳鮮奶";
        annotation.subtitle = @"西子灣店";
        annotation.ind = 6;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"2" forKey:@"id"];
        [dic setObject:@"南傳鮮奶" forKey:@"name"];
        [dic setObject:@"西子灣店" forKey:@"branch"];
        [dic setObject:@"高雄市鼓山區臨海二路34號" forKey:@"addr"];
        [dic setObject:@"07-5310900" forKey:@"tel"];
        [dic setObject:@"22.623122" forKey:@"lat"];
        [dic setObject:@"120.272403" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.626306;
        pinCenter.longitude = 120.282418;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"鮮茶道";
        annotation.subtitle = @"鹽埕七賢店";
        annotation.ind = 7;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"3" forKey:@"id"];
        [dic setObject:@"鮮茶道" forKey:@"name"];
        [dic setObject:@"鹽埕七賢店" forKey:@"branch"];
        [dic setObject:@"高雄市鹽埕區七賢三路130號" forKey:@"addr"];
        [dic setObject:@"07-5316718" forKey:@"tel"];
        [dic setObject:@"22.626306" forKey:@"lat"];
        [dic setObject:@"120.282418" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.651908;
        pinCenter.longitude = 120.318245;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"鮮茶道";
        annotation.subtitle = @"高雄鼎山店";
        annotation.ind = 8;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"3" forKey:@"id"];
        [dic setObject:@"鮮茶道" forKey:@"name"];
        [dic setObject:@"高雄鼎山店" forKey:@"branch"];
        [dic setObject:@"高雄市三民區鼎山街555號" forKey:@"addr"];
        [dic setObject:@"07-3945736" forKey:@"tel"];
        [dic setObject:@"22.651908" forKey:@"lat"];
        [dic setObject:@"120.318245" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
    {
        CLLocationCoordinate2D pinCenter;
        pinCenter.latitude = 22.623018;
        pinCenter.longitude = 120.271809;
        mapAnnotaion *annotation = [[mapAnnotaion alloc] initWithCoordinate: pinCenter];
        annotation.title = @"鮮茶道";
        annotation.subtitle = @"高雄西子灣店";
        annotation.ind = 9;
        [_mapView addAnnotation:annotation];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"3" forKey:@"id"];
        [dic setObject:@"鮮茶道" forKey:@"name"];
        [dic setObject:@"高雄西子灣店" forKey:@"branch"];
        [dic setObject:@"高雄市鼓山區臨海二路47號" forKey:@"addr"];
        [dic setObject:@"07-5336018" forKey:@"tel"];
        [dic setObject:@"22.623018" forKey:@"lat"];
        [dic setObject:@"120.271809" forKey:@"lng"];
        [_roleArray addObject:dic];
        
    }
}


@end
