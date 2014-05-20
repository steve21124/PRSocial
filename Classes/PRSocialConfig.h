//
//  PRSocialConfig.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kPRSocialConfigKeyAppID;
extern NSString * const kPRSocialConfigKeyAppDescription;

@interface PRSocialConfig : NSObject

+ (instancetype)defaultConfig;

- (id)valueForKey:(NSString *)key forServiceName:(NSString *)serviceName;
- (void)setValue:(id)value forKey:(NSString *)key forServiceName:(NSString *)serviceName;

- (void)setServiceName:(NSString *)serviceName forURLScheme:(NSString *)scheme;
- (NSString *)serviceNameForURLScheme:(NSString *)scheme;

@end
