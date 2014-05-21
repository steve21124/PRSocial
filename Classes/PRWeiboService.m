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
#import "PRSocialComposeViewController.h"
#import "NSString+PRSocialURLCoding.h"
#import "NSObject+PRSocialJSONKeyPath.h"
#import "PRSocialHTTPFormDataRequest.h"
#import "PRWeiboService.h"

@interface PRWeiboService () <PRSocialComposeViewControllerDelegate>

@property (nonatomic, copy) PRSocialCallback completionHandler;

- (void)presentComposeViewControllerWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image;
- (void)sendShareRequestWithText:(NSString *)text image:(UIImage *)image completion:(PRSocialCallback)completion;

@end

@implementation PRWeiboService

- (BOOL)isAvailable
{
    return YES;
}

- (BOOL)handleOpenURL:(NSURL *)URL
{
    return [[PRWeiboAuth sharedAuth] handleSSOAuthOpenURL:URL];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image
{
    if (_usesSystemSocialFramework) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        composeViewController.title = title;
        [composeViewController setInitialText:description];
        
        if (URL) {
            [composeViewController addURL:URL];
        }
        
        if (image) {
            [composeViewController addImage:image];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].topWindow.rootViewController presentViewController:composeViewController animated:YES completion:nil];
        });
    } else {
        [[PRWeiboAuth sharedAuth] authorizeWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self presentComposeViewControllerWithTitle:title description:description URL:URL image:image];
            }
        }];
    }
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
            [[UIApplication sharedApplication].topWindow.rootViewController presentViewController:composeViewController animated:YES completion:nil];
        });
    } else {
        self.completionHandler = completion;
        [[PRWeiboAuth sharedAuth] authorizeWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self presentComposeViewControllerWithTitle:title description:description URL:URL image:image];
            } else {
                completion(NO, nil);
            }
        }];
    }
}

#pragma mark - UI

- (void)presentComposeViewControllerWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PRSocialGlobalHUD show];
        NSString *shortenedLink = [self shortLinkForLink:URL.absoluteString];
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
            [[UIApplication sharedApplication].topWindow.rootViewController presentViewController:composeNavigationController animated:YES completion:nil];
        });
    });
}

#pragma mark - Data

- (NSString *)shortLinkForLink:(NSString *)link
{
    NSString *shortenedLink;
    if (link.length) {
        NSDictionary *requestDictionary = @{@"access_token": [PRWeiboAuth sharedAuth].accessToken,
                                            @"url_long": link};
        NSURL *URLWithData = [NSURL URLWithString:[@"https://api.weibo.com/2/short_url/shorten.json" stringByAppendingFormat:@"?%@", [NSString prs_stringWithURLEncodedDictionary:requestDictionary]]];
        NSDictionary *responseDictionary = [PRSocialHTTPRequest sendSynchronousRequestForURL:URLWithData method:HTTPMethodGET headers:nil requestBody:nil responseHeaders:nil];
        if ([[responseDictionary prs_objectWithJSONKeyPath:@"urls..0.url_long"] isEqualToString:link]) {
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
