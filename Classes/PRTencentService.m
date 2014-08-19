//
//  PRTencentService.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 8/18/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSObject+PRSocialJSONKeyPath.h"
#import "PRTencentService.h"

@interface PRTencentService ()

@property (nonatomic, strong) PRSocialUserInfoCallback userInfoCompletionHandler;

@end

@implementation PRTencentService

#pragma mark - Override

- (void)registerService
{
    self.tencentAPI = [[TencentOAuth alloc] initWithAppId:[[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppID
                                                                                       forServiceName:NSStringFromClass(PRTencentService.class)]
                                              andDelegate:self];
}

- (BOOL)isAvailable
{
    return [TencentOAuth iphoneQQInstalled];
}

- (BOOL)handleOpenURL:(NSURL *)URL
{
    return [[PRTencentAuth sharedAuth] handleSSOAuthOpenURL:URL];
}

#pragma mark - Account

- (void)fetchUserInfoCompletion:(PRSocialUserInfoCallback)completion
{
    PRTencentAuth *tencentAuth = [PRTencentAuth sharedAuth];
    [tencentAuth authorizeWithCompletionHandler:^(BOOL success) {
        if (success) {
            self.userInfoCompletionHandler = completion;
            [self.tencentAPI getUserInfo];
        } else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}

#pragma mark - TencentSessionDelegate

- (void)tencentDidLogin
{
    [[PRTencentAuth sharedAuth] tencentDidLogin];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    [[PRTencentAuth sharedAuth] tencentDidNotLogin:cancelled];
}

- (void)tencentDidNotNetWork
{
    [[PRTencentAuth sharedAuth] tencentDidNotNetWork];
}

- (void)getUserInfoResponse:(APIResponse *)response
{
	if (response.retCode == URLREQUEST_SUCCEED) {
        NSDictionary *responseDictionary = response.jsonResponse;
        PRSocialUserInfo *userInfo = [[PRSocialUserInfo alloc] init];
        userInfo.userID = [PRTencentAuth sharedAuth].userID;
        userInfo.nickname = [responseDictionary prs_objectWithJSONKeyPath:@"nickname"];
        NSString *avatarURLString = [responseDictionary prs_objectWithJSONKeyPath:@"figureurl_qq_2"];
        if (avatarURLString) {
            userInfo.avatarURL = [NSURL URLWithString:avatarURLString];
        }
        NSString *genderString = [responseDictionary prs_objectWithJSONKeyPath:@"gender"];
        if ([genderString isEqualToString:@"男"]) {
            userInfo.gender = PRSocialUserGenderMale;
        } else if ([genderString isEqualToString:@"女"]) {
            userInfo.gender = PRSocialUserGenderFemale;
        } else {
            userInfo.gender = PRSocialUserGenderUnknown;
        }
        NSString *locationState = [responseDictionary prs_objectWithJSONKeyPath:@"province"];
        NSString *locationCity = [responseDictionary prs_objectWithJSONKeyPath:@"city"];
        NSMutableString *location = locationState.mutableCopy;
        if (locationCity.length) {
            if (location.length) [location appendString:@" "];
            [location appendString:locationCity];
        }
        userInfo.location = location;
        if (self.userInfoCompletionHandler) {
            self.userInfoCompletionHandler(YES, userInfo);
        }
	} else {
        if (self.userInfoCompletionHandler) {
            self.userInfoCompletionHandler(NO, nil);
        }
	}
}

@end
