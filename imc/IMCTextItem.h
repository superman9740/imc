//
//  IMCTextItem.h
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCTextItem : UIScrollView<UIWebViewDelegate> {
    UIWebView* webView;
}

- (id)initWithCardItemDict:(NSDictionary*)dictionary;

@end
