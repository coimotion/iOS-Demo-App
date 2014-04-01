//
//  DetailedViewController.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "MapListingViewController.h"

@interface DetailedViewController : UIViewController <UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UITextView *saleText;
@property (strong, nonatomic) IBOutlet UITextView *locationText;
@property (strong, nonatomic) IBOutlet UITextView *descText;
@property (strong, nonatomic) IBOutlet UITextView *periodText;
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) IBOutlet UILabel *showTitle;
@property (strong, nonatomic) NSString *detailURL;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) NSString *docURL;
@property (strong, nonatomic) IBOutlet UIButton *saleImg;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) IBOutlet UIView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *dismissPickerView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *freeImg;
- (IBAction)openMapView:(id)sender;
- (IBAction)buyTicket:(id)sender;
- (IBAction)check:(id)sender;
- (IBAction)cancel:(id)sender;

@end
