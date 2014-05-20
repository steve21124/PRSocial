//
//  PRSocialAuthWebViewController.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSString+PRSocialURLCoding.h"
#import "PRSocialAuthWebViewController.h"

@interface PRSocialAuthWebViewController ()

@property (nonatomic, strong) NSURL *authURL;
@property (nonatomic, strong) NSURL *callbackURL;

@property (nonatomic, weak) UIBarButtonItem *cancelBarButton;
@property (nonatomic, weak) UIBarButtonItem *refreshBarButton;
@property (nonatomic, weak) UIBarButtonItem *stopBarButton;
@property (nonatomic, weak) UIWebView *webView;

// Actions
- (void)cancelButtonClicked:(UIButton *)button;
- (void)refreshButtonClicked:(UIButton *)button;
- (void)stopButtonClicked:(UIButton *)button;

// Web view control
- (void)loadAuthPage;
- (void)stopLoading;

// View control
- (void)dismiss;

@end

@implementation PRSocialAuthWebViewController

#pragma mark - Actions

- (void)cancelButtonClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(authWebViewControllerDidCancel:)]) {
        [self.delegate authWebViewControllerDidCancel:self];
    }
    [self dismiss];
}

- (void)refreshButtonClicked:(UIButton *)button
{
    [self loadAuthPage];
}

- (void)stopButtonClicked:(UIButton *)button
{
    [self stopLoading];
}

#pragma mark - Web view control

- (void)loadAuthPage
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authURL];
    [self.webView loadRequest:request];
}

- (void)stopLoading
{
    [self.webView stopLoading];
}

#pragma mark - View control

- (void)dismiss
{
    self.webView.delegate = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(authWebViewControllerDidDismiss:)]) {
            [self.delegate authWebViewControllerDidDismiss:self];
        }
    }];
}

#pragma mark - Life cycle

+ (void)promptWithAuthURL:(NSURL *)authURL callbackURL:(NSURL *)callbackURL delegate:(id<PRSocialAuthWebViewControllerDelegate>)delegate
{
    // Find the window on the top.
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *topWindow = application.keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        for (UIWindow *window in application.windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                topWindow = window;
                break;
            }
        }
    }
    
    // Present view controller.
    UINavigationController *navigationController = [PRSocialAuthWebViewController navigationControllerWithAuthURL:authURL callbackURL:callbackURL delegate:delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [topWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
    });
}

+ (UINavigationController *)navigationControllerWithAuthURL:(NSURL *)authURL
                                                callbackURL:(NSURL *)callbackURL
                                                   delegate:(id<PRSocialAuthWebViewControllerDelegate>)delegate
{
    PRSocialAuthWebViewController *authWebViewController = [[[self class] alloc] init];
    authWebViewController.delegate = delegate;
    authWebViewController.authURL = authURL;
    authWebViewController.callbackURL = callbackURL;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authWebViewController];
    return navigationController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)];
    self.cancelBarButton = cancelBarButton;
    
    UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClicked:)];
    self.refreshBarButton = refreshBarButton;
    
    UIBarButtonItem *stopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonClicked:)];
    self.stopBarButton = stopBarButton;
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButton;
    self.navigationItem.rightBarButtonItem = self.refreshBarButton;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleHeight);
    webView.delegate = self;
    self.webView = webView;
    [self.view addSubview:webView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadAuthPage];
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

#pragma mark - Interface orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? YES : toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.navigationItem setRightBarButtonItem:self.stopBarButton animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.navigationItem setRightBarButtonItem:self.refreshBarButton animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.navigationItem setRightBarButtonItem:self.refreshBarButton animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = YES;
    if (webView == self.webView) {
        if ([request.URL.absoluteString rangeOfString:self.callbackURL.absoluteString].location == 0) {
            NSDictionary *responseDictionary = [request.URL.query prs_URLDecodedDictionary];
            shouldLoad = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(authWebViewController:didSucceedWithResponseDictionary:)]) {
                    [self.delegate authWebViewController:self didSucceedWithResponseDictionary:responseDictionary];
                }
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1f];
            });
        }
    }
    return shouldLoad;
}

@end
