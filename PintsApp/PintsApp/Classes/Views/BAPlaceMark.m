//
//  BAPlaceMark.m
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAPlaceMark.h"

@interface BAPlaceMark ()

@property (nonatomic, strong) NSString *placemarkID;
@property (nonatomic, strong) NSString *headerText;
@property (nonatomic, strong) NSString *subheaderText;

@end

@implementation BAPlaceMark

@synthesize coordinate = coordinate_;

- (id)initWithID:(NSString *)pID coordinate:(CLLocationCoordinate2D)coordinate header:(NSString *)header subheader:(NSString *)subheader
{
    self = [super init];
	if (self != nil)
    {
		coordinate_.latitude = coordinate.latitude;
		coordinate_.longitude = coordinate.longitude;
	
        self.placemarkID = pID;
        self.headerText = header;
        self.subheaderText = subheader;
	}
    
	return self;
}

- (NSString *)subtitle
{
	return self.subheaderText;
}

- (NSString *)title
{
	return self.headerText;
}

- (NSString *)cID
{
	return self.placemarkID;
}

@end
