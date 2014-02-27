//
//  AppDelegate.h
//  appTemplate
//
//  Created by Mac on 14/2/18.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

#define CHECK_TOKEN_CONNECTION_LABEL @"checkTokenConn"
#define LOGIN_CONNECTION_LABEL @"loginConn"
#define SEARCH_CONNECTION_LABEL @"searchConn"
#define DETAIL_CONNECTION_LABEL @"detailConn"
#define REGISTER_CONNECTION_LABEL @"registerConn"
#define ACTIVATE_CONNECTION_LABEL @"activateConn"
#define TOP_OF_BUTTON 236
#define TOP_OF_CONFIRM 198
#define CELL_IDENTIFIER @"cell"
#define SEARCH_ERROR @"搜尋錯誤"
#define LOGIN_ERROR @"登入錯誤"
#define REGISTER_ERROR @"註冊錯誤"
#define DETAIL_ERROR @"資訊錯誤"
#define LIST_TITLE @"列表顯示"
#define MAP_TITLE @"地圖顯示"
#define RIGHT_BUTTON_TITLE_MAP @"登出"
#define LEFT_BUTTON_TITLE_MAP @"目前位置"
#define RIGHT_BUTTON_TITLE_LIST @"登出"
#define LEFT_BUTTON_TITLE_LIST @"登出"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
