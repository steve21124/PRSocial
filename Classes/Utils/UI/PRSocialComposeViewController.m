//
//  PRSocialComposeViewController.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSString+PRSocialASCIILength.h"
#import "PRSocialComposeViewController.h"

CGFloat const kImageViewWidth = 100.f;
CGFloat const kImageViewHeight = 100.f;
CGFloat const kTextViewFontSize = 18.f;
CGFloat const kTextLengthLabelHeight = 18.f;
CGFloat const kTextLengthLabelFontSize = 16.f;

@interface PRSocialComposeViewController () <UITextViewDelegate>

@property (nonatomic, weak) UIBarButtonItem *doneButton;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *imageBackgroundView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UILabel *textLengthLabel;

- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)doneButtonClicked:(UIBarButtonItem *)sender;

- (void)updateUI;

- (void)keyboardDidChangeFrameNotificationReceived:(NSNotification *)notification;

@end

@implementation PRSocialComposeViewController

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (void)updateUI
{
    NSUInteger textLength = self.textView.text.asciiLength;
    self.doneButton.enabled = textLength && textLength <= self.maxASCIITextLength;
    
    BOOL exceedMaxLength = self.textView.text.asciiLength > self.maxASCIITextLength;
    self.textLengthLabel.text = @((NSInteger)(self.maxASCIITextLength - self.textView.text.asciiLength - (exceedMaxLength ? 1 : 0)) / 2).stringValue;
    self.textLengthLabel.textColor = exceedMaxLength ? [UIColor colorWithRed:.97f green:.62f blue:.62f alpha:1.f] : [UIColor colorWithWhite:.61f alpha:1.f];
}

#pragma mark - Actions

- (void)cancelButtonClicked:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(composeViewControllerDidCancel:)]) {
            [self.delegate composeViewControllerDidCancel:self];
        }
    }];
}

- (void)doneButtonClicked:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.usesWebImage) {
            if ([self.delegate respondsToSelector:@selector(composeViewController:didFinishWithText:URL:imageURL:)]) {
                [self.delegate composeViewController:self didFinishWithText:self.textView.text URL:self.URL imageURL:self.imageURL];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(composeViewController:didFinishWithText:URL:image:)]) {
                [self.delegate composeViewController:self didFinishWithText:self.textView.text URL:self.URL image:self.image];
            }
        }
    }];
}

#pragma mark - Getters and setters

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        _image = image;
        if (image) {
            self.usesWebImage = NO;
        }
    }
}

- (void)setImageURL:(NSURL *)imageURL
{
    if (_imageURL != imageURL) {
        _imageURL = imageURL;
        if (imageURL.absoluteString.length) {
            self.usesWebImage = YES;
        }
    }
}

#pragma mark - Life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.maxASCIITextLength = 280;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
    self.doneButton = doneButton;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView = containerView;
    [self.view addSubview:containerView];
    
    CGRect bounds = CGRectInset(containerView.bounds, 5.f, 5.f);
    
    UILabel *textLengthLabel = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(CGRectGetMinX(bounds),
                                                                                     CGRectGetMaxY(bounds) - kTextLengthLabelHeight,
                                                                                     CGRectGetWidth(bounds),
                                                                                     kTextLengthLabelHeight),
                                                                          5.f,
                                                                          0)];
    textLengthLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleTopMargin);
    textLengthLabel.font = [UIFont systemFontOfSize:kTextLengthLabelFontSize];
    self.textLengthLabel = textLengthLabel;
    [containerView addSubview:textLengthLabel];
    
    UIView *imageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bounds) - kImageViewWidth,
                                                                           CGRectGetMinY(bounds),
                                                                           kImageViewWidth,
                                                                           kImageViewHeight)];
    imageBackgroundView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleBottomMargin);
    imageBackgroundView.backgroundColor = [UIColor lightGrayColor];
    imageBackgroundView.alpha = .3f;
    imageBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageBackgroundView.layer.shadowRadius = 1.f;
    imageBackgroundView.layer.shadowOpacity = .5f;
    self.imageBackgroundView = imageBackgroundView;
    [containerView addSubview:imageBackgroundView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(imageBackgroundView.frame,
                                                                            5.f,
                                                                            5.f)];
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleBottomMargin);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    self.imageView = imageView;
    [containerView addSubview:imageView];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(bounds),
                                                                        CGRectGetMinY(bounds),
                                                                        CGRectGetWidth(bounds) - kImageViewWidth - 5.f,
                                                                        CGRectGetHeight(bounds) - kTextLengthLabelHeight)];
    textView.delegate = self;
    textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
    textView.font = [UIFont systemFontOfSize:kTextViewFontSize];
    self.textView = textView;
    [containerView addSubview:textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.textView.text = self.initialText;
    if (self.usesWebImage) {
        NSURL *imageURL = self.imageURL;
        if (imageURL.absoluteString.length) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *image = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                });
            });
        }
    } else {
        self.imageView.image = self.image;
    }
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameNotificationReceived:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameNotificationReceived:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateUI];
}

#pragma mark - Keyboard notification

- (void)keyboardDidChangeFrameNotificationReceived:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect containerViewFrame = self.containerView.frame;
    CGRect keyboardBeginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    containerViewFrame.size.height = CGRectGetHeight(self.view.bounds) - (CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMinY(keyboardBeginFrame));
    self.containerView.frame = containerViewFrame;
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    containerViewFrame.size.height = CGRectGetHeight(self.view.bounds) - (CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMinY(keyboardEndFrame));
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:NO];
    self.containerView.frame = containerViewFrame;
    [UIView commitAnimations];
}

@end
