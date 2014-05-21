//
//  NSObject+PRSocialJSONKeyPath.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/21/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PRSocialJSONKeyPath)

- (id)prs_objectWithJSONKeyPath:(NSString *)keyPath;

@end
