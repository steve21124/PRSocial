//
//  PRWeChatService.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "WXApi.h"
#import "PRSocialHTTPFormDataRequest.h"
#import "NSObject+PRSocialJSONKeyPath.h"
#import "PRWeChatService.h"

@interface PRWeChatService () <WXApiDelegate>

+ (UIImage *)scaledImageWithImage:(UIImage *)image size:(CGSize)size;

@end

@implementation PRWeChatService

#pragma mark - Override

- (void)registerService
{
    [WXApi registerApp:[[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppID
                                                    forServiceName:NSStringFromClass(self.class)]
       withDescription:[[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppDescription
                                                    forServiceName:NSStringFromClass(self.class)]];
}

- (BOOL)isAvailable
{
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}

- (BOOL)handleOpenURL:(NSURL *)URL
{
    return [WXApi handleOpenURL:URL delegate:self];
}

#pragma mark - Account

- (void)fetchUserInfoCompletion:(void (^)(BOOL, PRSocialUserInfo *))completion
{
    PRWeChatAuth *weChatAuth = [PRWeChatAuth sharedAuth];
    [weChatAuth authorizeWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSDictionary *requestDictionary = @{@"openid": weChatAuth.userID,
                                                @"access_token": weChatAuth.accessToken};
            NSURL *requestURL = [NSURL URLWithString:@"https://api.weixin.qq.com/sns/userinfo"];
            [PRSocialHTTPRequest sendAsynchronousRequestForURL:requestURL
                                                        method:HTTPMethodGET
                                                       headers:nil
                                                   requestBody:requestDictionary
                                                    completion:^(NSDictionary *responseHeaders,
                                                                 NSDictionary *responseDictionary) {
                                                        PRSocialUserInfo *userInfo = [[PRSocialUserInfo alloc] init];
                                                        userInfo.userID = [responseDictionary prs_objectWithJSONKeyPath:@"openid"];
                                                        userInfo.userName = [responseDictionary prs_objectWithJSONKeyPath:@"unionid"];
                                                        userInfo.nickname = [responseDictionary prs_objectWithJSONKeyPath:@"nickname"];
                                                        NSString *avatarURLString = [responseDictionary prs_objectWithJSONKeyPath:@"headimgurl"];
                                                        if (avatarURLString) {
                                                            userInfo.avatarURL = [NSURL URLWithString:avatarURLString];
                                                        }
                                                        NSUInteger genderInt = [[responseDictionary prs_objectWithJSONKeyPath:@"sex"] integerValue];
                                                        if (genderInt == 1) {
                                                            userInfo.gender = PRSocialUserGenderMale;
                                                        } else if (genderInt == 2) {
                                                            userInfo.gender = PRSocialUserGenderFemale;
                                                        } else {
                                                            userInfo.gender = PRSocialUserGenderUnknown;
                                                        }
                                                        NSString *locationCountry = [responseDictionary prs_objectWithJSONKeyPath:@"country"];
                                                        NSString *locationState = [responseDictionary prs_objectWithJSONKeyPath:@"province"];
                                                        NSString *locationCity = [responseDictionary prs_objectWithJSONKeyPath:@"city"];
                                                        NSMutableString *location = locationCountry.mutableCopy;
                                                        if (locationState.length) {
                                                            if (location.length) [location appendString:@" "];
                                                            [location appendString:locationState];
                                                        }
                                                        if (locationCity.length) {
                                                            if (location.length) [location appendString:@" "];
                                                            [location appendString:locationCity];
                                                        }
                                                        userInfo.location = location;
                                                        if (completion) {
                                                            completion(YES, userInfo);
                                                        }
                                                    }];
        } else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}

#pragma mark - Share

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image completion:(PRSocialCallback)completion
{
    [self shareContentWithTitle:title description:description URL:URL image:image scene:PRWeChatServiceSceneTimeline completion:completion];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRWeChatServiceScene)scene
{
    [self shareContentWithTitle:title description:description URL:URL image:image scene:scene completion:nil];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRWeChatServiceScene)scene completion:(PRSocialCallback)completion
{
    self.completionHandler = completion;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    
    if (URL.absoluteString.length || image) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = description;
        
        if (image) {
            message.thumbData = UIImageJPEGRepresentation([self.class scaledImageWithImage:image size:CGSizeMake(180.f, 180.f * image.size.height / image.size.width)], .7f);
        }
        
        if (URL.absoluteString.length) {
            WXWebpageObject *webpageObject = [WXWebpageObject object];
            webpageObject.webpageUrl = URL.absoluteString;
            message.mediaObject = webpageObject;
        }
        
        req.bText = NO;
        req.message = message;
    } else {
        req.bText = YES;
        req.text = description;
    }
    
    req.scene = (scene == PRWeChatServiceSceneSession) ? WXSceneSession : WXSceneTimeline;
    
    [WXApi sendReq:req];
}

#pragma mark - Utils

+ (UIImage *)scaledImageWithImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:SendAuthResp.class]) {
        [[PRWeChatOAuth sharedOAuth] onResp:(SendAuthResp *)resp];
    } else {
        BOOL success = resp.errCode == WXSuccess;
        [[NSNotificationCenter defaultCenter] postNotificationName:PRSocialServiceResultNotification
                                                            object:self
                                                          userInfo:@{PRSocialServiceResultNotificationKeySuccess: @(success)}];
        if (self.completionHandler) {
            self.completionHandler(success, nil);
            self.completionHandler = nil;
        }
    }
}

@end
