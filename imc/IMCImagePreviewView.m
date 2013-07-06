//
//  ImagePreviewViewController.m
//  imc
//
//  Created by Andry Rozdolsky on 3/28/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCImagePreviewView.h"
#import "UIImageView+actualImageFrame.h"



@implementation IMCImagePreviewView


-(void) appearWithImageContainers:(NSArray*)_sourceImageContainers activeImageIndex:(int)index {
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    sourceImageViews = _sourceImageContainers;
    
    imageViews = [NSMutableArray array];
    scrollViews = [NSMutableArray array];
    
    backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    [backgroundView setAlpha:0.f];
    [self addSubview: backgroundView];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:scrollView];
    
    int imageIndex = 0;
    
    for (UIImageView* sourceImageView in sourceImageViews) {
        [sourceImageView setAlpha:0.1f];
        
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:nil];
        
        
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        CGRect rect = [self convertRect:[sourceImageView actualImageFrame]
                                              fromView:sourceImageView];
        
        UIScrollView* childScrollView = [[UIScrollView alloc] initWithFrame: CGRectInset(CGRectOffset(rect, self.frame.size.width*index, 0), -20, -20)];
        
        
        [scrollView addSubview: childScrollView];
        [childScrollView addSubview: imageView];
        
        childScrollView.maximumZoomScale = 5.0f;
        childScrollView.delegate = self;
        childScrollView.showsHorizontalScrollIndicator = NO;
        childScrollView.showsVerticalScrollIndicator = NO;
        
        [childScrollView setAutoresizesSubviews:YES];
        
        [imageView setFrame:CGRectInset([childScrollView bounds], 20, 20) ];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

        
        [imageView setImage: [sourceImageView image]];
        
        
        [imageViews addObject:imageView];
        [scrollViews addObject:childScrollView];
        imageIndex++;
    }
    
    [scrollView setContentSize:CGSizeMake(self.frame.size.width*imageIndex, self.frame.size.height)];
    [scrollView setPagingEnabled:YES];
    
    [scrollView setContentOffset:CGPointMake(self.frame.size.width*index, 0) animated:NO];
    
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"Close-1.png"] forState:UIControlStateNormal];
    [self addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(disappear) forControlEvents:UIControlEventTouchUpInside];
    
    [closeBtn setFrame:CGRectMake(self.frame.size.width - 80, 0, 80, 80)];
    [backgroundView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    
    [UIView animateWithDuration:0.3f animations:^{
        
        int imageIndex = 0;
        
        for (UIView* scrlView in scrollViews) {
            
            [scrlView setFrame:CGRectMake(0+self.frame.size.width*imageIndex, 0,
                                           self.frame.size.width,
                                           self.frame.size.height)];
            imageIndex++;
        }
        
        [backgroundView setAlpha:0.6f];
    }];
}
                


-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView* res  = nil;
    for (int i =0; i < [scrollViews count]; i++) {
        if (scrollViews[i] == scrollView) {
            res = [imageViews objectAtIndex:i];
        }
    }
    return res;
}


-(void) disappear {
    [UIView animateWithDuration:0.3f animations:^{
        [backgroundView setAlpha:0.0f];
        
        int imageIndex = 0;
        for (UIView* scrlView in scrollViews) {
           
            UIImageView* sourceImageView = [sourceImageViews objectAtIndex:imageIndex];
            
            CGRect rect = [self convertRect:[sourceImageView actualImageFrame]
                                                  fromView:sourceImageView];
            
            [scrlView setFrame:CGRectInset(CGRectOffset(rect, [scrollView contentOffset].x, 0),-20,-20)];
            imageIndex++;
        }
        
    } completion:^(BOOL finished) {
        for (UIImageView* sourceImageView in sourceImageViews) {
            [sourceImageView setAlpha:1.f];
        }
        
        [self removeFromSuperview];

    }];
    

}


@end
