//
//  PRSocialService.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialService.h"

NSString * const PRSocialServiceResultNotification = @"PRSocialServiceResultNotification";
NSString * const PRSocialServiceResultNotificationKeySuccess = @"PRSocialServiceResultNotificationKeySuccess";
NSString * const PRSocialServiceResultNotificationKeyInfo = @"PRSocialServiceResultNotificationKeyInfo";

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

- (BOOL)isAvailable
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
    return NO;
}

- (void)fetchUserInfoCompletion:(void (^)(BOOL, PRSocialUserInfo *))completion
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image
{
    [self shareContentWithTitle:title description:description URL:URL image:image completion:nil];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image completion:(PRSocialCallback)completion
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

+ (BOOL)handleOpenURL:(NSURL *)URL
{
    NSString *serviceName = [[PRSocialConfig defaultConfig] serviceNameForURLScheme:URL.scheme];
    if (serviceName) {
        Class class = NSClassFromString(serviceName);
        return [[class sharedService] handleOpenURL:URL];
    }
    return NO;
}

- (BOOL)handleOpenURL:(NSURL *)URL
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
    return NO;
}

@end
