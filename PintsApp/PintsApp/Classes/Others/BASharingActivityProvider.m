//
//  BASharingActivityProvider.m
//  EmeraldStreet
//
//  Created by Sandip on 08/03/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BASharingActivityProvider.h"

@implementation BASharingActivityProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
 
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id375380948";
    
    NSString *barName = [self.barData valueForKey:kBarTitleKey];
    if (0 == barName.length)
        barName = @"";
    
    NSString *barWebsite =  [[self.barData valueForKey:kBarWebsiteUrlKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (0 == barWebsite.length)
        barWebsite = @"";
    
    NSString *shareString = [NSString stringWithFormat:@"Check out %@: %@ via the @Shortlist #pintsandpistachios app: %@", barName, barWebsite, iTunesLink];
    
//    if ([activityType isEqualToString:UIActivityTypePostToFacebook])
//    {
//        shareString = [NSString stringWithFormat:@"Check out %@: %@ via the @Shortlist #pintsandpistachios app: %@", barName, barWebsite, iTunesLink];
//    }
//    else if ([activityType isEqualToString:UIActivityTypePostToTwitter])
//    {
//          shareString = [NSString stringWithFormat:@"Check out %@: %@ via the @Shortlist #pintsandpistachios app: %@", barName, barWebsite, iTunesLink];
//    }
//    else if ([activityType isEqualToString:UIActivityTypeMail])
//    {
//        shareString = [[self.barData valueForKey:kBarWebsiteUrlKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        if (0 == shareString.length)
//            shareString = [NSString stringWithFormat:@"%@ %@", [[self.barData valueForKey:kBarTitleKey] uppercaseString], [self.barData valueForKey:kBarStandFirstKey]];
//    }
    
    return shareString;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

@end
