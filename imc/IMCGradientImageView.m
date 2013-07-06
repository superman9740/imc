//
//  IMCGradientImage.m
//  imc
//
//  Created by Andry Rozdolsky on 4/5/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCGradientImageView.h"

@implementation IMCGradientImageView

-(void)createGradientWithColor:(UIColor*)color  bFadeToTop:(BOOL)bToTop{
    UIImage *mask = [UIImage imageNamed:@"gradient.png"];
    
    UIGraphicsBeginImageContext(mask.size);

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (bToTop) {
        CGContextTranslateCTM(context, 0, mask.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    
    CGRect maskRect = CGRectMake(0, 0, mask.size.width, mask.size.height);
    CGContextClipToMask(context, maskRect, [mask CGImage]);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, maskRect);
    
    [self setImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();

}

@end
