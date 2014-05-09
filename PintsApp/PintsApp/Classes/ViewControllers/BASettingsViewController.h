//
//  BASettingsViewController.h
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BASettingsViewController;

@protocol BASettingsViewControllerDelegate <NSObject>

- (void)dismissSettingsViewController:(BASettingsViewController *)viewController withReceive:(BOOL)receive andEmail:(NSString *)email;

@end

@interface BASettingsViewController : UIViewController

@property (nonatomic, weak) id <BASettingsViewControllerDelegate> delegate;

@end
