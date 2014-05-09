//
//  BALocationManager.m
//  EmeraldStreet
//
//  Created by Sandip on 12/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BALocationManager.h"

#define kMTLocationTitle @"Location service is disabled"
#define kMTLocationMessage @"Please go to 'Settings' and enable the location service."

@interface BALocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;
@property (nonatomic, strong) NSDate *lastLocationUpdate;
@property (nonatomic, assign) BOOL isLocationActivated;

-(void)updateLocationManager;
-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

@end

@implementation BALocationManager


@synthesize locationManager = locationManager_;

+ (BALocationManager *)sharedInstance
{
    static BALocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BALocationManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)copyWithZone:(NSZone *)inZone
{
    return self;
}

- (id)init
{
    self = [super init];
    
	if(self)
	{
        [self updateLocationManager];
	}
    
	return self;
}

#pragma mark - CLLocationManagerDelegate

// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
#ifdef DEBUG
    //    NSLog(@"locationManager didUpdateToLocation\n%@", newLocation);
#endif
    
    if ((self.currentCoordinate.latitude == newLocation.coordinate.latitude) && (self.currentCoordinate.longitude == newLocation.coordinate.longitude)) {
        
        self.lastLocationUpdate = [NSDate date];
        
//        if (self.locationManager)
//        {
//            self.locationManager.delegate = nil;
//            self.locationManager = nil;
//            self.isLocationActivated = NO;
//        }
        
        return;
    }
    
    [self didUpdateCurrentCoordinate:newLocation.coordinate];
}

// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"locationManager didFailWithError\n%@", error);
#endif
    
	if ([error code] == kCLErrorDenied)
	{
        [self.locationManager stopUpdatingLocation];
        
		self.isLocationActivated = NO;
        
		[self showAlertWithTitle:kMTLocationTitle andMessage:kMTLocationMessage];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"locationManager didFinishDeferredUpdatesWithError\n%@", error);
#endif
    
	if ([error code] == kCLErrorDenied)
	{
        [self.locationManager stopUpdatingLocation];
        
		self.isLocationActivated = NO;
        
		[self showAlertWithTitle:kMTLocationTitle andMessage:kMTLocationMessage];
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
#ifdef DEBUG
    //    NSLog(@"locationManager didChangeAuthorizationStatus %d", status);
#endif
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        [self.locationManager stopUpdatingLocation];
        
		self.isLocationActivated = NO;
		[self showAlertWithTitle:kMTLocationTitle andMessage:kMTLocationMessage];
    }
    else if(status == kCLAuthorizationStatusAuthorized)
    {
        [self.locationManager startUpdatingLocation];
        
		self.isLocationActivated = YES;
    }
}

#pragma mark -

+ (BOOL)hasCurrentCoordinate
{
    if (![self sharedInstance].isLocationActivated)
		[[self sharedInstance] updateLocationManager];
    
    if ((0.0 == [self getCurrentCoordinate].latitude) && (0.0 == [self getCurrentCoordinate].longitude))
        return NO;
    
    return CLLocationCoordinate2DIsValid([self getCurrentCoordinate]);
}

+ (CLLocationCoordinate2D)getCurrentCoordinate
{
	return [self sharedInstance].currentCoordinate;
}

+ (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ((0.0 == coordinate.latitude) || (0.0 == coordinate.longitude))
        return NO;
    
    return CLLocationCoordinate2DIsValid(coordinate);
}

+ (double)distanceFromCoordinate:(CLLocationCoordinate2D)coordinate
{
    double km = 0;
    
    if ([self hasCurrentCoordinate] && [self isValidCoordinate:coordinate])
    {
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:[self getCurrentCoordinate].latitude longitude:[self getCurrentCoordinate].longitude];
        CLLocation *destLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        km = [currentLocation distanceFromLocation:destLocation]/1000.0;
        
        if (km < 0)
            km *= -1.0;
    }
    
    return km;
}

- (void)didUpdateCurrentCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.lastLocationUpdate = [NSDate date];
    
    self.currentCoordinate = coordinate;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidUpdateNotification object:nil];
    
//    if (self.locationManager)
//    {
//        self.locationManager.delegate = nil;
//        self.locationManager = nil;
//        self.isLocationActivated = NO;
//    }
}

- (void)updateLocationManager
{
	if (nil == self.locationManager)
	{
        BOOL shouldCreateLocationManager = YES;
        
        if (nil == self.lastLocationUpdate)
        {
            self.currentCoordinate = CLLocationCoordinate2DMake(0, 0);
        }
        else
        {
            NSUInteger minutes = [self.lastLocationUpdate timeIntervalSinceDate:[NSDate date]]/60.0;
            shouldCreateLocationManager = (minutes >= 10.0);
        }
        
        if (shouldCreateLocationManager)
        {
            CLLocationManager *alocationManager = [[CLLocationManager alloc] init];
            self.locationManager = alocationManager;
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            self.locationManager.distanceFilter = 100.0f;
        }
	}
    
    if (self.locationManager)
    {
        [self.locationManager startUpdatingLocation];
        
        self.isLocationActivated = YES;
    }
}

-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
#ifdef DEBUG
    NSLog(@"Title: %@\nMessage: %@", title, message);
#endif
}

#pragma mark -

- (void)dealloc
{
    locationManager_.delegate = nil;
}

@end
