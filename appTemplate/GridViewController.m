//
//  GridViewController.m
//  appTemplate
//
//  Created by Mac on 2014/4/1.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()

@end

@implementation GridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES];   //it hides
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];    // it shows
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)show1:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"1";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show2:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"2";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show3:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"3";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show4:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"4";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show5:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"6";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show6:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"7";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show7:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"8";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show8:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"17";
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)show9:(id)sender {
    ViewController *VC = [ViewController new];
    VC.catID = @"15";
    [self.navigationController pushViewController:VC animated:YES];
}
@end
