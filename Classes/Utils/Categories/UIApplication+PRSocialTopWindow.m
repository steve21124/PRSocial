//
//  UIApplication+PRSocialTopWindow.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "UIApplication+PRSocialTopWindow.h"

@implementation UIApplication (PRSocialTopWindow)

- (UIWindow *)topWindow
{
    // Find the window on the top.
    UIWindow *topWindow = self.keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        for (UIWindow *window in self.windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                topWindow = window;
                break;
            }
        }
    }
    return topWindow;
}

@end
