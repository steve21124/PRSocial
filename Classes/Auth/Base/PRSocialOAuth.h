//
//  PRSocialOAuth.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRSocialConfig.h"
#import "PRSocialAuthWebViewController.h"

@interface PRSocialOAuth : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSString *refreshToken;
@property (nonatomic) NSDate *accessTokenTimeout;
@property (nonatomic) NSDate *refreshTokenTimeout;

#pragma mark - Life cycle

+ (instancetype)sharedOAuth;

#pragma mark - Actions

// Return YES if access token is currently valid.
- (BOOL)isAuthorized;

// If access token is currently valid, return YES. Or try use refresh token to fetch access token, then return YES if the process succeeded.
- (BOOL)checkAuthorizationUpdate;

// Try authorize using standard auth flow.
- (void)authorizeWithCompletionHandler:(void (^)(BOOL success))completion;

// Call this method to deactivate access token manually if it is somehow invalid.
- (void)deactivateAccessToken;

// Clears all the information stored.
- (void)logout;

#pragma mark - Auth flow

// These methods can be used to make custom changes to adapt to different platforms.
- (NSDictionary *)webViewAuthRequestDictionary;
- (NSDictionary *)codeAuthRequestDictionary;
- (NSDictionary *)refreshTokenAuthRequestDictionary;
- (void)handleWebViewAuthResponse:(NSDictionary *)responseDictionary;
- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary;
- (void)handleRefreshTokenAuthResponse:(NSDictionary *)responseDictionary;

@end

@interface PRSocialOAuth (Override)

- (NSString *)authorizeLink;
- (NSString *)accessTokenLink;

@end

@interface PRSocialOAuth () <PRSocialAuthWebViewControllerDelegate>

@property (nonatomic, readonly) BOOL isAccessTokenValid;
@property (nonatomic, readonly) BOOL isRefreshTokenValid;

@property (nonatomic, assign) dispatch_semaphore_t isAuthorizingViaWebViewSem;

// Config
- (NSString *)clientID;
- (NSString *)clientSecret;
- (NSString *)redirectURI;
- (NSString *)scope;

// Auth flow
- (void)promptWithWebView;
- (void)getAccessTokenWithAuthCode;
- (void)getAccessTokenWithRefreshToken;

@end
