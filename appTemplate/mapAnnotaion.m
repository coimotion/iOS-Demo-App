//
//  mapAnnotaion.m
//  appTemplate
//
//  Created by Mac on 14/2/21.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import "mapAnnotaion.h"

@implementation mapAnnotaion
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize ind;

-(id) initWithCoordinate: (CLLocationCoordinate2D) the_coordinate
{
    if (self = [super init])
    {
        coordinate = the_coordinate;
    }
    return self;
}


@end
