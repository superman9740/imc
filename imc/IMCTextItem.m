//
//  IMCTextItem.m
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "globalDefines.h"

#import "IMCTextItem.h"
#import "XMLReader.h"
#import "IMCContentLoader.h"
#import "IMCUserSession.h"

#import "IMCBRowserViewController.h"

@implementation IMCTextItem

- (id)initWithCardItemDict:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"text_item_template" ofType:@"html"];
        
        NSString *template = [NSString stringWithContentsOfFile:fullPath
                                                       encoding:NSUTF8StringEncoding error:nil];
        
        NSString* html = [[dictionary xmlGetLastChildNode:@"text"] xmlGetNodeText];
        
        if (html) {
            
            
            //TMP ?
            html = [html stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
            
            NSMutableString *str = [[NSMutableString alloc] initWithString:html];
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                          @"</li>\\s*<br>" options:0 error:nil];
            [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"</li>"];
            
            NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:
                                          @"<li>\\s*<second>" options:0 error:nil];
            [regex2 replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"<li class='second'>"];
            
            NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:
                                          @"</second>\\s*</li>" options:0 error:nil];
            [regex3 replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"</li>"];
            
            
            html = str;
            
            ///
            
            //NSLog(@"%@", html);
        
        
            html = [NSString stringWithFormat:template, html];
        }
        
        webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        
        
        [webView loadHTMLString:html baseURL:[[IMCContentLoader instance] getBaseUrl]];
        [webView setBackgroundColor: [UIColor clearColor]];
        [webView setOpaque:NO];
       
        
        [self addSubview:webView];
        [webView scrollView].scrollEnabled = NO;
        
        [webView setDelegate:self];
        	
    }
    return self;
}

-(void) layoutSubviews {
    [webView setFrame:[self bounds]];
    
    [webView setFrame:CGRectMake(0, 10, self.bounds.size.width, webView.scrollView.contentSize.height)];
    [self setContentSize:CGSizeMake(self.bounds.size.width, webView.scrollView.contentSize.height+18)];
    
    [super layoutSubviews];
}


-(NSString*) urlEscapeString:(NSString*)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string,
                                                                                 NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    BOOL bRes = YES;
    
    NSString* urlString = [[request URL] description];
    
    NSString* linkEventPrefix = @"event:link%7C";
    NSString* emailEventPrefix = @"event:email%7C";
    
    if ([urlString hasPrefix:linkEventPrefix]) {
        NSString* lid = [urlString substringFromIndex:[linkEventPrefix length]];
        
        NSDictionary* dict = [[[IMCUserSession currentSession] rootContentProvider]
                              getLinkConfigById:lid];
        NSString* linkUrl = [dict xmlGetNodeAttribute:@"url"];
        
        if ([linkUrl hasPrefix:@"/"]) {
            NSString* domain =  [[IMCContentLoader instance] getBaseUrlString];
            linkUrl = [domain stringByAppendingString:linkUrl];
        }
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:@[linkUrl]
                                                             forKeys:@[@"url"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HTML_PREVIEW_NOTIFICATION object:nil userInfo:userInfo];

        
        
        bRes = NO;
    }
    
    if ([urlString hasPrefix:emailEventPrefix]) {
        [urlString substringFromIndex:[emailEventPrefix length]];
        
        NSString* eid = [urlString substringFromIndex:[emailEventPrefix length]];
        
        NSDictionary* dict = [[[IMCUserSession currentSession] rootContentProvider]
                              getEmailConfigById:eid];
        
        NSString* toId = [dict xmlGetNodeAttribute:@"to"];
        NSString* subject = [dict xmlGetNodeAttribute:@"subject"];
        NSString* message =[dict xmlGetNodeAttribute:@"message"];
        
        
        NSDictionary* toContact = [[[IMCUserSession currentSession] rootContentProvider]
                                   getContactById:toId];
        
        NSString* toEmail = [toContact xmlGetNodeAttribute:@"email"];
        
        if (toEmail) {
            
            if (![subject length]) {
                subject = @"";
            }
            
            if (![message length]) {
                message = @"";
            }
            
            subject = [self urlEscapeString:subject];
            message = [self urlEscapeString:message];
            
            NSString* linkUrl = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", toEmail,
                                 subject, message];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkUrl]];
        }
        
        
        bRes = NO;
    }
    
    return bRes;
    
}



@end
