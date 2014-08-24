//
//  BAAnalytics.m
//  PintsApp
//
//  Created by Sandip on 18/08/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAAnalytics.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


@interface BAAnalytics ()

@property (nonatomic, strong) id <GAITracker> tracker;

@end

@implementation BAAnalytics

+ (BAAnalytics *)sharedInstance
{
    static BAAnalytics *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BAAnalytics alloc] init];
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
        // Optional: automatically send uncaught exceptions to Google Analytics.
        //[GAI sharedInstance].trackUncaughtExceptions = YES;
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        //[GAI sharedInstance].dispatchInterval = 20;
        
        // Optional: set Logger to VERBOSE for debug information.
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
        
        // Initialize tracker. Replace with your tracking ID.
        [[GAI sharedInstance] trackerWithTrackingId:@"UA-53770107-1"];
        
        self.tracker = [[GAI sharedInstance] defaultTracker];
	}
    
	return self;
}

#pragma mark -

- (void)screenDisplayed:(BAAnalyticsScreen)screen
{
    NSString *stringValue = [self stringForScreen:screen];
    if (stringValue)
    {
        [self.tracker set:kGAIScreenName value:stringValue];
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
        [self.tracker set:kGAIScreenName value:nil];
    }
}

- (void)eventWithCategory:(BAAnalyticsCategory)category action:(NSString*)action
{
    [self eventWithCategory:category action:action label:nil];
}

- (void)eventWithCategory:(BAAnalyticsCategory)category action:(NSString*)action label:(NSString*)label
{
    [self eventWithCategory:category action:action label:label number:nil];
}

- (void)eventWithCategory:(BAAnalyticsCategory)category action:(NSString*)action label:(NSString*)label number:(NSNumber*)number
{
    NSString *stringValue = [self stringForCategory:category];
    if (stringValue && action)
    {
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:stringValue action:action label:label value:number] build]];
    }
}

- (void)timingWithCategory:(BAAnalyticsCategory)category interval:(NSTimeInterval)interval name:(NSString*)name
{
    [self timingWithCategory:category interval:interval name:name label:nil];
}

- (void)timingWithCategory:(BAAnalyticsCategory)category interval:(NSTimeInterval)interval name:(NSString*)name label:(NSString*)label
{
    NSString *stringValue = [self stringForCategory:category];
    if (stringValue && (interval > 0))
    {
        [self.tracker send:[[GAIDictionaryBuilder createTimingWithCategory:stringValue interval:[NSNumber numberWithDouble:interval] name:name label:label] build]];
    }
}

- (NSString*)stringForScreen:(BAAnalyticsScreen)screen
{
    switch (screen)
    {
        case BAAnalyticsScreenNearby:           return @"Nearby Bars Screen";
        case BAAnalyticsScreenSearch:           return @"Search Bars Screen";
        case BAAnalyticsScreenNew:              return @"New Bars Screen";
        case BAAnalyticsScreenBarDetails:       return @"Bar Details Screen";
        case BAAnalyticsScreenMap:              return @"Map Screen";
        case BAAnalyticsScreenFavourites:       return @"Favourites Screen";
        case BAAnalyticsScreenHelp:             return @"Help Screen";
        case BAAnalyticsScreenMenu:             return @"Menu Screen";
    }
    
    return nil;
}

- (NSString*)stringForCategory:(BAAnalyticsCategory)category
{
    switch (category)
    {
        case BAAnalyticsCategoryTiming:                     return @"Timing";
        case BAAnalyticsCategoryBarsInteraction:            return @"Bars Screen Interactions";
        case BAAnalyticsCategoryBarDetailsInteraction:      return @"Bar Details Screen Interactions";
        case BAAnalyticsCategoryMapInteraction:             return @"Map Screen Interactions";
        case BAAnalyticsCategoryMenuInteraction:            return @"Menu Screen Interactions";
        case BAAnalyticsCategoryFavouritesInteraction:      return @"Favourites Screen Interactions";
        case BAAnalyticsCategoryHelpInteraction:            return @"Help Screen Interactions";
    }
    
    return nil;
}

@end
