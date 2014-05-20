//
//  PRSocialConfig.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialConfig.h"

NSString * const kPRSocialConfigKeyAppID = @"AppID";
NSString * const kPRSocialConfigKeyAppDescription = @"AppDescription";

@interface PRSocialConfig ()

@property (nonatomic, strong) NSMutableDictionary *configs;
@property (nonatomic, strong) dispatch_queue_t configQueue;

@end

@implementation PRSocialConfig

- (id)valueForKey:(NSString *)key forServiceName:(NSString *)serviceName
{
    id value;
    @try {
        value = self.configs[serviceName][key];
    }
    @catch (NSException *exception) {
        NSLog(@"%s Failed to get value for key \"%@\" for service name \"%@\": %@", __PRETTY_FUNCTION__, key, serviceName, exception.reason);
    }
    return value;
}

- (void)setValue:(id)value forKey:(NSString *)key forServiceName:(NSString *)serviceName
{
    dispatch_sync(self.configQueue, ^{
        if (![self.configs.allKeys containsObject:serviceName]) {
            self.configs[serviceName] = [[NSMutableDictionary alloc] init];
        }
        NSMutableDictionary *config = self.configs[serviceName];
        [config setValue:value forKey:key];
    });
}

#pragma mark - Life cycle

+ (instancetype)defaultConfig
{
    static id defaultConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultConfig = [[self alloc] init];
    });
    return defaultConfig;
}

- (id)init
{
    self = [super init];
    if (self) {
        _configs = [[NSMutableDictionary alloc] init];
        _configQueue = dispatch_queue_create("PRSocialConfigQueue", NULL);
    }
    return self;
}

@end
