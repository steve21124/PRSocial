//
//  PRSocialComposeViewController.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PRSocialComposeViewController;

@protocol PRSocialComposeViewControllerDelegate <NSObject>

@optional

- (void)composeViewController:(PRSocialComposeViewController *)composeViewController didFinishWithText:(NSString *)text URL:(NSURL *)URL image:(UIImage *)image;
- (void)composeViewControllerDidCancel:(PRSocialComposeViewController *)composeViewController;

@end

@interface PRSocialComposeViewController : UIViewController

@property (nonatomic, weak) id<PRSocialComposeViewControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger maxASCIITextLength;

@property (nonatomic, copy) NSString *initialText;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIImage *image;

@end
