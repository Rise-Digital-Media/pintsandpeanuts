//
//  BAAnalytics.h
//  PintsApp
//
//  Created by Sandip on 18/08/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    BAAnalyticsScreenNearby,
    BAAnalyticsScreenSearch,
    BAAnalyticsScreenNew,
    BAAnalyticsScreenBarDetails,
    BAAnalyticsScreenMap,
    BAAnalyticsScreenFavourites,
    BAAnalyticsScreenHelp,
    BAAnalyticsScreenMenu
} BAAnalyticsScreen;

typedef enum
{
    BAAnalyticsCategoryTiming,
    BAAnalyticsCategoryBarsInteraction,
    BAAnalyticsCategoryBarDetailsInteraction,
    BAAnalyticsCategoryMapInteraction,
    BAAnalyticsCategoryMenuInteraction,
    BAAnalyticsCategoryFavouritesInteraction,
    BAAnalyticsCategoryHelpInteraction
} BAAnalyticsCategory;

#define kBAAnalyticsActionTappedMenu @"Tapped on Menu Icon"
#define kBAAnalyticsActionChangedUserLocation @"User Location Changed"
#define kBAAnalyticsActionTappedMap @"Tapped on Map Icon"
#define kBAAnalyticsActionTappedShare @"Tapped on Share Icon"
#define kBAAnalyticsActionTappedFavourite @"Tapped on Favourite Icon"
#define kBAAnalyticsActionTappedBar @"Tapped on a Bar"
#define kBAAnalyticsActionScrolledBars @"Scrolled Bars"
#define kBAAnalyticsActionTappedBarAddress @"Tapped on a Bar Address"
#define kBAAnalyticsActionSearchedBars @"Searched Bars"
#define kBAAnalyticsActionTappedFavouritesMenu @"Tapped on Favourites Menu"
#define kBAAnalyticsActionTappedHelpMenu @"Tapped on Help Menu"
#define kBAAnalyticsActionTappedContactUsMenu @"Tapped on Contact Us Menu"
#define kBAAnalyticsActionTappedInstructionsMenu @"Tapped on Instructions Menu"
#define kBAAnalyticsActionTappedPrivacyMenu @"Tapped on Privacy Menu"

#define kBAAnalyticsLabelAddedFavourite @"Added Favourite"
#define kBAAnalyticsLabelRemovedFavourite @"Removed Favourite"

#define kBAAnalyticsTimingNearbyAPI @"Time took to get Nearby bar response"
#define kBAAnalyticsTimingSearchAPI @"Time took to get Seached bar response"
#define kBAAnalyticsTimingNewAPI @"Time took to get New bar response"

@interface BAAnalytics : NSObject

+ (BAAnalytics *)sharedInstance;

- (void)screenDisplayed:(BAAnalyticsScreen)screen;
- (void)eventWithCategory:(BAAnalyticsCategory)category action:(NSString*)action;
- (void)eventWithCategory:(BAAnalyticsCategory)category action:(NSString*)action label:(NSString*)label;
- (void)eventWithCategory:(BAAnalyticsCategory)category action:(NSString*)action label:(NSString*)label number:(NSNumber*)number;
- (void)timingWithCategory:(BAAnalyticsCategory)category interval:(NSTimeInterval)interval name:(NSString*)name;
- (void)timingWithCategory:(BAAnalyticsCategory)category interval:(NSTimeInterval)interval name:(NSString*)name label:(NSString*)label;

@end
