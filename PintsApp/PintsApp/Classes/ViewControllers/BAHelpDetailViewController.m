//
//  BAHelpDetailViewController.m
//  EmeraldStreet
//
//  Created by Sandip on 15/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BAHelpDetailViewController.h"

@interface BAHelpDetailViewController ()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)backButtonTapped:(UIButton *)sender;

@end

@implementation BAHelpDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.viewHeader.bounds];
    self.viewHeader.layer.masksToBounds = NO;
    self.viewHeader.layer.shadowColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.viewHeader.layer.shadowOpacity = 0.5f;
    self.viewHeader.layer.shadowPath = shadowPath.CGPath;

    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    
    for(UIView *wview in [[[self.webView subviews] objectAtIndex:0] subviews])
        if([wview isKindOfClass:[UIImageView class]])
            wview.hidden = YES;
    
    NSString *htmlFilename = nil;
    
    if (BAHelpContactUs == self.helpType)
    {
        htmlFilename = @"contact_us";
    }
    else if (BAHelpInstructions == self.helpType)
    {
        htmlFilename = @"instructions";
    }
    else if (BAHelpLegal == self.helpType)
    {
        htmlFilename = @"legal";
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:htmlFilename ofType:@"html"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    [self.webView loadHTMLString:content baseURL:nil];
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

@end
