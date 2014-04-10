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

@synthesize aboutText = _aboutText;
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
    [self setTitle:@"關於此App"];
    [_aboutText setBackgroundColor:[UIColor clearColor]];
    [_aboutText setTextAlignment:NSTextAlignmentNatural];
    [_aboutText setText:@"此App是用以展示COIMOTION API平台，結合政府開放資料中的藝文活動與高雄市政府的公車資訊打造，提供高雄市藝文活動的查詢以及活動地點的公車資訊，方便使用者查詢可前往的公車。"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)logout:(id)sender {
    [coimSDK logoutFrom:@"core/user/logout" delegate:self];
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
