//
//  BAFavouritesViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAFavouritesViewController.h"
#import "BABarDetailViewController.h"
#import "BABarTableCell.h"
#import "BAMapViewController.h"
#import "BADataStore.h"
#import "BASharingActivityProvider.h"

@interface BAFavouritesViewController () <BABarTableCellDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *labelNoResults;

- (IBAction)backButtonTapped:(UIButton *)sender;

@end

@implementation BAFavouritesViewController

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
	
    [[BAAnalytics sharedInstance] screenDisplayed:BAAnalyticsScreenFavourites];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.viewHeader.bounds];
    self.viewHeader.layer.masksToBounds = NO;
    self.viewHeader.layer.shadowColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.viewHeader.layer.shadowOpacity = 0.5f;
    self.viewHeader.layer.shadowPath = shadowPath.CGPath;
    
    self.labelNoResults.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favouriteDidChangeNotification:) name:kFavouriteDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath)
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFavouriteDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowBarDetailVCFromFavouritesVC"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        if (indexPath)
        {
            BABarTableCell *cell = (BABarTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            if (cell)
            {
                BABarDetailViewController *viewController = segue.destinationViewController;
                viewController.imageBar = cell.imageViewPrimary.image;
                viewController.barData = cell.barData;
            }
        }
    }
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (void)favouriteDidChangeNotification:(NSNotification *)notification
{
    NSDictionary *barData = [notification object];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath)
    {
        BABarTableCell *cell = (BABarTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell)
        {
            if ([[barData valueForKey:kBarIdKey] integerValue] == [[cell.barData valueForKey:kBarIdKey] integerValue])
            {
                [[BADataStore getFavourites] removeObject:cell.barData];
                
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numOfRows = [BADataStore getFavourites].count;
    self.labelNoResults.hidden = (numOfRows > 0);
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BABarTableCell *cell = (BABarTableCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.delegate = self;
    cell.barData = [[BADataStore getFavourites] objectAtIndex:indexPath.row];;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowBarDetailVCFromFavouritesVC" sender:self];
}

#pragma mark - BABarTableCellDelegate

- (void)mapButtonTappedOnBarTableCell:(BABarTableCell *)cell
{
    [[BAAnalytics sharedInstance] eventWithCategory:BAAnalyticsCategoryFavouritesInteraction action:kBAAnalyticsActionTappedMap];
    
    BAMapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BAMapVC"];
    mapVC.data = cell.barData;
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (void)shareButtonTappedOnBarTableCell:(BABarTableCell *)cell
{
    [[BAAnalytics sharedInstance] eventWithCategory:BAAnalyticsCategoryFavouritesInteraction action:kBAAnalyticsActionTappedShare];
    
    BASharingActivityProvider *sharingActivityProvider = [[BASharingActivityProvider alloc] init];
    sharingActivityProvider.barData = cell.barData;
    
    NSArray *activityItems = nil;
    
    if (cell.imageViewPrimary.image)
        activityItems = @[sharingActivityProvider, cell.imageViewPrimary.image];
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

- (void)favButtonTappedOnBarTableCell:(BABarTableCell *)cell
{
    if (cell.buttonFavourite.selected)
    {
        [[BAAnalytics sharedInstance] eventWithCategory:BAAnalyticsCategoryFavouritesInteraction action:kBAAnalyticsActionTappedFavourite label:kBAAnalyticsLabelAddedFavourite];
    }
    else
    {
        [[BAAnalytics sharedInstance] eventWithCategory:BAAnalyticsCategoryFavouritesInteraction action:kBAAnalyticsActionTappedFavourite label:kBAAnalyticsLabelRemovedFavourite];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (indexPath)
        {
            NSDictionary *barData = cell.barData;
            
            [[BADataStore getFavourites] removeObject:barData];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFavouriteDidChangeNotification object:barData];
        }
    }
}

@end
