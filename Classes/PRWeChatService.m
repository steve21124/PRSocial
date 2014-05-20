//
//  PRWeChatService.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "WXApi.h"
#import "PRWeChatService.h"

@interface PRWeChatService ()

+ (UIImage *)scaledImageWithImage:(UIImage *)image size:(CGSize)size;

@end

@implementation PRWeChatService

- (void)registerService
{
    [WXApi registerApp:[[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppID
                                                    forServiceName:NSStringFromClass(self.class)]
       withDescription:[[PRSocialConfig defaultConfig] valueForKey:kPRSocialConfigKeyAppDescription
                                                    forServiceName:NSStringFromClass(self.class)]];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image
{
    [self shareContentWithTitle:title description:description URL:URL image:image scene:PRWeChatServiceSceneTimeline];
}

- (void)shareContentWithTitle:(NSString *)title description:(NSString *)description URL:(NSURL *)URL image:(UIImage *)image scene:(PRWeChatServiceScene)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    
    if (image) {
        message.thumbData = UIImageJPEGRepresentation([self.class scaledImageWithImage:image size:CGSizeMake(100.f, 100.f * image.size.height / image.size.width)], .5f);
    }
    
    if (URL.absoluteString.length) {
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = URL.absoluteString;
        message.mediaObject = webpageObject;
    }
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = (scene == PRWeChatServiceSceneSession) ? WXSceneSession : WXSceneTimeline;
    
    [WXApi sendReq:req];
}

#pragma mark - Utils

+ (UIImage *)scaledImageWithImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return scaledImage;
}

@end
