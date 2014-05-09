//
//  BAPlaceMark.h
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BAPlaceMark : NSObject <MKAnnotation>

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithID:(NSString *)pID coordinate:(CLLocationCoordinate2D)coordinate header:(NSString *)header subheader:(NSString *)subheader;
- (NSString *)placemarkID;

@end
