//
//  BADataStore.m
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BADataStore.h"

@implementation BADataStore

+ (NSMutableArray *)getFavourites
{
    return kAppDelegate.favourites;
}

+ (NSDictionary *)isExistsFavouriteData:(NSDictionary *)value
{
    if (value)
    {
        for (NSDictionary *favourite in kAppDelegate.favourites)
        {
            if ([[favourite valueForKey:kBarIdKey] unsignedIntegerValue] == [[value valueForKey:kBarIdKey] unsignedIntegerValue])
                return favourite;
        }
    }
    
    return nil;
}

+ (void)addFavouriteData:(NSDictionary *)value
{
    if (value)
    {
        NSDictionary *favourite = [self isExistsFavouriteData:value];
        if (favourite)
            [kAppDelegate.favourites removeObject:favourite];
        
        [kAppDelegate.favourites addObject:value];
    }
}

+ (void)removeFavouriteData:(NSDictionary *)value
{
    if (value)
    {
        NSDictionary *favourite = [self isExistsFavouriteData:value];
        if (nil == favourite)
            return;
        
        [kAppDelegate.favourites removeObject:favourite];
    }
}

+ (NSNumber *)getSettingsId
{
    return kAppDelegate.settingsId;
}

+ (void)storeSettingsId:(NSNumber *)idValue
{
    kAppDelegate.settingsId = idValue;
}

+ (BOOL)getReceiveEmeraldStreetFlag
{
    return kAppDelegate.receiveEmeraldStreetFlag;
}

+ (void)storeReceiveEmeraldStreetFlag:(BOOL)flag
{
    kAppDelegate.receiveEmeraldStreetFlag = flag;
}

+ (NSString *)getSettingsEmail
{
    return kAppDelegate.settingsEmail;
}

+ (void)storeSettingsEmail:(NSString *)email
{
    kAppDelegate.settingsEmail = email;
}

+ (NSString *)getSearchText
{
    return kAppDelegate.searchText;
}

+ (void)storeSearchText:(NSString *)searchText
{
    kAppDelegate.searchText = searchText;
}

+ (NSMutableArray *)getNearbyResult
{
    return kAppDelegate.barsNearbyResult;
}

+ (void)storeNearbyResult:(NSMutableArray *)result
{
    kAppDelegate.barsNearbyResult = result;
}

+ (NSMutableArray *)getSearchResult
{
    return kAppDelegate.barsSearchResult;
}

+ (void)storeSearchResult:(NSMutableArray *)result
{
    kAppDelegate.barsSearchResult = result;
}

+ (NSMutableArray *)getNewResult
{
    return kAppDelegate.barsNewResult;
}

+ (void)storeNewResult:(NSMutableArray *)result
{
    kAppDelegate.barsNewResult = result;
}

+ (CLLocationCoordinate2D)getCoordinate
{
    return kAppDelegate.coordinate;
}

+ (void)storeCoordinate:(CLLocationCoordinate2D)coordinate
{
    kAppDelegate.coordinate = coordinate;
}

@end
