//
//  IMCAutoLoadableImageView.m
//  imc
//
//  Created by Andry Rozdolsky on 3/11/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCAutoLoadableImageView.h"
#import "IMCContentLoader.h"

@implementation IMCAutoLoadableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void) loadFromURL:(NSString*)urlSubpath {
    activityIndicator = [[UIActivityIndicatorView alloc] init];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityIndicator];
    [activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* picData = [[IMCContentLoader instance] getGenericResource:urlSubpath];
        UIImage* pic = [UIImage imageWithData:picData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:pic];
            [activityIndicator removeFromSuperview];
        });
    });
    
}

-(void) layoutSubviews {
    CGRect parentFrame = [self frame];
    //float middleX = parentFrame.size.width/2;
    //float middleY = parentFrame.size.height/2;
    
    [activityIndicator setFrame:CGRectMake(0, 0, parentFrame.size.width, parentFrame.size.height)];
    
    [super layoutSubviews];
}


@end
