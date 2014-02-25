//
//  appConstants.m
//  appTemplate
//
//  Created by Mac on 14/2/25.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "appConstants.h"

@implementation appConstants
NSString *const coiBaseURL = @"http://192.168.1.190:3000";
NSString *const coiAppCode = @"wcoim";
NSString *const coiLoginURI = @"core/user/login";
NSString *const coiSearchURI = @"cms/geoLoc/search";
NSString *const coiPlist = @"/app.plist";
NSString *const coiMethodPost = @"POST";
NSString *const coiMethodGet = @"GET";

const struct requestKeysForCoimotionAPI coiReqParams = {
    .lat = @"lat",
    .lng = @"lng",
    .addr = @"addr",
    .accName = @"accName",
    .passwd = @"passwd",
    .token = @"token"
};

const struct responseKeysFromCoimotionAPI coiResParams = {
    .errCode = @"errCode",
    .message = @"message",
    .value = @"value",
    .list = @"list",
    .latitude = @"latitude",
    .longitude = @"longitude",
    .title = @"title",
    .summary = @"summary",
    .geID = @"geID",
    .ngID = @"ngID",
    .token = @"token",
    .addr = @"addr"
};

@end
