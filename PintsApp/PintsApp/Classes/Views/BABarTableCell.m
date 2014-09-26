//
//  BABarTableCell.m
//  EmeraldStreet
//
//  Created by Sandip on 13/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BABarTableCell.h"
#import "UIImageView+AFNetworking.h"
#import "BAHTTPAuditor.h"
#import "BADataStore.h"
#import "BALocationManager.h"

@interface BABarTableCell ()

- (IBAction)mapButtonTapped:(UIButton *)sender;
- (IBAction)shareButtonTapped:(UIButton *)sender;
- (IBAction)favButtonTapped:(UIButton *)sender;

@end

@implementation BABarTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeCell];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)mapButtonTapped:(UIButton *)sender
{
    [self.delegate mapButtonTappedOnBarTableCell:self];
}

- (IBAction)shareButtonTapped:(UIButton *)sender
{
    [self.delegate shareButtonTappedOnBarTableCell:self];
}

- (IBAction)favButtonTapped:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected)
        [BADataStore addFavouriteData:self.barData];
    else
        [BADataStore removeFavouriteData:self.barData];
    
    if ([self.delegate respondsToSelector:@selector(favButtonTappedOnBarTableCell:)])
        [self.delegate favButtonTappedOnBarTableCell:self];
}

#pragma mark -

- (void)initializeCell
{
    self.labelHeader.font = [UIFont fontWithName:@"Gotham-Book" size:12.0];
    self.labelSubheader.font = [UIFont fontWithName:@"Gotham-Book" size:10.0];
}

- (void)setBarData:(NSDictionary *)barData
{
    if ([[barData valueForKey:kBarIdKey] integerValue] != [[_barData valueForKey:kBarIdKey] integerValue])
    {
        _barData = barData;
        
        self.labelHeader.text = [[barData valueForKey:kBarTitleKey] uppercaseString];
        self.labelSubheader.text = [barData valueForKey:kBarStandFirstKey];
        
        
        id latitudeValue = [self.barData valueForKey:kBarLatitudeKey];
        double latitude = [latitudeValue isKindOfClass:[NSNull class]]?0:[latitudeValue doubleValue];
        id longitudeValue = [self.barData valueForKey:kBarLongitudeKey];
        double longitude = [longitudeValue isKindOfClass:[NSNull class]]?0:[longitudeValue doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.buttonMap.enabled = [BALocationManager isValidCoordinate:coordinate];
        
        NSString *urlString = [barData valueForKey:kBarPrimaryImageKey];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];

        __weak BABarTableCell *weakSelf = self;
        [self.imageViewPrimary setImageWithURLRequest:urlRequest placeholderImage:[UIImage imageNamed:@"awaitingimage"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            weakSelf.imageViewPrimary.image = image;
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
           
            [BAHTTPAuditor postError:error];
        }];
    }
    
    self.buttonFavourite.selected = ([BADataStore isExistsFavouriteData:self.barData] != nil);
}

@end
