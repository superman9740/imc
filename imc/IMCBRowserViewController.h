//
//  IMCBRowserViewController.h
//  imc
//
//  Created by Andry Rozdolsky on 4/9/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCBRowserViewController : UIViewController<UIWebViewDelegate> {
    IBOutlet UIWebView* webView;
    NSString* url;
    
    IBOutlet UIButton* backBtn;
    IBOutlet UIButton* forwardBtn;
    
    IBOutlet UIView* loaderView;
}

-(void) appearWithUrl:(NSString*)_url ;

-(IBAction)back;
-(IBAction)forward;
-(IBAction)openInSafary;
-(IBAction)close;

@end
