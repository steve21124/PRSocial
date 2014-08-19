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

@interface PRTencentService : PRSocialService <TencentSessionDelegate>

@property (nonatomic, strong) TencentOAuth *tencentAPI;

@end
