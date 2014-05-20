//
//  NSString+PRSocialURLCoding.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSNumber+PRSocialURLCoding.h"

@interface NSString (PRSocialURLCoding)

- (NSString *)prs_URLEncodedString;
- (NSString *)prs_URLDecodedString;

+ (NSString *)prs_stringWithURLEncodedDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)prs_URLDecodedDictionary;

@end
