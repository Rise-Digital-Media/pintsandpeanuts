//
//  BADataStore.h
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BADataStore : NSObject

+ (NSMutableArray *)getFavourites;
+ (NSDictionary *)isExistsFavouriteData:(NSDictionary *)value;
+ (void)addFavouriteData:(NSDictionary *)value;
+ (void)removeFavouriteData:(NSDictionary *)value;

+ (NSNumber *)getSettingsId;
+ (void)storeSettingsId:(NSNumber *)idValue;

+ (BOOL)getReceiveEmeraldStreetFlag;
+ (void)storeReceiveEmeraldStreetFlag:(BOOL)flag;

+ (NSString *)getSettingsEmail;
+ (void)storeSettingsEmail:(NSString *)email;

+ (NSString *)getSearchText;
+ (void)storeSearchText:(NSString *)searchText;

+ (NSMutableArray *)getNearbyResult;
+ (void)storeNearbyResult:(NSMutableArray *)result;

+ (NSMutableArray *)getSearchResult;
+ (void)storeSearchResult:(NSMutableArray *)result;

+ (NSMutableArray *)getNewResult;
+ (void)storeNewResult:(NSMutableArray *)result;

+ (CLLocationCoordinate2D)getCoordinate;
+ (void)storeCoordinate:(CLLocationCoordinate2D)coordinate;

@end
