//
//  BABarsViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 12/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BABarsViewController.h"
#import "BABarDetailViewController.h"
#import "BABarTableCell.h"
#import "BALocationManager.h"
#import "BAMapViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "BAHTTPAuditor.h"
#import "BADataStore.h"
#import "BASharingActivityProvider.h"

typedef enum
{
    BASegmentNearby = 0,
    BASegmentSearch,
    BASegmentNew
} BASegmentType;

#define kRowHeight 200.0

@interface BABarsViewController () <BABarTableCellDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewOverlay;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewHeader;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *buttonNearby;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearch;
@property (strong, nonatomic) IBOutlet UIButton *buttonNew;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSearch;
@property (strong, nonatomic) IBOutlet UILabel *labelNoResults;
@property (strong, nonatomic) IBOutlet UIView *activityView;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewBlankSearch;
@property (strong, nonatomic) UIButton *buttonSelectedSegment;
@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) AFJSONRequestOperation *requestOperation;
@property (nonatomic, strong) NSMutableArray *allData;
@property (nonatomic, assign) BOOL shouldDownloadData;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (IBAction)segmentButtonTapped:(UIButton *)sender;
- (IBAction)menuButtonTapped:(UIButton *)sender;

@end

@implementation BABarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (nil == self.httpClient)
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.google.com"]];
    
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.imageViewHeader.bounds];
//    self.imageViewHeader.layer.masksToBounds = NO;
//    self.imageViewHeader.layer.shadowColor = [UIColor grayColor].CGColor;
//    self.imageViewHeader.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
//    self.imageViewHeader.layer.shadowOpacity = 0.5f;
//    self.imageViewHeader.layer.shadowPath = shadowPath.CGPath;

    self.textFieldSearch.layer.cornerRadius = 3.0;
    self.textFieldSearch.layer.masksToBounds = YES;
    
    
    CGRect activityViewShadowRect = self.activityView.bounds;
    activityViewShadowRect.origin.x = 8.0;
    activityViewShadowRect.origin.y = activityViewShadowRect.size.height - 10.0;
    activityViewShadowRect.size.width -= 16.0;
    activityViewShadowRect.size.height = 10.0;
    UIBezierPath *activityViewShadowPath = [UIBezierPath bezierPathWithRect:activityViewShadowRect];
    self.activityView.layer.masksToBounds = NO;
    self.activityView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.activityView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.activityView.layer.shadowOpacity = 0.5f;
    self.activityView.layer.shadowPath = activityViewShadowPath.CGPath;
    self.activityView.layer.cornerRadius = 10.0;
    
    self.buttonNearby.titleLabel.font = [UIFont fontWithName:@"Gotham-Book" size:12.0];
    self.buttonSearch.titleLabel.font = [UIFont fontWithName:@"Gotham-Book" size:12.0];
    self.buttonNew.titleLabel.font = [UIFont fontWithName:@"Gotham-Book" size:12.0];
    self.textFieldSearch.font = [UIFont fontWithName:@"Gotham-Book" size:12.0];
    self.labelNoResults.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
    
    if (nil == self.buttonSelectedSegment)
        self.buttonSelectedSegment = self.buttonNearby;
    
    if (nil == self.allData)
    {
        self.allData = [[NSMutableArray alloc] initWithCapacity:0];
        
        BOOL shouldDownloadServerData = YES;
        self.coordinate = [BADataStore getCoordinate];
        
        if (AFNetworkReachabilityStatusNotReachable == [self.httpClient networkReachabilityStatus])
        {
            shouldDownloadServerData = NO;
        }
        else if ([BALocationManager isValidCoordinate:self.coordinate])
        {
            CLLocationCoordinate2D coordinate = [BALocationManager getCurrentCoordinate];
            
            if ([BALocationManager isValidCoordinate:coordinate])
            {
                shouldDownloadServerData = !((coordinate.longitude == self.coordinate.longitude) && (coordinate.latitude == self.coordinate.latitude));
            }
            else
            {
                shouldDownloadServerData = NO;
            }
        }
        
        if (!shouldDownloadServerData)
        {
            NSArray *lastResult = [BADataStore getNearbyResult];
            
            if (lastResult.count)
            {
                [self addRowsWithObjects:lastResult];
                shouldDownloadServerData = NO;
            }
        }
        
        if (shouldDownloadServerData)
        {
            [self downloadServerData];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerDidUpdateNotification:) name:kLocationManagerDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favouriteDidChangeNotification:) name:kFavouriteDidChangeNotification object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationManagerDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFavouriteDidChangeNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowBarDetailVCFromBarVC"])
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

