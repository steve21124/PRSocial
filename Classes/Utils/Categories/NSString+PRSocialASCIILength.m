//
//  NSString+PRSocialASCIILength.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSString+PRSocialASCIILength.h"

@implementation NSString (PRSocialASCIILength)

- (NSUInteger)asciiLength
{
    NSUInteger length = 0;
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar uc = [self characterAtIndex:i];
        length += isascii(uc) ? 1 : 2;
    }
    return length;
}

@end
