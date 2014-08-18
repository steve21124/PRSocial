//
//  PRWeChatOAuth.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 8/15/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRWeChatOAuth.h"
#import "WxApi.h"
#import "NSObject+PRSocialJSONKeyPath.h"

@interface PRWeChatOAuth () <WXApiDelegate>

@property (nonatomic, strong) NSString *state;

@end

@implementation PRWeChatOAuth

#pragma mark - Getters and setters

- (NSString *)accessTokenLink
{
    return @"https://api.weixin.qq.com/sns/oauth2/access_token";
}

- (NSDictionary *)codeAuthRequestDictionary
{
    NSDictionary *requestDictionary = @{
                                        @"appid": self.clientID,
                                        @"secret": self.clientSecret,
                                        @"grant_type": @"authorization_code",
                                        @"code": self.code
                                        };
    return requestDictionary;
}

- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary
{
    [super handleCodeAuthResponse:responseDictionary];
    self.userID = [responseDictionary prs_objectWithJSONKeyPath:@"openid"];
}

#pragma mark - Auth flow

- (void)promptWithWebView
{
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = self.scope;
    NSString *state = @(arc4random()).stringValue;
    self.state = state;
    req.state = state;
    [WXApi sendReq:req];
}

#pragma mark - WXApiDelegate

- (void)onResp:(SendAuthResp *)resp
{
    BOOL success = resp.errCode == WXSuccess;
    if (success &&
        [resp.state isEqualToString:self.state]) {
        self.code = resp.code;
    }
    dispatch_semaphore_signal(self.isAuthorizingViaWebViewSem);
}

@end
