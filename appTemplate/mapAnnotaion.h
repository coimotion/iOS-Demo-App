//
//  mapAnnotaion.h
//  appTemplate
//
//  Created by Mac on 14/2/21.
//  Copyright (c) 2014年 Gocharm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface mapAnnotaion : NSObject <MKAnnotation>
{}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property int ind;

-(id) initWithCoordinate: (CLLocationCoordinate2D) the_coordinate;

@end
