//
//  BAHTTPAuditor.m
//  EmeraldStreet
//
//  Created by Sandip on 16/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAHTTPAuditor.h"
#import "AFJSONRequestOperation.h"

@implementation BAHTTPAuditor

+ (void)postError:(NSError *)error
{
    if ((nil == error) || [error code] == -999)
        return;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/android/error", kBaseURLString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"f3590938-9ad9-4168-9646-d02b67a95103" forHTTPHeaderField:@"api-key"];
    
    NSString *machineName = [BAAppDelegate machineName];
    NSString *osVersion = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSMutableDictionary *httpBody = [[NSMutableDictionary alloc] initWithCapacity:0];
    [httpBody setValue:[[NSDate date] description] forKey:@"Timestamp"];
    [httpBody setValue:[error localizedDescription] forKey:@"Message"];
    [httpBody setValue:[error description] forKey:@"Stacktrace"];
    [httpBody setValue:machineName forKey:@"Device"];
    [httpBody setValue:osVersion forKey:@"OS"];
    [httpBody setValue:appVersion forKey:@"AppVersion"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:nil];
    [urlRequest setHTTPBody:jsonData];
    
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
#ifdef DEBUG
        NSLog(@"JSON\n%@", JSON);
#endif
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
#ifdef DEBUG
        NSLog(@"Error\n%@", error);
#endif
    }];
    
    [requestOperation start];
}

@end
