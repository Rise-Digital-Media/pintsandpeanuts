//
//  BASettingsViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 14/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BASettingsViewController.h"
#import "BADataStore.h"

@interface BASettingsViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *labelHeader;
@property (strong, nonatomic) IBOutlet UILabel *labelSwitchYesNo;
@property (strong, nonatomic) IBOutlet UISwitch *switchYesNo;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;

- (IBAction)backButtonTapped:(UIButton *)sender;
@end

@implementation BASettingsViewController

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
    self.labelSwitchYesNo.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];
    self.textFieldEmail.font = [UIFont fontWithName:@"Gotham-Book" size:14.0];

    self.switchYesNo.on = [BADataStore getReceiveEmeraldStreetFlag];
    self.textFieldEmail.text = [BADataStore getSettingsEmail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    NSString *email = [self isValidEmail]?self.textFieldEmail.text:@"";
    [self.delegate dismissSettingsViewController:self withReceive:self.switchYesNo.on andEmail:email];
}

- (BOOL)isValidEmail
{
    NSString *textString = [self.textFieldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.textFieldEmail.text = textString;
    
    if (textString.length)
    {
        NSString *nameRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSString *lengthRegex = @"^.{6,50}$";
        
        NSPredicate *lengthPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", lengthRegex];
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
        
        if (![lengthPredicate evaluateWithObject:textString] || ![namePredicate evaluateWithObject:textString])
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL isValidEmail = [self isValidEmail];
    if (isValidEmail)
    {
        [textField resignFirstResponder];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"EMAIL" message:@"Please give proper email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    return isValidEmail;
}

@end
