//
//  PRWeiboService.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialService.h"
#import "PRWeiboAuth.h"

@interface PRWeiboService : PRSocialService

@property (nonatomic, assign) BOOL usesSystemSocialFramework;

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL;
- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL imageURL:(NSURL *)imageURL completion:(PRSocialCallback)completion;

@end
