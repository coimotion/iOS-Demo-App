//
//  ViewController.h
//  appTemplate
//
//  Created by Mac on 2014/3/28.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myCell.h"
#import "DetailedViewController.h"
@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (nonatomic,retain)CLLocationManager* locationManager;
@property (nonatomic, retain)NSURLConnection *connection;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property bool catFlag;
@property int selectedPeriod;
@property (strong, nonatomic)UILabel *titleLabel;
@property (strong, nonatomic) NSArray *pickerValue;
@property (strong, nonatomic) NSArray *catPickerValue;
@property (strong, nonatomic) NSArray *catIDArray;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *dismissView;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) NSString *catID;
@property (strong, nonatomic) NSMutableData *myData;
@property (strong, nonatomic) NSMutableDictionary *dic;
- (IBAction)check:(id)sender;
- (IBAction)cancel:(id)sender;
@end