- (IBAction)segmentButtonTapped:(UIButton *)sender
{
    NSUInteger selectedTag = self.buttonSelectedSegment.tag;
    
    if (selectedTag != sender.tag)
    {
        [kAppDelegate saveUserDefaults];
        
        self.buttonSelectedSegment.selected = YES;
        self.buttonSelectedSegment = sender;
        self.buttonSelectedSegment.selected = NO;
        
        [self.allData removeAllObjects];
        [self.tableView reloadData];
        
        self.activityView.hidden = YES;
        self.labelNoResults.hidden = YES;
        
        [self.requestOperation cancel];
        self.requestOperation = nil;
        
        if (BASegmentSearch == self.buttonSelectedSegment.tag)
        {
            CGRect tableViewFrame = self.tableView.frame;
            tableViewFrame.origin.y = self.textFieldSearch.frame.origin.y + self.textFieldSearch.frame.size.height + 2.0;
            tableViewFrame.size.height = self.view.frame.size.height - tableViewFrame.origin.y;
            self.tableView.frame = tableViewFrame;
            
            self.textFieldSearch.hidden = NO;
            self.textFieldSearch.text = kAppDelegate.searchText;
            
            if (self.textFieldSearch.text.length)
            {
                NSArray *lastResult = [BADataStore getSearchResult];
                if (lastResult.count)
                    [self addRowsWithObjects:lastResult];
                else
                    [self downloadServerData];
            }
        }
        else
        {
            CGRect tableViewFrame = self.tableView.frame;
            tableViewFrame.origin.y = self.textFieldSearch.frame.origin.y - 2.0;
            tableViewFrame.size.height = self.view.frame.size.height - tableViewFrame.origin.y;
            self.tableView.frame = tableViewFrame;
            
            [self.textFieldSearch resignFirstResponder];
            self.textFieldSearch.text = @"";
            self.textFieldSearch.hidden = YES;
            
            if (BASegmentNearby == self.buttonSelectedSegment.tag)
            {
                BOOL shouldDownloadServerData = YES;
                self.coordinate = [BADataStore getCoordinate];
                
                if (AFNetworkReachabilityStatusNotReachable == [self.httpClient networkReachabilityStatus])
                {
                    shouldDownloadServerData = NO;
                }
                else
                {
                    if ([BALocationManager isValidCoordinate:self.coordinate])
                    {
                        CLLocationCoordinate2D coordinate = [BALocationManager getCurrentCoordinate];
                        
                        if ([BALocationManager isValidCoordinate:coordinate])
                        {
                            shouldDownloadServerData = !((coordinate.longitude == self.coordinate.longitude) && (coordinate.latitude == self.coordinate.latitude));
                        }
                        else
                        {
                            shouldDownloadServerData = NO;
                        }
                    }
                }
                
                if (!shouldDownloadServerData)
                {
                    NSArray *lastResult = [BADataStore getNearbyResult];
                    
                    if (lastResult.count)
                    {
                        [self addRowsWithObjects:lastResult];
                        shouldDownloadServerData = NO;
                    }
                }
                
                if (shouldDownloadServerData)
                {
                    [self downloadServerData];
                }
            }
            else if (BASegmentNew == self.buttonSelectedSegment.tag)
            {
                NSArray *lastResult = [BADataStore getNewResult];
                if (lastResult.count)
                    [self addRowsWithObjects:lastResult];
                else
                    [self downloadServerData];
            }
        }
    }
}

- (IBAction)menuButtonTapped:(UIButton *)sender
{
    [self.textFieldSearch resignFirstResponder];
    [self.delegate didTapMenuOnBarsViewController:self];
}

- (void)disableUserIntercation:(BOOL)disable;
{
    self.viewOverlay.hidden = !disable;
}

#pragma mark -

- (void)locationManagerDidUpdateNotification:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(locationManagerDidUpdate) withObject:nil waitUntilDone:NO];
}

- (void)locationManagerDidUpdate
{
    if (BASegmentNearby == self.buttonSelectedSegment.tag)
    {
        if (self.shouldDownloadData)
        {
            [self downloadServerData];
        }
        else if ([self.httpClient networkReachabilityStatus] != AFNetworkReachabilityStatusNotReachable)
        {
            CLLocationCoordinate2D coordinate = [BALocationManager getCurrentCoordinate];
            if ([BALocationManager isValidCoordinate:coordinate] && ((coordinate.latitude != self.coordinate.latitude) || (coordinate.longitude != self.coordinate.longitude)))
            {
                [self.allData removeAllObjects];
                [self.tableView reloadData];
                
                self.labelNoResults.hidden = YES;
                
                [self.requestOperation cancel];
                self.requestOperation = nil;
                
                [self downloadServerData];
            }
        }
    }
}

- (void)favouriteDidChangeNotification:(NSNotification *)notification
{
    NSDictionary *barData = [notification object];

    NSArray *visibleCells = [self.tableView visibleCells];
    for (BABarTableCell *cell in visibleCells)
    {
        if ([[barData valueForKey:kBarIdKey] integerValue] == [[cell.barData valueForKey:kBarIdKey] integerValue])
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            
            if (indexPath)
            {
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];                    
            }
            
            break;
        }
    }
}

