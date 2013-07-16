//
//  IMCBRowserViewController.m
//  imc
//
//  Created by Andry Rozdolsky on 4/9/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCBRowserViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface IMCBRowserViewController ()

@end

@implementation IMCBRowserViewController


-(void) appearWithUrl:(NSString*)_url {
    url = _url;
}

-(void) viewWillAppear:(BOOL)animated {
    
    [[webView scrollView] setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
    
    [backBtn setEnabled:NO];
    [forwardBtn setEnabled:NO];
    
    
    [webView setDelegate:self];

    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [[webView scrollView] scrollsToTop];
}

-(void) webViewDidStartLoad:(UIWebView *)webView {
    
    loaderView = [[UIView alloc] initWithFrame:webView.frame];
    loaderView.backgroundColor = [UIColor blackColor];
    loaderView.alpha = .6;
    spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinnerView.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [spinnerView startAnimating];
    [loaderView addSubview:spinnerView];
    [self.view addSubview:loaderView];
    
}

-(void) webViewDidFinishLoad:(UIWebView *)_webView {
    [backBtn setEnabled:[webView canGoBack]];
    [forwardBtn setEnabled:[webView canGoForward]];
    [loaderView removeFromSuperview];
    [spinnerView stopAnimating];
    [spinnerView setHidden:YES];
    

}

-(void) webView:(UIWebView *)_webView didFailLoadWithError:(NSError *)error {
    [backBtn setEnabled:[webView canGoBack]];
    [forwardBtn setEnabled:[webView canGoForward]];
    [loaderView setHidden:YES];
    
    
    [webView loadHTMLString:@"<h1><center>Failed to load page!</center></h1>" baseURL:[NSURL URLWithString:@"/"]];
}

-(IBAction)back {
    [webView goBack];
}
-(IBAction)forward {
    [webView goForward];
}
-(IBAction)close {
    [webView setDelegate:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)openInSafary {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
