//
//  BAHelpDetailViewController.h
//  EmeraldStreet
//
//  Created by Sandip on 15/02/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    BAHelpInstructions = 0,
    BAHelpContactUs,
    BAHelpFAQS,
    BAHelpTC,
    BAHelpPrivacy
} BAHelpType;

@interface BAHelpDetailViewController : UIViewController

@property (nonatomic, assign) BAHelpType helpType;

@end
