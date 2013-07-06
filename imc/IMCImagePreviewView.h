//
//  ImagePreviewViewController.h
//  imc
//
//  Created by Andry Rozdolsky on 3/28/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCImagePreviewView : UIView<UIScrollViewDelegate> {
    UIView* backgroundView;
    //UIImageView* imageView;
    //UIImageView* sourceImageView;
    UIButton* closeBtn;

    UIScrollView* scrollView;
    
    NSMutableArray* imageViews;
    NSMutableArray* scrollViews;
    NSArray* sourceImageViews;
}

-(void) appearWithImageContainers:(NSArray*)_sourceImageContainers activeImageIndex:(int)index;

@end