- (void)downloadServerData
{
    self.shouldDownloadData = NO;
    __weak BABarsViewController *weakSelf = self;

    NSString *urlString = nil;
    
    if (BASegmentNearby == self.buttonSelectedSegment.tag)
    {
        BOOL shouldDownload = NO;
        
        if ([BALocationManager hasCurrentCoordinate])
        {
            self.coordinate = [BALocationManager getCurrentCoordinate];
            shouldDownload = YES;
        }
        else if ([BALocationManager isValidCoordinate:self.coordinate])
        {
            shouldDownload = YES;
        }
        
        if (shouldDownload)
        {
            urlString = [NSString stringWithFormat:@"%@%@/nearest?latitude=%f&longitude=%f&top=10&skip=%i", kBaseURLString, kAPIPathString, self.coordinate.latitude, self.coordinate.longitude, self.allData.count];
        }
        else
        {
            self.activityView.hidden = NO;

            self.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
            self.shouldDownloadData = YES;
        }
    }
    else if (BASegmentSearch == self.buttonSelectedSegment.tag)
    {
        NSString *searchText = [self.textFieldSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.textFieldSearch.text = searchText;
        
        if (searchText.length)
        {
            NSString *urlEncodedString = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            urlString = [NSString stringWithFormat:@"%@%@?$filter=substringof('%@',Title)%%20or%%20substringof('%@',StandFirst)&$top=10&$skip=%i", kBaseURLString, kAPIPathString, urlEncodedString, urlEncodedString, self.allData.count];
        }
    }
    else if (BASegmentNew == self.buttonSelectedSegment.tag)
    {
        urlString = [NSString stringWithFormat:@"%@%@?$orderby=LiveDate%%20desc&$top=10&$skip=%i", kBaseURLString, kAPIPathString, self.allData.count];
    }
    
    if (urlString.length)
    {
        //NSLog(@"urlString\n%@", urlString);
        
        self.activityView.hidden = NO;
        
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [urlRequest setValue:@"f3590938-9ad9-4168-9646-d02b67a95103" forHTTPHeaderField:@"api-key"];
        
        [self.requestOperation cancel];
        
        self.requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            if ([weakSelf.requestOperation.request.URL.absoluteString isEqualToString:request.URL.absoluteString])
            {
                NSArray *bars = [JSON isKindOfClass:[NSArray class]]?JSON:[NSArray arrayWithObject:JSON];
                [weakSelf addRowsWithObjects:bars];
                weakSelf.requestOperation = nil;
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         
            [BAHTTPAuditor postError:error];
            
            if ([weakSelf.requestOperation.request.URL.absoluteString isEqualToString:request.URL.absoluteString])
            {
                [weakSelf addRowsWithObjects:nil];
                weakSelf.requestOperation = nil;
            }
        }];
        
        [self.requestOperation start];
    }
}

- (void)addRowsWithObjects:(NSArray *)objects
{
    self.activityView.hidden = YES;
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSDictionary *object in objects)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:self.allData.count inSection:0]];
        [self.allData addObject:object];
    }
    
    if (indexPaths.count)
    {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    
    if (BASegmentSearch == self.buttonSelectedSegment.tag)
    {
        self.imageViewBlankSearch.hidden = (self.allData.count > 0);
    }
    else
    {
        self.labelNoResults.hidden = (self.allData.count > 0);
    }
    
    if (objects)
    {
        if (BASegmentNearby == self.buttonSelectedSegment.tag)
        {
            [BADataStore storeCoordinate:self.coordinate];
            [BADataStore storeNearbyResult:[self.allData copy]];
        }
        else if (BASegmentSearch == self.buttonSelectedSegment.tag)
        {
            [BADataStore storeSearchText:self.textFieldSearch.text];
            [BADataStore storeSearchResult:[self.allData copy]];
        }
        else if (BASegmentNew == self.buttonSelectedSegment.tag)
        {
            [BADataStore storeNewResult:[self.allData copy]];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BABarTableCell *cell = (BABarTableCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.delegate = self;
    cell.barData = [self.allData objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

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
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowBarDetailVCFromBarVC" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((nil == self.requestOperation) && (self.allData.count > 1))
    {
        CGFloat offsetY = 0;
        
        if (self.allData.count >= 6)
            offsetY = kRowHeight * 3.0;
        else if (self.allData.count > 3)
            offsetY = kRowHeight * (self.allData.count - 3.0);
        
        CGFloat actualPosition = scrollView.contentOffset.y;
        CGFloat contentHeight = scrollView.contentSize.height - self.tableView.bounds.size.height - offsetY;
        
        if (actualPosition >= contentHeight)
        {
            if (nil == self.requestOperation)
                [self downloadServerData];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.imageViewBlankSearch.hidden = YES;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
    [self.allData removeAllObjects];
    [self.tableView reloadData];
    [self addRowsWithObjects:[NSArray array]];
    
    self.imageViewBlankSearch.hidden = YES;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    [self.allData removeAllObjects];
    [self.tableView reloadData];
    [self downloadServerData];
    
    return YES;
}

#pragma mark - BABarTableCellDelegate

- (void)mapButtonTappedOnBarTableCell:(BABarTableCell *)cell
{
    BAMapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BAMapVC"];
    mapVC.data = cell.barData;
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (void)shareButtonTappedOnBarTableCell:(BABarTableCell *)cell
{
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

@end
