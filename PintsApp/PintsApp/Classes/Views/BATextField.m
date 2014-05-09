//
//  BATextField.m
//  EmeraldStreet
//
//  Created by Sandip on 24/03/14.
//  Copyright (c) 2014 Sandip. All rights reserved.
//

#import "BATextField.h"

@implementation BATextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect origValue = [super textRectForBounds:bounds];
    return CGRectOffset(origValue, 0.0f, 1.5f);
}

- (CGRect) editingRectForBounds:(CGRect)bounds
{
    CGRect origValue = [super textRectForBounds:bounds];
    return CGRectOffset(origValue, 0.0f, 1.0f);
}

@end
