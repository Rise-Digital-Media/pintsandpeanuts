//
//  BABarsViewController.h
//  EmeraldStreet
//
//  Created by Sandip on 12/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BABarsViewController;

@protocol BABarsViewControllerDelegete <NSObject>

- (void)didTapMenuOnBarsViewController:(BABarsViewController *)viewController;

@end

@interface BABarsViewController : UIViewController

@property (nonatomic, weak) id <BABarsViewControllerDelegete> delegate;

- (void)disableUserIntercation:(BOOL)disable;

@end
