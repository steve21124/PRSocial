//
//  PRTencentAuth.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 8/18/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRTencentAuth.h"
#import "PRTencentService.h"

@interface PRTencentAuth () <TencentSessionDelegate>

@property (nonatomic, strong) PRSocialAuthCallback authCompletionHandler;

@end

@implementation PRTencentAuth

- (BOOL)isAuthorized
{
    return [PRTencentService sharedService].tencentAPI.isSessionValid;
}

- (void)authorizeWithCompletionHandler:(PRSocialAuthCallback)completion
{
    if (self.isAuthorized) {
        completion(YES);
    } else {
        self.authCompletionHandler = completion;
        [self sendSSOAuthRequest];
    }
}

- (void)logout
{
    [[PRTencentOAuth sharedOAuth] logout];
}

- (void)sendSSOAuthRequest
{
    [[PRTencentService sharedService].tencentAPI authorize:@[kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]];
}

- (BOOL)handleSSOAuthOpenURL:(NSURL *)URL
{
    return [TencentOAuth HandleOpenURL:URL];
}

#pragma mark - Getters and setters

- (NSString *)userID
{
    return [PRTencentOAuth sharedOAuth].userID;
}

- (NSString *)accessToken
{
    return [PRTencentOAuth sharedOAuth].accessToken;
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogin
{
    TencentOAuth *tencentAPI = [PRTencentService sharedService].tencentAPI;
    PRTencentOAuth *tencentOAuth = [PRTencentOAuth sharedOAuth];
    tencentOAuth.userID = tencentAPI.openId;
    tencentOAuth.accessToken = tencentAPI.accessToken;
    tencentOAuth.accessTokenTimeout = tencentAPI.expirationDate;
    if (self.authCompletionHandler) {
        self.authCompletionHandler(YES);
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (self.authCompletionHandler) {
        self.authCompletionHandler(NO);
    }
}

- (void)tencentDidNotNetWork
{
    if (self.authCompletionHandler) {
        self.authCompletionHandler(NO);
    }
}

@end
