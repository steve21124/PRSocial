//
//  PRWeChatOAuth.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 8/15/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialOAuth.h"

@class SendAuthResp;

@interface PRWeChatOAuth : PRSocialOAuth

- (void)onResp:(SendAuthResp *)resp;

@end
