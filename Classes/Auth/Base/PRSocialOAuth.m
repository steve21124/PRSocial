//
//  PRSocialOAuth.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <SSKeychain.h>
#import "PRSocialGlobalHUD.h"
#import "NSString+PRSocialURLCoding.h"
#import "PRSocialHTTPRequest.h"
#import "PRSocialOAuth.h"

NSString * const kPRSocialKeychainAccountUserID = @"UserID";
NSString * const kPRSocialKeychainAccountAccessToken = @"AccessToken";
NSString * const kPRSocialKeychainAccountRefreshToken = @"RefreshToken";
NSString * const kPRSocialKeychainAccountAccessTokenTimeout = @"AccessTokenTimeout";
NSString * const kPRSocialKeychainAccountRefreshTokenTimeout = @"RefreshTokenTimeout";

// Use this offset to avoid inexactness when determining whether the tokens are valid.
// For example, if the expires_in value is 3600 (60 min), the token will appear to be invalid after (60 - 5) = 55 min.
NSTimeInterval const kPRSocialOAuthTimeoutOffset = 300; // 5 min

@implementation PRSocialOAuth

#pragma mark - External

// Status

- (BOOL)isAuthorized
{
    return self.isAccessTokenValid;
}

- (BOOL)checkAuthorizationUpdate
{
    BOOL isAuthorized = NO;
    if (self.isAccessTokenValid) {
        isAuthorized = YES;
    } else {
        if (self.isRefreshTokenValid) {
            [self getAccessTokenWithRefreshToken];
        }
        if (self.isAccessTokenValid) {
            isAuthorized = YES;
        }
    }
    return isAuthorized;
}

// Actions

- (void)authorizeWithCompletionHandler:(void (^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = NO;
        if (self.isAccessTokenValid) {
            success = YES;
        } else {
            self.accessToken = nil;
            self.accessTokenTimeout = nil;
            if (self.isRefreshTokenValid) {
                [self getAccessTokenWithRefreshToken];
            } else {
                self.refreshToken = nil;
                self.refreshTokenTimeout = nil;
            }
            if (!self.accessToken) {
                dispatch_semaphore_t isAuthorizingViaWebViewSem = dispatch_semaphore_create(0);
                self.isAuthorizingViaWebViewSem = isAuthorizingViaWebViewSem;
                [self promptWithWebView];
                dispatch_semaphore_wait(isAuthorizingViaWebViewSem, DISPATCH_TIME_FOREVER);
                self.isAuthorizingViaWebViewSem = NULL;
                [self getAccessTokenWithAuthCode];
            }
            if (self.isAccessTokenValid) {
                success = YES;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    });
}

- (void)deactivateAccessToken
{
    self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:-1];
}

- (void)logout
{
    self.code = nil;
    self.accessToken = nil;
    self.accessTokenTimeout = nil;
    self.refreshToken = nil;
    self.refreshTokenTimeout = nil;
}

#pragma mark - Getters and setters

#pragma mark Config

- (NSString *)clientID
{
    return [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyOAuthClientID
                                        forServiceName:NSStringFromClass(self.class)] ?: @"";
}

- (NSString *)clientSecret
{
    return [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyOAuthClientSecret
                                        forServiceName:NSStringFromClass(self.class)] ?: @"";
}

- (NSString *)redirectURI
{
    return [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyOAuthRedirectURI
                                        forServiceName:NSStringFromClass(self.class)] ?: @"";
}

- (NSString *)scope
{
    return [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyOAuthScope
                                        forServiceName:NSStringFromClass(self.class)] ?: @"";
}

- (NSString *)authorizeLink
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
    return nil;
}

- (NSString *)accessTokenLink
{
    NSAssert(NO, @"%s Override needed on abstract method.", __PRETTY_FUNCTION__);
    return nil;
}

#pragma mark Auth info

- (NSString *)userID
{
    return [SSKeychain passwordForService:NSStringFromClass(self.class)
                                  account:kPRSocialKeychainAccountUserID];
}

- (void)setUserID:(NSString *)userID
{
    if (userID) {
        [SSKeychain setPassword:userID
                     forService:NSStringFromClass(self.class)
                        account:kPRSocialKeychainAccountUserID];
    } else {
        [SSKeychain deletePasswordForService:NSStringFromClass(self.class)
                                     account:kPRSocialKeychainAccountUserID];
    }
}

