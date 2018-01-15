//
//  ViewController.m
//  JSAndOCInteractionWKWebViewDemo
//
//  Created by KODIE on 2018/1/15.
//  Copyright © 2018年 kodie. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configWKWebView];
}

- (void)configWKWebView{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.minimumFontSize = 50;
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
    [self.view addSubview:self.wkWebView];
    
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    
    NSURL *url = [NSURL URLWithString:@"https://m.benlai.com/huanan/zt/1231cherry"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.wkWebView loadRequest:request];
    
    
    WKUserContentController *userCC = config.userContentController;
    [userCC addScriptMessageHandler:self name:@"showMessage"];
}


#pragma mark - WKNavigationDelegate
///加载完成网页的时候才开始注入JS代码,要不然还没加载完时就可以点击了,就不能调用我们的代码了!
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"data.txt" ofType:nil];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.wkWebView evaluateJavaScript:str completionHandler:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    NSLog(@"%@",message);
    NSLog(@"%@",message.body);
    NSLog(@"%@",message.name);
    
    //这个是注入JS代码后的处理效果,尽管html已经有实现了,但是没用,还是执行JS中的实现
    if ([message.name isEqualToString:@"showMessage"]) {
        NSArray *array = message.body;
        NSLog(@"%@",array.firstObject);
        NSString *str = [NSString stringWithFormat:@"产品ID是: %@",array.firstObject];
        [self showMsg:str];
    }
}

#pragma mark - private
- (void)showMsg:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

@end
