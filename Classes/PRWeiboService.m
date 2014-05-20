//
//  PRWeiboService.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRWeiboService.h"
#import <Social/Social.h>

@interface PRWeiboService ()

@end

@implementation PRWeiboService

- (BOOL)isAvailable
{
    return YES;
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
        
        // Find the window on the top.
        UIApplication *application = [UIApplication sharedApplication];
        UIWindow *topWindow = application.keyWindow;
        if (topWindow.windowLevel != UIWindowLevelNormal) {
            for (UIWindow *window in application.windows) {
                if (window.windowLevel == UIWindowLevelNormal) {
                    topWindow = window;
                    break;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [topWindow.rootViewController presentViewController:composeViewController animated:YES completion:nil];
        });
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
        
        // Find the window on the top.
        UIApplication *application = [UIApplication sharedApplication];
        UIWindow *topWindow = application.keyWindow;
        if (topWindow.windowLevel != UIWindowLevelNormal) {
            for (UIWindow *window in application.windows) {
                if (window.windowLevel == UIWindowLevelNormal) {
                    topWindow = window;
                    break;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [topWindow.rootViewController presentViewController:composeViewController animated:YES completion:nil];
        });
    }
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

@end
