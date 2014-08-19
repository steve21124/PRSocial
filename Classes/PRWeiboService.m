//
//  PRWeiboService.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Social/Social.h>
#import "PRSocialGlobalHUD.h"
#import "UIApplication+PRSocialTopWindow.h"
#import "UIWindow+PRSocialTopViewController.h"
#import "PRSocialComposeViewController.h"
#import "NSString+PRSocialURLCoding.h"
#import "NSObject+PRSocialJSONKeyPath.h"
#import "PRSocialHTTPFormDataRequest.h"
#import "PRWeiboService.h"

@interface PRWeiboService () <PRSocialComposeViewControllerDelegate>

- (void)presentComposeViewControllerWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image;
- (void)sendShareRequestWithText:(NSString *)text image:(UIImage *)image completion:(PRSocialCallback)completion;

@end

@implementation PRWeiboService

#pragma mark - Override

- (BOOL)isAvailable
{
    return YES;
}

- (BOOL)handleOpenURL:(NSURL *)URL
{
    return [[PRWeiboAuth sharedAuth] handleSSOAuthOpenURL:URL];
}

#pragma mark - Account

- (void)fetchUserInfoCompletion:(PRSocialUserInfoCallback)completion
{
    PRWeiboAuth *weiboAuth = [PRWeiboAuth sharedAuth];
    [weiboAuth authorizeWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSDictionary *requestDictionary = @{@"access_token": weiboAuth.accessToken,
                                                @"uid": weiboAuth.userID};
            [PRSocialHTTPRequest sendAsynchronousRequestForURL:[NSURL URLWithString:@"https://api.weibo.com/2/users/show.json"] method:HTTPMethodGET headers:nil requestBody:requestDictionary completion:^(NSDictionary *responseHeaders, NSDictionary *responseDictionary) {
                PRSocialUserInfo *userInfo = [[PRSocialUserInfo alloc] init];
                userInfo.userID = [responseDictionary prs_objectWithJSONKeyPath:@"id"];
                userInfo.userName = [responseDictionary prs_objectWithJSONKeyPath:@"domain"];
                userInfo.nickname = [responseDictionary prs_objectWithJSONKeyPath:@"name"];
                NSString *avatarURLString = [responseDictionary prs_objectWithJSONKeyPath:@"avatar_hd"];
                if (avatarURLString) {
                    userInfo.avatarURL = [NSURL URLWithString:avatarURLString];
                }
                NSString *genderString = [responseDictionary prs_objectWithJSONKeyPath:@"gender"];
                if ([genderString isEqualToString:@"m"]) {
                    userInfo.gender = PRSocialUserGenderMale;
                } else if ([genderString isEqualToString:@"f"]) {
                    userInfo.gender = PRSocialUserGenderFemale;
                } else if ([genderString isEqualToString:@"n"]) {
                    userInfo.gender = PRSocialUserGenderUnknown;
                } else {
                    userInfo.gender = PRSocialUserGenderUnknown;
                }
                userInfo.intro = [responseDictionary prs_objectWithJSONKeyPath:@"description"];
                userInfo.location = [responseDictionary prs_objectWithJSONKeyPath:@"location"];
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

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL
{
    [self shareContentWithTitle:title description:description URL:URL imageURL:imageURL completion:nil];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL completion:(PRSocialCallback)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PRSocialGlobalHUD show];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        [PRSocialGlobalHUD hide];
        [self shareContentWithTitle:title description:description URL:URL image:image completion:completion];
    });
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image completion:(PRSocialCallback)completion
{
    if (_usesSystemSocialFramework) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
            if (completion) {
                completion(result == SLComposeViewControllerResultDone, nil);
            }
        };
        
        composeViewController.title = title;
        [composeViewController setInitialText:description];
        
        if (URL) {
            [composeViewController addURL:URL];
        }
        
        if (image) {
            [composeViewController addImage:image];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].topWindow.topViewController presentViewController:composeViewController animated:YES completion:nil];
        });
    } else {
        [[PRWeiboAuth sharedAuth] authorizeWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.completionHandler = completion;
                [self presentComposeViewControllerWithTitle:title description:description URL:URL image:image];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(NO, nil);
                    }
                });
            }
        }];
    }
}

#pragma mark - UI

