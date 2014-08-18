//
//  PRWeChatAuth.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 8/15/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRWeChatAuth.h"
#import "WXApi.h"
#import "PRWeChatService.h"

@implementation PRWeChatAuth

- (void)authorizeWithCompletionHandler:(PRSocialAuthCallback)completion
{
    [[PRWeChatOAuth sharedOAuth] authorizeWithCompletionHandler:completion];
}

- (void)logout
{
    [[PRWeChatOAuth sharedOAuth] logout];
}

- (void)registerSSO
{
    [WXApi registerApp:[[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppID
                                                    forServiceName:NSStringFromClass(PRWeChatService.class)]];
}

#pragma mark - Getters and setters

- (NSString *)userID
{
    return [PRWeChatOAuth sharedOAuth].userID;
}

- (NSString *)accessToken
{
    return [PRWeChatOAuth sharedOAuth].accessToken;
}

@end
