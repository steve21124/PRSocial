//
//  PRWeChatService.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialService.h"

typedef NS_ENUM(NSUInteger, PRWeChatServiceScene) {
    PRWeChatServiceSceneSession,
    PRWeChatServiceSceneTimeline
};

@interface PRWeChatService : PRSocialService

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRWeChatServiceScene)scene;

@end