- (NSString *)accessToken
{
    return [SSKeychain passwordForService:NSStringFromClass(self.class)
                                  account:kPRSocialKeychainAccountAccessToken];
}

- (void)setAccessToken:(NSString *)accessToken
{
    if (accessToken) {
        [SSKeychain setPassword:accessToken
                     forService:NSStringFromClass(self.class)
                        account:kPRSocialKeychainAccountAccessToken];
    } else {
        [SSKeychain deletePasswordForService:NSStringFromClass(self.class)
                                     account:kPRSocialKeychainAccountAccessToken];
    }
}

- (NSDate *)accessTokenTimeout
{
    return [NSDate dateWithTimeIntervalSince1970:[SSKeychain passwordForService:NSStringFromClass(self.class)
                                                                        account:kPRSocialKeychainAccountAccessTokenTimeout].integerValue];
    
}

- (void)setAccessTokenTimeout:(NSDate *)accessTokenTimeout
{
    if (accessTokenTimeout) {
        [SSKeychain setPassword:@(accessTokenTimeout.timeIntervalSince1970).stringValue
                     forService:NSStringFromClass(self.class)
                        account:kPRSocialKeychainAccountAccessTokenTimeout];
    } else {
        [SSKeychain deletePasswordForService:NSStringFromClass(self.class)
                                     account:kPRSocialKeychainAccountAccessTokenTimeout];
    }
}

- (NSString *)refreshToken
{
    return [SSKeychain passwordForService:NSStringFromClass(self.class)
                                  account:kPRSocialKeychainAccountRefreshToken];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    if (refreshToken) {
        [SSKeychain setPassword:refreshToken
                     forService:NSStringFromClass(self.class)
                        account:kPRSocialKeychainAccountRefreshToken];
    } else {
        [SSKeychain deletePasswordForService:NSStringFromClass(self.class)
                                     account:kPRSocialKeychainAccountRefreshToken];
    }
}

- (NSDate *)refreshTokenTimeout
{
    return [NSDate dateWithTimeIntervalSince1970:[SSKeychain passwordForService:NSStringFromClass(self.class)
                                                                        account:kPRSocialKeychainAccountRefreshTokenTimeout].integerValue];
    
}

- (void)setRefreshTokenTimeout:(NSDate *)refreshTokenTimeout
{
    if (refreshTokenTimeout) {
        [SSKeychain setPassword:@(refreshTokenTimeout.timeIntervalSince1970).stringValue
                     forService:NSStringFromClass(self.class)
                        account:kPRSocialKeychainAccountRefreshTokenTimeout];
    } else {
        [SSKeychain deletePasswordForService:NSStringFromClass(self.class)
                                     account:kPRSocialKeychainAccountRefreshTokenTimeout];
    }
}

#pragma mark Auth status

- (BOOL)isAccessTokenValid
{
    BOOL isAccessTokenValid = NO;
    if (self.userID && self.accessToken && self.accessTokenTimeout) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult comparisonResult = [currentDate compare:[self.accessTokenTimeout dateByAddingTimeInterval:kPRSocialOAuthTimeoutOffset]];
        if (comparisonResult == NSOrderedAscending) {
            isAccessTokenValid = YES;
        }
    }
    return isAccessTokenValid;
}

- (BOOL)isRefreshTokenValid
{
    BOOL isRefreshTokenValid = NO;
    if (self.refreshToken && self.refreshTokenTimeout) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult comparisonResult = [currentDate compare:[self.refreshTokenTimeout dateByAddingTimeInterval:kPRSocialOAuthTimeoutOffset]];
        if (comparisonResult == NSOrderedAscending) {
            isRefreshTokenValid = YES;
        }
    }
    return isRefreshTokenValid;
}

#pragma mark - Auth flow

- (void)promptWithWebView
{
    NSDictionary *authRequestDictionary = self.webViewAuthRequestDictionary;
    NSURL *urlWithData = [NSURL URLWithString:[self.authorizeLink stringByAppendingFormat:@"?%@", [NSString prs_stringWithURLEncodedDictionary:authRequestDictionary]]];
    [PRSocialAuthWebViewController promptWithAuthURL:urlWithData callbackURL:[NSURL URLWithString:self.redirectURI] delegate:self];
}

