//
//  NSNumber+PRSocialURLCoding.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSString+PRSocialURLCoding.h"
#import "NSNumber+PRSocialURLCoding.h"

@implementation NSNumber (PRSocialURLCoding)

- (NSString *)prs_URLEncodedString
{
    return self.stringValue.prs_URLEncodedString;
}

@end
