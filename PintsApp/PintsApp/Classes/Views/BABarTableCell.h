//
//  BABarTableCell.h
//  EmeraldStreet
//
//  Created by Sandip on 13/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BABarTableCell;

@protocol BABarTableCellDelegate <NSObject>

- (void)mapButtonTappedOnBarTableCell:(BABarTableCell *)cell;
- (void)shareButtonTappedOnBarTableCell:(BABarTableCell *)cell;

@optional

- (void)favButtonTappedOnBarTableCell:(BABarTableCell *)cell;

@end

@interface BABarTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPrimary;
@property (strong, nonatomic) IBOutlet UILabel *labelHeader;
@property (strong, nonatomic) IBOutlet UILabel *labelSubheader;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UIButton *buttonFavourite;

@property (nonatomic, weak) id <BABarTableCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *barData;

@end
