//
//  PreloadWebView.m
//  StaffApp
//
//  Created by stolyarov on 13/10/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "PreloadHtml.h"
#import "UIScreen+Utils.h"
//#import "FlashUpdate.h"
#import <UIKit/UIWebView.h>

@interface PreloadHtml() <UIWebViewDelegate>
{
    void(^_onSuccessBlock)(NSArray *result);
    NSMutableArray *_result;
    NSUInteger _htmlAmount;
    NSMutableArray *_webViews;
    
    UIViewController *_vc;
}

@end

@implementation PreloadHtml

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _vc = vc;
    
    return self;
}


- (void)preloadHtmls:(NSArray *)htmlArray
          withFrames:(NSArray *)webViewFrames
           onSuccess:(void(^)(NSArray *))onSuccess
             onError:(void(^)(NSError *error))onError{
    
    _htmlAmount = htmlArray.count;
    _result = [[NSMutableArray alloc] initWithCapacity:_htmlAmount];
    _webViews = [[NSMutableArray alloc] initWithCapacity:_htmlAmount];
    for (int i = 0; i < _htmlAmount; i++) {
        UIWebView *w = [[UIWebView alloc] initWithFrame: [webViewFrames[i] CGRectValue]];
        w.scrollView.scrollEnabled = NO;
        w.hidden = YES;
        [w setDelegate:self];
        w.restorationIdentifier = [NSString stringWithFormat:@"%d", i];
        
        [_vc.view addSubview:w];
        [w loadHTMLString:(NSString *)htmlArray[i] baseURL:nil];
        [_webViews addObject:w];
    }
    _onSuccessBlock = onSuccess;
}

//- (void)preloadFlashUpdates:(NSArray *)flashUpdates
//                   forWidth:(NSArray *)textWidth
//                  onSuccess:(void(^)(NSArray *))onSuccess
//                    onError:(void(^)(NSError *error))onError
//{
//    
//}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    frame.size = [webView sizeThatFits:CGSizeZero];
    webView.frame = frame;
    
    [_result insertObject:@(frame.size.height) atIndex:[webView.restorationIdentifier intValue]];
    webView.delegate = nil;
    [webView removeFromSuperview];
    webView = nil;
    
    if (_result.count == _htmlAmount) {
        _onSuccessBlock(_result);
    }
}

@end
