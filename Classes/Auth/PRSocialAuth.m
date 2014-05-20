//
//  PRSocialAuth.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialAuth.h"

@implementation PRSocialAuth

- (void)registerSSO
{
    
}

- (void)sendSSOAuthRequest
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

- (BOOL)handleSSOAuthOpenURL:(NSURL *)URL
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
    return NO;
}

#pragma mark - External

- (BOOL)isAuthorized
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
    return NO;
}

- (void)authorizeWithCompletionHandler:(PRSocialAuthCallback)completion
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

- (void)logout
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
}

#pragma mark - Life cycle

+ (instancetype)sharedAuth
{
    static NSMutableDictionary *sharedAuths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAuths = [[NSMutableDictionary alloc] init];
    });
    NSString *classString = NSStringFromClass(self);
    @synchronized(sharedAuths) {
        if (![sharedAuths.allKeys containsObject:classString]) {
            sharedAuths[classString] = [[self alloc] init];
        }
    }
    return sharedAuths[classString];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerSSO];
    }
    return self;
}

@end
