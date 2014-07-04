//
//  UIWindow+PRSocialTopViewController.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 7/4/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "UIWindow+PRSocialTopViewController.h"

@implementation UIWindow (PRSocialTopViewController)

- (UIViewController *)topViewController
{
    return [self topViewControllerForRootViewController:self.rootViewController];
}

- (UIViewController *)topViewControllerForRootViewController:(UIViewController *)rootViewController
{
    UIViewController *topViewController = rootViewController.presentedViewController ?: rootViewController;
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)topViewController;
        topViewController = navigationController.viewControllers.lastObject;
    }
    UIViewController *presentedViewController = topViewController.presentedViewController;
    return presentedViewController ? [self topViewControllerForRootViewController:presentedViewController] : topViewController;
}

@end
