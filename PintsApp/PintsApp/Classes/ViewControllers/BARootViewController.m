//
//  BARootViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 13/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BARootViewController.h"
#import "BAMenuViewController.h"
#import "BABarsViewController.h"
#import "PSStackedView.h"

@interface BARootViewController () <BABarsViewControllerDelegete>

@property (nonatomic, strong) PSStackedViewController *stackedViewController;

@end

@implementation BARootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        
//        for (NSString* name in [UIFont fontNamesForFamilyName:family])
//        {
//            NSLog(@"  %@", name);
//        }
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (nil == self.stackedViewController)
    {
        BAMenuViewController *menuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BAMenuVC"];
        self.stackedViewController = [[PSStackedViewController alloc] initWithRootViewController:menuVC];
        self.stackedViewController.panRecognizer.enabled = NO;
        self.stackedViewController.enableBounces = NO;
        self.stackedViewController.enableShadows = NO;
        self.stackedViewController.largeLeftInset = 270.0;
        self.stackedViewController.leftInset = 0.0;
        [self addChildViewController:self.stackedViewController];
        [self.view addSubview:self.stackedViewController.view];
        self.stackedViewController.view.frame = self.view.bounds;
        
        UINavigationController *masterNC = [self.storyboard instantiateViewControllerWithIdentifier:@"BarsNC"];
        BABarsViewController *masterVC = (BABarsViewController *)masterNC.topViewController;
        masterVC.delegate = self;
        [self.stackedViewController pushViewController:masterNC animated:NO];
        masterNC.view.frame = self.stackedViewController.view.bounds;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BABarsViewControllerDelegete

- (void)didTapMenuOnBarsViewController:(BABarsViewController *)viewController
{
    if ([self.stackedViewController.fullyVisibleViewControllers containsObject:viewController.navigationController])
    {
        [self.stackedViewController expandStack:1 animated:YES];
        [viewController disableUserIntercation:YES];
    }
    else if([self.stackedViewController.visibleViewControllers containsObject:viewController.navigationController])
    {
        [self.stackedViewController collapseStack:1 animated:YES];
        [viewController disableUserIntercation:NO];
    }
}

@end
