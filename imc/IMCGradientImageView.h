//
//  IMCGradientImage.h
//  imc
//
//  Created by Andry Rozdolsky on 4/5/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCGradientImageView : UIImageView

-(void)createGradientWithColor:(UIColor*)color bFadeToTop:(BOOL)bToTop;

@end
