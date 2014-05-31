//
//  BASharingActivityProvider.m
//  EmeraldStreet
//
//  Created by Sandip on 08/03/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BASharingActivityProvider.h"

@implementation BASharingActivityProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    NSString *shareString = @"";
    
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        shareString = self.message;
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        shareString = [NSString stringWithFormat:@"%@ via @ShortList", self.message];
    } else if ([activityType isEqualToString:UIActivityTypeMail]) {
        shareString = self.message;
    }
    
    return shareString;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

@end
