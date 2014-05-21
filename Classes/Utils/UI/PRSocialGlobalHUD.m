//
//  PRSocialGlobalHUD.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/21/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialGlobalHUD.h"
#import "UIApplication+PRSocialTopWindow.h"

@implementation PRSocialGlobalHUD

static PRSocialGlobalHUD *__globalHUD;

+ (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!__globalHUD) {
            __globalHUD = [self showHUDAddedTo:[UIApplication sharedApplication].topWindow animated:YES];
        } else {
            [__globalHUD show:YES];
        }
    });
}

+ (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [__globalHUD hide:YES];
    });
}

@end
