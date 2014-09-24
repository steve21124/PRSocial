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
                                                                                       forServiceName:NSStringFromClass(self.class)]
                                              andDelegate:self];
}

- (BOOL)isAvailable
{
    return [TencentOAuth iphoneQQInstalled];
}

- (BOOL)handleOpenURL:(NSURL *)URL
{
    QQApiMessage *message = [QQApi handleOpenURL:URL];
    if (message) {
        if (message.type == QQApiMessageTypeSendMessageToQQResponse) {
            QQApiObject *object = message.object;
            if ([object isKindOfClass:[QQApiResultObject class]]) {
                BOOL success = [(QQApiResultObject *)object error].integerValue == 0;
                if (self.completionHandler) {
                    self.completionHandler(success, nil);
                }
            }
        }
        return YES;
    } else {
        return [[PRTencentAuth sharedAuth] handleSSOAuthOpenURL:URL];
    }
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

#pragma mark - Share

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image
{
    [self shareContentWithTitle:title description:description URL:URL image:image scene:PRTencentServiceSceneQQ];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image completion:(PRSocialCallback)completion
{
    [self shareContentWithTitle:title description:description URL:URL image:image scene:PRTencentServiceSceneQQ completion:PRTencentServiceSceneQQ];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRTencentServiceScene)scene
{
    [self shareContentWithTitle:title description:description URL:URL image:image scene:scene completion:nil];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRTencentServiceScene)scene completion:(PRSocialCallback)completion;
{
    self.completionHandler = completion;
    if (scene == PRTencentServiceSceneQQ) {
        QQApiURLObject *object = [QQApiURLObject objectWithURL:URL
                                                         title:title
                                                   description:description
                                              previewImageData:UIImagePNGRepresentation(image)
                                             targetContentType:QQApiURLTargetTypeNews];
        QQApiMessage *message = [QQApiMessage messageWithObject:object
                                                        andType:QQApiMessageTypeSendMessageToQQRequest];
        [QQApi sendMessage:message];
    } else if (scene == PRTencentServiceSceneQzone) {
        QQApiURLObject *object = [QQApiURLObject objectWithURL:URL
                                                         title:title
                                                   description:description
                                              previewImageData:UIImagePNGRepresentation(image)
                                             targetContentType:QQApiURLTargetTypeNews];
        QQApiMessage *message = [QQApiMessage messageWithObject:object
                                                        andType:QQApiMessageTypeSendMessageToQQQZoneRequest];
        [QQApi sendMessage:message];
    }
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL scene:(PRTencentServiceScene)scene
{
    [self shareContentWithTitle:title description:description URL:URL imageURL:imageURL scene:scene completion:nil];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL scene:(PRTencentServiceScene)scene completion:(PRSocialCallback)completion
{
    self.completionHandler = completion;
    if (scene == PRTencentServiceSceneQQ) {
        QQApiURLObject *object = [QQApiURLObject objectWithURL:URL
                                                         title:title
                                                   description:description
                                               previewImageURL:imageURL
                                             targetContentType:QQApiURLTargetTypeNews];
        QQApiMessage *message = [QQApiMessage messageWithObject:object
                                                        andType:QQApiMessageTypeSendMessageToQQRequest];
        [QQApi sendMessage:message];
    } else if (scene == PRTencentServiceSceneQzone) {
        QQApiURLObject *object = [QQApiURLObject objectWithURL:URL
                                                         title:title
                                                   description:description
                                               previewImageURL:imageURL
                                             targetContentType:QQApiURLTargetTypeNews];
        QQApiMessage *message = [QQApiMessage messageWithObject:object
                                                        andType:QQApiMessageTypeSendMessageToQQQZoneRequest];
        [QQApi sendMessage:message];
    }
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
        userInfo.accessToken = [PRTencentAuth sharedAuth].accessToken;
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
