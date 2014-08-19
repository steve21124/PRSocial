//
//  PRWeiboAuth.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRWeiboAuth.h"
#import <WeiboSDK.h>
#import "PRWeiboService.h"

@interface PRWeiboAuth () <WeiboSDKDelegate>

@property (nonatomic, strong) PRSocialAuthCallback authCompletionHandler;

@end

@implementation PRWeiboAuth

- (BOOL)isAuthorized
{
    return [PRWeiboOAuth sharedOAuth].isAuthorized;
}

- (void)authorizeWithCompletionHandler:(PRSocialAuthCallback)completion
{
    if (!self.isAuthorized && _usesSSO && [WeiboSDK isWeiboAppInstalled]) {
        self.authCompletionHandler = completion;
        [self sendSSOAuthRequest];
    } else {
        [[PRWeiboOAuth sharedOAuth] authorizeWithCompletionHandler:completion];
    }
}

- (void)logout
{
    [[PRWeiboOAuth sharedOAuth] logout];
}

- (void)registerSSO
{
    [WeiboSDK registerApp:[[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppID
                                                       forServiceName:NSStringFromClass(PRWeiboService.class)]];
}

- (void)sendSSOAuthRequest
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyOAuthRedirectURI
                                                       forServiceName:NSStringFromClass(PRWeiboOAuth.class)];
    request.scope = [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyOAuthScope
                                                 forServiceName:NSStringFromClass(PRWeiboOAuth.class)];
    [WeiboSDK sendRequest:request];
}

- (BOOL)handleSSOAuthOpenURL:(NSURL *)URL
{
    return [WeiboSDK handleOpenURL:URL delegate:self];
}

#pragma mark - Getters and setters

- (NSString *)userID
{
    return [PRWeiboOAuth sharedOAuth].userID;
}

- (NSString *)accessToken
{
    return [PRWeiboOAuth sharedOAuth].accessToken;
}

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        self.usesSSO = YES;
    }
    return self;
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            PRWeiboOAuth *weiboOAuth = [PRWeiboOAuth sharedOAuth];
            weiboOAuth.userID = authResponse.userID;
            weiboOAuth.accessToken = authResponse.accessToken;
            weiboOAuth.accessTokenTimeout = authResponse.expirationDate;
            if (self.authCompletionHandler) {
                self.authCompletionHandler(YES);
            }
        } else {
            if (self.authCompletionHandler) {
                self.authCompletionHandler(NO);
            }
        }
    }
}

@end
