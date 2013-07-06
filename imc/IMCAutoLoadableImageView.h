//
//  IMCAutoLoadableImageView.h
//  imc
//
//  Created by Andry Rozdolsky on 3/11/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCAutoLoadableImageView : UIImageView {
    UIActivityIndicatorView* activityIndicator;
}

-(void) loadFromURL:(NSString*)urlSubpath;

@end
