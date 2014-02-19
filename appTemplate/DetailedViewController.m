//
//  DetailedViewController.m
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "DetailedViewController.h"

@interface DetailedViewController ()

@end

@implementation DetailedViewController
@synthesize data;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [data valueForKey:@"name"];
    NSString *imageFilename = [[NSString alloc] init];
    if ([[data valueForKey:@"id"] isEqual:@"1"])
        imageFilename = @"menu1.png";
    if ([[data valueForKey:@"id"] isEqual:@"2"])
        imageFilename = @"menu2.png";
    if ([[data valueForKey:@"id"] isEqual:@"3"])
        imageFilename = @"menu3.png";
    UIImage *image = [UIImage imageNamed:imageFilename];
    UIImageView *menuImage = [[UIImageView alloc] initWithImage:image];
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.delegate = self;
    [scrollView addSubview:menuImage];
    [scrollView setContentSize:CGSizeMake(image.size.width, image.size.height)];
    self.view = scrollView;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
