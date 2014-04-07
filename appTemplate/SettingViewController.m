//
//  SettingViewController.m
//  appTemplate
//
//  Created by Mac on 2014/4/3.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

#pragma mark - view control flow
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)logout:(id)sender {
    [coimSDK logoutFrom:@"drinks/account/logout" delegate:self];
}

#pragma mark - coimotion delegaet
- (void)coimConnectionDidFinishLoading:(NSURLConnection *)connection
                              withData:(NSDictionary *)responseData
{
    NSLog(@"finish: %@", responseData);
    [appUtil enterLogin];
}

- (void)coimConnection:(NSURLConnection *)connection
      didFailWithError:(NSError *)error
{
    NSLog(@"fail: %@", [error localizedDescription]);
    [appUtil enterLogin];
}
@end
