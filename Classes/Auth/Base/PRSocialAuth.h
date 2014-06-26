//
//  PRSocialAuth.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRSocialConfig.h"

typedef void (^PRSocialAuthCallback)(BOOL success);

@interface PRSocialAuth : NSObject

@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) NSString *accessToken;

+ (instancetype)sharedAuth;

@end

@interface PRSocialAuth (Override)

- (BOOL)isAuthorized;
- (void)authorizeWithCompletionHandler:(PRSocialAuthCallback)completion;
- (void)logout;

- (void)registerSSO;
- (void)sendSSOAuthRequest;
- (BOOL)handleSSOAuthOpenURL:(NSURL *)URL;

@end
