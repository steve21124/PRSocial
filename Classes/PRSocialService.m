//
//  PRSocialService.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialService.h"

@implementation PRSocialService

+ (instancetype)sharedService
{
    static NSMutableDictionary *sharedServices;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServices = [[NSMutableDictionary alloc] init];
    });
    NSString *classString = NSStringFromClass(self);
    @synchronized(sharedServices) {
        if (![sharedServices.allKeys containsObject:classString]) {
            sharedServices[classString] = [[self alloc] init];
        }
    }
    return sharedServices[classString];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerService];
    }
    return self;
}

- (void)registerService
{
    
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image completion:(PRSocialCallback)completion
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

+ (void)handleOpenURL:(NSURL *)URL
{
    NSString *serviceName = [[PRSocialConfig defaultConfig] serviceNameForURLScheme:URL.scheme];
    if (serviceName) {
        Class class = NSClassFromString(serviceName);
        [[class sharedService] handleOpenURL:URL];
    }
}

- (void)handleOpenURL:(NSURL *)URL
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

@end
