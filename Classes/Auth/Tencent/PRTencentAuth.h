//
//  PRTencentAuth.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 8/18/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialAuth.h"
#import "PRTencentOAuth.h"

@interface PRTencentAuth : PRSocialAuth

- (void)tencentDidLogin;
- (void)tencentDidNotLogin:(BOOL)cancelled;
- (void)tencentDidNotNetWork;

@end