- (void)presentComposeViewControllerWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PRSocialGlobalHUD show];
        NSString *shortenedLink = [self shortLinkForLink:URL.absoluteString] ?: URL.absoluteString;
        PRSocialComposeViewController *composeViewController = [[PRSocialComposeViewController alloc] init];
        composeViewController.delegate = self;
        composeViewController.title = title;
        composeViewController.initialText = shortenedLink ? [@[description, shortenedLink] componentsJoinedByString:@" "] : description;
        
        if (image) {
            composeViewController.image = image;
        }
        
        UINavigationController *composeNavigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
        [PRSocialGlobalHUD hide];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].topWindow.topViewController presentViewController:composeNavigationController animated:YES completion:nil];
        });
    });
}

#pragma mark - Data

- (NSString *)shortLinkForLink:(NSString *)link
{
    NSString *shortenedLink;
    if (link.length) {
        NSDictionary *requestDictionary = @{@"source": [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppID
                                                                                    forServiceName:NSStringFromClass(self.class)],
                                            @"access_token": [PRWeiboAuth sharedAuth].accessToken,
                                            @"url_long": link};
        NSURL *URLWithData = [NSURL URLWithString:[@"https://api.weibo.com/2/short_url/shorten.json" stringByAppendingFormat:@"?%@", [NSString prs_stringWithURLEncodedDictionary:requestDictionary]]];
        NSDictionary *responseDictionary = [PRSocialHTTPRequest sendSynchronousRequestForURL:URLWithData
                                                                                      method:HTTPMethodGET
                                                                                     headers:nil
                                                                                 requestBody:nil
                                                                             responseHeaders:nil];
        if (YES || // Fix for Weibo's bug
            [[responseDictionary prs_objectWithJSONKeyPath:@"urls..0.url_long"] isEqualToString:link]) {
            shortenedLink = [responseDictionary prs_objectWithJSONKeyPath:@"urls..0.url_short"];
        }
    }
    return shortenedLink;
}

- (void)sendShareRequestWithText:(NSString *)text image:(UIImage *)image completion:(PRSocialCallback)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PRSocialGlobalHUD show];
        NSString *accessToken = [PRWeiboAuth sharedAuth].accessToken;
        NSString *clientID = [[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppID
                                                          forServiceName:NSStringFromClass(self.class)];
        NSURLRequest *request;
        if (image) {
            NSURL *requestURL = [NSURL URLWithString:@"https://upload.api.weibo.com/2/statuses/upload.json"];
            request = [PRSocialHTTPFormDataRequest formDataRequestForURL:requestURL
                                                                 headers:nil
                                                             requestBody:@{@"access_token": accessToken,
                                                                           @"source": clientID,
                                                                           @"status": text.prs_URLEncodedString,
                                                                           @"pic": image}];
        } else {
            NSURL *requestURL = [NSURL URLWithString:@"https://api.weibo.com/2/statuses/update.json"];
            request = [PRSocialHTTPRequest requestForURL:requestURL
                                                  method:HTTPMethodPOST
                                                 headers:nil
                                             requestBody:@{@"access_token": accessToken,
                                                           @"source": clientID,
                                                           @"status": text.prs_URLEncodedString}];
        }
        NSHTTPURLResponse *response;
        NSError *error;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        if (error) {
            NSLog(@"%s URL connection error \n%@", __PRETTY_FUNCTION__, error.description);
        }
        NSDictionary *responseDictionary;
        if (responseData) {
            responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
            if (error) {
                NSLog(@"%s JSON parsing error \n%@", __PRETTY_FUNCTION__, error.description);
            }
        }
        [PRSocialGlobalHUD hide];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(response.statusCode == 200, responseDictionary);
            }
        });
    });
}

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        self.usesSystemSocialFramework = YES;
    }
    return self;
}

#pragma mark - PRSocialComposeViewControllerDelegate

- (void)composeViewControllerDidCancel:(PRSocialComposeViewController *)composeViewController
{
    self.completionHandler = nil;
}

- (void)composeViewController:(PRSocialComposeViewController *)composeViewController didFinishWithText:(NSString *)text URL:(NSURL *)URL image:(UIImage *)image
{
    [self sendShareRequestWithText:text image:image completion:^(BOOL success, NSDictionary *result) {
        if (self.completionHandler) {
            self.completionHandler(success, result);
            self.completionHandler = nil;
        }
    }];
}

@end
