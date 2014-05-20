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

NSString * const kPRSocialConfigKeyOAuthClientID = @"ClientID";
NSString * const kPRSocialConfigKeyOAuthClientSecret = @"ClientSecret";
NSString * const kPRSocialConfigKeyOAuthRedirectURI = @"RedirectURI";
NSString * const kPRSocialConfigKeyOAuthScope = @"Scope";

@interface PRSocialConfig ()

@property (nonatomic, strong) NSMutableDictionary *configs;
@property (nonatomic, strong) NSMutableDictionary *URLSchemes;
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

- (void)setServiceName:(NSString *)serviceName forURLScheme:(NSString *)scheme
{
    @synchronized(self.URLSchemes) {
        [self.URLSchemes setValue:serviceName forKey:scheme];
    }
}

- (NSString *)serviceNameForURLScheme:(NSString *)scheme
{
    NSString *serviceName;
    @try {
        serviceName = self.URLSchemes[scheme];
    }
    @catch (NSException *exception) {
        NSLog(@"%s Failed to get service name for URL scheme \"%@\": %@", __PRETTY_FUNCTION__, scheme, exception.reason);
    }
    return serviceName;
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
        _URLSchemes = [[NSMutableDictionary alloc] init];
        _configQueue = dispatch_queue_create("PRSocialConfigQueue", NULL);
    }
    return self;
}

@end
