//
//  BALocationManager.h
//  EmeraldStreet
//
//  Created by Sandip on 12/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kLocationManagerDidUpdateNotification @"LocationManagerDidUpdateNotification"

#import <Foundation/Foundation.h>

@interface BALocationManager : NSObject

+ (BALocationManager *)sharedInstance;

+ (BOOL)hasCurrentCoordinate;
+ (CLLocationCoordinate2D)getCurrentCoordinate;
+ (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate;
+ (double)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate;

@end
