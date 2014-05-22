//
//  BAHelpViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 15/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAHelpViewController.h"
#import "BAHelpDetailViewController.h"

@interface BAHelpViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *labelHeader;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backButtonTapped:(UIButton *)sender;

@end

@implementation BAHelpViewController

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

    self.labelHeader.font = [UIFont fontWithName:@"Gotham-Book" size:16.0];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowHelpDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath)
        {
            BAHelpDetailViewController *helpDetailVC = segue.destinationViewController;
            helpDetailVC.helpType = indexPath.row;
        }
    }
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
        cell.textLabel.font = [UIFont fontWithName:@"Gotham-Book" size:15.0];
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
    
    if (BAHelpContactUs == indexPath.row)
    {
        cell.textLabel.text = @"CONTACT US";
    }
    else if (BAHelpInstructions == indexPath.row)
    {
        cell.textLabel.text = @"INSTRUCTIONS";
    }
    else if (BAHelpLegal == indexPath.row)
    {
        cell.textLabel.text = @"LEGAL";
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
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowHelpDetail" sender:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
