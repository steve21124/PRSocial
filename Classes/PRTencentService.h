//
//  PRTencentService.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 8/18/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <TencentOpenAPI/TencentOpenSDK.h>
#import "PRSocialService.h"
#import "PRTencentAuth.h"

typedef NS_ENUM(NSUInteger, PRTencentServiceScene) {
    PRTencentServiceSceneQQ,
    PRTencentServiceSceneQzone
};

@interface PRTencentService : PRSocialService <TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *tencentAPI;

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRTencentServiceScene)scene;
- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRTencentServiceScene)scene completion:(PRSocialCallback)completion;
- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL scene:(PRTencentServiceScene)scene;
- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL scene:(PRTencentServiceScene)scene completion:(PRSocialCallback)completion;

@end
