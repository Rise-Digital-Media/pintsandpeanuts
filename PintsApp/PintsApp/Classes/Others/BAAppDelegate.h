//
//  BAAppDelegate.h
//  EmeraldStreet
//
//  Created by Sandip on 12/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSMutableArray *favourites;
@property (nonatomic, strong) NSNumber *settingsId;
@property (nonatomic, assign) BOOL receiveEmeraldStreetFlag;
@property (nonatomic, strong) NSString *settingsEmail;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) NSMutableArray *barsNearbyResult;
@property (nonatomic, strong) NSMutableArray *barsSearchResult;
@property (nonatomic, strong) NSMutableArray *barsNewResult;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+ (NSString *)machineName;
- (void)saveUserDefaults;

@end
