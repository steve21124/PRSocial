//
//  NSObject+PRSocialJSONKeyPath.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/21/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSObject+PRSocialJSONKeyPath.h"

@implementation NSObject (PRSocialJSONKeyPath)

- (id)prs_objectWithJSONKeyPath:(NSString *)keyPath
{
    id result = self;
    NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@".."];
    for (NSString *keyPathComponent in keyPathComponents) {
        NSInteger indexPart = -1;
        NSString *keyPathPart;
        
        // Parse index and key path
        if (![keyPathComponents indexOfObject:keyPathComponent] &&
            [keyPathComponent characterAtIndex:0] != '.') {
            keyPathPart = keyPathComponent;
        } else {
            NSUInteger startIndex = (NSUInteger)([keyPathComponent characterAtIndex:0] == '.');
            NSUInteger dotIndex;
            for (dotIndex = startIndex; dotIndex < keyPathComponent.length; dotIndex++) {
                if ([keyPathComponent characterAtIndex:dotIndex] == '.') {
                    break;
                }
            }
            
            if (dotIndex == keyPathComponent.length) {
                indexPart = [[keyPathComponent substringFromIndex:startIndex] integerValue];
            } else {
                indexPart = [[keyPathComponent substringWithRange:NSMakeRange(startIndex, dotIndex - startIndex)] integerValue];
                keyPathPart = [keyPathComponent substringFromIndex:dotIndex + 1];
            }
        }
        
        // Use index and key path if available
        if (indexPart != -1) {
            @try {
                result = result[indexPart];
            }
            @catch (NSException *exception) {
                NSLog(@"%s Error evaluating index: %@", __PRETTY_FUNCTION__, exception.reason);
                return nil;
            }
        }
        if (keyPathPart) {
            @try {
                result = [result valueForKeyPath:keyPathPart];
            }
            @catch (NSException *exception) {
                NSLog(@"%s Error evaluating key path: %@", __PRETTY_FUNCTION__, exception.reason);
                return nil;
            }
        }
    }
    
    return result;
}

@end
