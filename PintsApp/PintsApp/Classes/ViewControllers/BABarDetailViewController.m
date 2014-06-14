//
//  BABarDetailViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 17/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BABarDetailViewController.h"
#import "BAMapViewController.h"
#import "BADataStore.h"
#import "BASharingActivityProvider.h"
#import "BALocationManager.h"

#define kVerticalOffset 10.0

@interface BABarDetailViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewBar;
@property (strong, nonatomic) IBOutlet UILabel *labelHeader;
@property (strong, nonatomic) IBOutlet UIButton *buttonSubheader;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UIView *viewButtons;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UIButton *buttonFav;

- (IBAction)backButtonTapped:(UIButton *)sender;
- (IBAction)subheaderButtonTapped:(UIButton *)sender;
- (IBAction)mapButtonTapped:(UIButton *)sender;
- (IBAction)shareButtonTapped:(UIButton *)sender;
- (IBAction)favButtonTapped:(UIButton *)sender;

@end

@implementation BABarDetailViewController

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

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.viewHeader.bounds];
    self.viewHeader.layer.masksToBounds = NO;
    self.viewHeader.layer.shadowColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.viewHeader.layer.shadowOpacity = 0.5f;
    self.viewHeader.layer.shadowPath = shadowPath.CGPath;
    
    self.labelHeader.font = [UIFont fontWithName:@"Georgia" size:16.0];
    [self.buttonSubheader.titleLabel setFont:[UIFont fontWithName:@"Georgia" size:12.0]];
    self.labelDescription.font = [UIFont fontWithName:@"Georgia" size:12.0];
    
    self.imageViewBar.image = self.imageBar;
    self.labelHeader.text = [[self.barData valueForKey:kBarTitleKey] uppercaseString];
    [self.buttonSubheader setTitle:[self.barData valueForKey:kBarStandFirstKey] forState:UIControlStateNormal];
    self.labelDescription.text = [self.barData valueForKey:kBarBodyKey];
    self.buttonFav.selected = ([BADataStore isExistsFavouriteData:self.barData] != nil);

    id latitudeValue = [self.barData valueForKey:kBarLatitudeKey];
    double latitude = [latitudeValue isKindOfClass:[NSNull class]]?0:[latitudeValue doubleValue];
    id longitudeValue = [self.barData valueForKey:kBarLongitudeKey];
    double longitude = [longitudeValue isKindOfClass:[NSNull class]]?0:[longitudeValue doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.buttonMap.enabled = [BALocationManager isValidCoordinate:coordinate];
    
    CGRect labelRect = self.labelDescription.frame;
    labelRect.size.height = 1000.0;
    CGRect textRect = [self.labelDescription textRectForBounds:labelRect limitedToNumberOfLines:0];
    labelRect.size.height = textRect.size.height;
    self.labelDescription.frame = labelRect;
    
    CGRect viewRect = self.viewButtons.frame;
    viewRect.origin.y = labelRect.origin.y + labelRect.size.height + kVerticalOffset;
    self.viewButtons.frame = viewRect;
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = viewRect.origin.y + viewRect.size.height + kVerticalOffset;
    self.scrollView.contentSize = contentSize;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)subheaderButtonTapped:(UIButton *)sender
{
    NSString *urlString = [[self.barData valueForKey:kBarWebsiteUrlKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)mapButtonTapped:(UIButton *)sender
{
    BAMapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BAMapVC"];
    mapVC.data = self.barData;
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (IBAction)shareButtonTapped:(UIButton *)sender
{
    BASharingActivityProvider *sharingActivityProvider = [[BASharingActivityProvider alloc] init];
    sharingActivityProvider.barData = self.barData;
    
    NSArray *activityItems = nil;
    
    if (self.imageViewBar.image)
        activityItems = @[sharingActivityProvider, self.imageViewBar.image];
    else
        activityItems = @[sharingActivityProvider];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeMessage,
                                        UIActivityTypeAssignToContact,
                                        UIActivityTypePrint,
                                        nil];
    
    [self presentViewController:activityVC animated:YES completion:NULL];
}

- (IBAction)favButtonTapped:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected)
        [BADataStore addFavouriteData:self.barData];
    else
        [BADataStore removeFavouriteData:self.barData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFavouriteDidChangeNotification object:self.barData];
}

@end
