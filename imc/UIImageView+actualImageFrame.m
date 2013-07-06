//
//  UIImageView+actualImageFrame.m
//  imc
//
//  Created by Andry Rozdolsky on 3/29/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "UIImageView+actualImageFrame.h"

@implementation UIImageView (actualImageFrame)

-(CGRect) actualImageFrame
{
    CGSize imageSize = self.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.bounds)/imageSize.width, CGRectGetHeight(self.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(self.frame.origin.x +
                                   floorf(0.5f*(CGRectGetWidth(self.bounds)-scaledImageSize.width)),
                                   self.frame.origin.y +
                                   floorf(0.5f*(CGRectGetHeight(self.bounds)-scaledImageSize.height)), scaledImageSize.width,
                                   scaledImageSize.height);
    
    return imageFrame;
}

@end
