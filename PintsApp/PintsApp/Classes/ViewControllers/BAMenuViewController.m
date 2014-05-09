//
//  BAMenuViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 13/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAMenuViewController.h"
#import "BABarsViewController.h"
#import "BAFavouritesViewController.h"
#import "BASettingsViewController.h"
#import "BALocationManager.h"
#import "AFJSONRequestOperation.h"
#import "BAHTTPAuditor.h"
#import "BADataStore.h"

#define kUserIdKey @"Id"

typedef enum
{
    BAMenuFavourites = 0,
    BAMenuHelp,
    BAMenuSettings
} BAMenuType;

@interface BAMenuViewController () <BASettingsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AFJSONRequestOperation *requestOperation;

@end

@implementation BAMenuViewController

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

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowSettingsVC"])
    {
        BASettingsViewController *settingsVC = segue.destinationViewController;
        settingsVC.delegate = self;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIView *viewSeperator = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 1.0, cell.contentView.frame.size.width, 1.0)];
        viewSeperator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        viewSeperator.backgroundColor = [UIColor lightGrayColor];
        viewSeperator.userInteractionEnabled = NO;
        [cell.contentView addSubview:viewSeperator];
    }
    
    if (BAMenuFavourites == indexPath.row)
    {
        cell.textLabel.text = @"FAVOURITES";
        cell.imageView.image = [UIImage imageNamed:@"menu_fav"];
    }
    else if (BAMenuHelp == indexPath.row)
    {
        cell.textLabel.text = @"HELP";
        cell.imageView.image = [UIImage imageNamed:@"menu_help"];
    }
    else if (BAMenuSettings == indexPath.row)
    {
        cell.textLabel.text = @"SETTINGS";
        cell.imageView.image = [UIImage imageNamed:@"menu_settings"];
    }
    
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
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (BAMenuFavourites == indexPath.row)
    {
        [self performSegueWithIdentifier:@"ShowFavouritesVC" sender:self];
    }
    else if (BAMenuHelp == indexPath.row)
    {
        [self performSegueWithIdentifier:@"ShowHelpVC" sender:self];
    }
    else if (BAMenuSettings == indexPath.row)
    {
        [self performSegueWithIdentifier:@"ShowSettingsVC" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - BASettingsViewControllerDelegate

- (void)dismissSettingsViewController:(BASettingsViewController *)viewController withReceive:(BOOL)receive andEmail:(NSString *)email
{
    [viewController dismissViewControllerAnimated:YES completion:NULL];
    
    [BADataStore storeReceiveEmeraldStreetFlag:receive];
    [BADataStore storeSettingsEmail:email];
    
    if (0 == email.length)
        return;

    __weak BAMenuViewController *weakSelf = self;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/appsettings/", kBaseURLString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"f3590938-9ad9-4168-9646-d02b67a95103" forHTTPHeaderField:@"api-key"];
    
    NSString *machineName = [BAAppDelegate machineName];
    NSString *osVersion = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
    
    NSString *region = @"";
    CLLocationCoordinate2D coordinate = [BALocationManager getCurrentCoordinate];
    if ([BALocationManager isValidCoordinate:coordinate])
        region = [NSString stringWithFormat:@"{%f, %f}", coordinate.latitude, coordinate.longitude];
    
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *screenSize = [NSString stringWithFormat:@"%.0fx%.0f", (windowSize.width * scale), (windowSize.height * scale)];
    
    NSMutableDictionary *httpBody = [[NSMutableDictionary alloc] initWithCapacity:0];
    [httpBody setValue:[[NSDate date] description] forKey:@"Date"];
    [httpBody setValue:email forKey:@"Email"];
    [httpBody setValue:machineName forKey:@"Device"];
    [httpBody setValue:osVersion forKey:@"OS"];
    [httpBody setValue:@"NA" forKey:@"GoogleRes"];
    [httpBody setValue:region forKey:@"Region"];
    [httpBody setValue:screenSize forKey:@"AppleRes"];
    [httpBody setValue:[NSNumber numberWithBool:receive] forKey:@"ReceiveEmeraldStreet"];
    
    NSNumber *idValue = [BADataStore getSettingsId];
    if (idValue)
    {
        [httpBody setValue:idValue forKey:kUserIdKey];
    }
    
//    NSLog(@"httpBody\n%@", httpBody);
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:nil];
    [urlRequest setHTTPBody:jsonData];
    
    [self.requestOperation cancel];
    
    self.requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if ([weakSelf.requestOperation.request.URL.absoluteString isEqualToString:request.URL.absoluteString])
        {
//            NSLog(@"JSON\n%@", JSON);
         
            [BADataStore storeSettingsId:[JSON valueForKey:kUserIdKey]];
            
            weakSelf.requestOperation = nil;
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        [BAHTTPAuditor postError:error];
        
        if ([weakSelf.requestOperation.request.URL.absoluteString isEqualToString:request.URL.absoluteString])
        {
            weakSelf.requestOperation = nil;
        }
    }];
    
    [self.requestOperation start];
}

@end
