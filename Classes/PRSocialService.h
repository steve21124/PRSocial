//
//  PRSocialService.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PRSocialConfig.h"

extern NSString * const PRSocialServiceResultNotification;
extern NSString * const PRSocialServiceResultNotificationKeySuccess;
extern NSString * const PRSocialServiceResultNotificationKeyInfo;

typedef void (^PRSocialCallback)(BOOL success, NSDictionary *result);

@interface PRSocialService : NSObject

@property (nonatomic, copy) PRSocialCallback completionHandler;

+ (instancetype)sharedService;

@end

@interface PRSocialService (Override)

- (void)registerService;
- (BOOL)isAvailable;

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image;
- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image completion:(PRSocialCallback)completion;

- (BOOL)handleOpenURL:(NSURL *)URL;

@end

@interface PRSocialService (Private)

+ (BOOL)handleOpenURL:(NSURL *)URL;

@end
