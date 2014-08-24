//
//  BAAppDelegate.m
//  EmeraldStreet
//
//  Created by Sandip on 12/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <sys/utsname.h>
#import "BAAppDelegate.h"
#import "BALocationManager.h"
#import "BADataStore.h"

#define kFavouritesKey @"Favourites"
#define kSettingsIDKey @"SettingsID"
#define kReceiveEmeraldStreetKey @"ReceiveEmeraldStreet"
#define kSettingsEmailKey @"SettingsEmail"
#define kSearchTextKey @"SearchText"
#define kLatitudeNumberKey @"LatitudeNumber"
#define kLongitudeNumberKey @"LongitudeNumber"
#define kBarsNearbyResultKey @"BarsNearbyResult"
#define kBarsSearchResultKey @"BarsSearchResult"
#define kBarsNewResultKey @"BarsNewResult"

@interface BAAppDelegate ()

- (void)reloadUserDefaults;

@end

@implementation BAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BALocationManager sharedInstance];
    [BAAnalytics sharedInstance];
    
    [self reloadUserDefaults];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveUserDefaults];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveUserDefaults];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -

+ (NSString *)machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)reloadUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *favourites = [userDefaults valueForKey:kFavouritesKey];
    self.favourites = favourites.count?[NSMutableArray arrayWithArray:favourites]:[NSMutableArray arrayWithCapacity:0];
    
    self.settingsId = [userDefaults valueForKey:kSettingsIDKey];
    
    self.receiveEmeraldStreetFlag = [userDefaults boolForKey:kReceiveEmeraldStreetKey];
    
    NSString *settingsEmail = [userDefaults valueForKey:kSettingsEmailKey];
    self.settingsEmail = settingsEmail?settingsEmail:@"";
    
    NSString *searchText = [userDefaults valueForKey:kSearchTextKey];
    self.searchText = searchText?searchText:@"";
    
    id latitudeValue = [userDefaults valueForKey:kLatitudeNumberKey];
    double latitude = [latitudeValue isKindOfClass:[NSNull class]]?0:[latitudeValue doubleValue];
    id longitudeValue = [userDefaults valueForKey:kLatitudeNumberKey];
    double longitude = [longitudeValue isKindOfClass:[NSNull class]]?0:[longitudeValue doubleValue];
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    NSArray *barsNearbyResult = [userDefaults valueForKey:kBarsNearbyResultKey];
    self.barsNearbyResult = barsNearbyResult.count?[NSMutableArray arrayWithArray:barsNearbyResult]:[NSMutableArray arrayWithCapacity:0];

    NSArray *barsSearchResult = [userDefaults valueForKey:kBarsSearchResultKey];
    self.barsSearchResult = barsSearchResult.count?[NSMutableArray arrayWithArray:barsSearchResult]:[NSMutableArray arrayWithCapacity:0];

    NSArray *barsNewResult = [userDefaults valueForKey:kBarsNewResultKey];
    self.barsNewResult = barsNewResult.count?[NSMutableArray arrayWithArray:barsNewResult]:[NSMutableArray arrayWithCapacity:0];
}

- (void)saveUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:self.favourites forKey:kFavouritesKey];
    
    [userDefaults setValue:self.settingsId forKey:kSettingsIDKey];
    
    [userDefaults setBool:self.receiveEmeraldStreetFlag forKey:kReceiveEmeraldStreetKey];
    
    [userDefaults setValue:self.settingsEmail forKey:kSettingsEmailKey];
    
    [userDefaults setValue:self.searchText forKey:kSearchTextKey];
    
    [userDefaults setValue:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:kLatitudeNumberKey];
    [userDefaults setValue:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:kLongitudeNumberKey];
    
    [userDefaults setValue:[self removeNullObjectsInArray:self.barsNearbyResult] forKey:kBarsNearbyResultKey];
    [userDefaults setValue:[self removeNullObjectsInArray:self.barsSearchResult] forKey:kBarsSearchResultKey];
    [userDefaults setValue:[self removeNullObjectsInArray:self.self.barsNewResult] forKey:kBarsNewResultKey];
    
    [userDefaults synchronize];
}

- (NSMutableArray *)removeNullObjectsInArray:(NSMutableArray *)array
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *object in array)
    {
        NSMutableDictionary *newObject = [NSMutableDictionary dictionaryWithCapacity:0];
        NSArray *allKeys = [object allKeys];
        
        for (NSString *valueKey in allKeys)
        {
            id objectValue = [object valueForKey:valueKey];
            if (![objectValue isKindOfClass:[NSNull class]])
                [newObject setValue:objectValue forKey:valueKey];
        }
        
        [newArray addObject:newObject];
    }
    
    return newArray;
}

@end
