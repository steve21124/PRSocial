//
//  PRSocialAuthWebViewController.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PRSocialAuthWebViewController;

@protocol PRSocialAuthWebViewControllerDelegate <NSObject>

@optional

- (void)authWebViewControllerDidDismiss:(PRSocialAuthWebViewController *)viewController;

- (void)authWebViewController:(PRSocialAuthWebViewController *)viewController didSucceedWithResponseDictionary:(NSDictionary *)responseDictionary;
- (void)authWebViewControllerDidCancel:(PRSocialAuthWebViewController *)viewController;

@end

@interface PRSocialAuthWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) id<PRSocialAuthWebViewControllerDelegate> delegate;

+ (void)promptWithAuthURL:(NSURL *)authURL
              callbackURL:(NSURL *)callbackURL
                 delegate:(id<PRSocialAuthWebViewControllerDelegate>)delegate;
+ (UINavigationController *)navigationControllerWithAuthURL:(NSURL *)authURL
                                                callbackURL:(NSURL *)callbackURL
                                                   delegate:(id<PRSocialAuthWebViewControllerDelegate>)delegate;

@end