- (void)getAccessTokenWithAuthCode
{
    if (self.code) {
        [PRSocialGlobalHUD show];
        NSURL *requestURL = [NSURL URLWithString:self.accessTokenLink];
        NSDictionary *requestDictionary = self.codeAuthRequestDictionary;
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [PRSocialHTTPRequest sendSynchronousRequestForURL:requestURL
                                                                                      method:HTTPMethodPOST
                                                                                     headers:nil
                                                                                 requestBody:requestDictionary
                                                                             responseHeaders:&responseHeaders];
        [self handleCodeAuthResponse:responseDictionary];
        [PRSocialGlobalHUD hide];
    }
}

- (void)getAccessTokenWithRefreshToken
{
    if (self.refreshToken) {
        [PRSocialGlobalHUD show];
        NSURL *requestURL = [NSURL URLWithString:self.accessTokenLink];
        NSDictionary *requestDictionary = self.refreshTokenAuthRequestDictionary;
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [PRSocialHTTPRequest sendSynchronousRequestForURL:requestURL
                                                                                      method:HTTPMethodPOST
                                                                                     headers:nil
                                                                                 requestBody:requestDictionary
                                                                             responseHeaders:&responseHeaders];
        [self handleRefreshTokenAuthResponse:responseDictionary];
        [PRSocialGlobalHUD hide];
    }
}

- (NSDictionary *)webViewAuthRequestDictionary
{
    NSDictionary *authRequestDictionary = @{
                                            @"client_id": self.clientID,
                                            @"client_secret": self.clientSecret,
                                            @"redirect_uri": self.redirectURI,
                                            @"response_type": @"code",
                                            @"scope": self.scope
                                            };
    return authRequestDictionary;
}

- (NSDictionary *)codeAuthRequestDictionary
{
    NSDictionary *requestDictionary = @{
                                        @"client_id": self.clientID,
                                        @"client_secret": self.clientSecret,
                                        @"grant_type": @"authorization_code",
                                        @"code": self.code
                                        };
    return requestDictionary;
}

- (NSDictionary *)refreshTokenAuthRequestDictionary
{
    NSDictionary *requestDictionary = @{
                                        @"client_id": self.clientID,
                                        @"client_secret": self.clientSecret,
                                        @"grant_type": @"refresh_token",
                                        @"refresh_token": self.refreshToken
                                        };
    return requestDictionary;
}

- (void)handleWebViewAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        self.code = responseDictionary[@"code"];
    }
}

- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        self.userID = responseDictionary[@"uid"];
        self.accessToken = responseDictionary[@"access_token"];
        self.refreshToken = responseDictionary[@"refresh_token"];
        NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
        self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
        if (self.refreshToken) {
            self.refreshTokenTimeout = [NSDate distantFuture];
        }
    }
}

- (void)handleRefreshTokenAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        self.accessToken = responseDictionary[@"access_token"];
        self.refreshToken = responseDictionary[@"refresh_token"];
        NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
        self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
        if (self.refreshToken) {
            self.refreshTokenTimeout = [NSDate distantFuture];
        }
    }
}

#pragma mark - Life cycle

+ (instancetype)sharedOAuth
{
    static NSMutableDictionary *sharedOAuths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOAuths = [[NSMutableDictionary alloc] init];
    });
    NSString *classString = NSStringFromClass(self);
    @synchronized(sharedOAuths) {
        if (![sharedOAuths.allKeys containsObject:classString]) {
            sharedOAuths[classString] = [[self alloc] init];
        }
    }
    return sharedOAuths[classString];
}

#pragma mark - Auth web view controller delegate

- (void)authWebViewControllerDidDismiss:(PRSocialAuthWebViewController *)viewController
{
    dispatch_semaphore_signal(self.isAuthorizingViaWebViewSem);
}

- (void)authWebViewController:(PRSocialAuthWebViewController *)viewController didSucceedWithResponseDictionary:(NSDictionary *)responseDictionary
{
    [self handleWebViewAuthResponse:responseDictionary];
}

@end
