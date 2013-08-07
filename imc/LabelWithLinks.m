//
//  LabelWithLinks.m
//  IMCPortal
//
//  Created by Shane Dickson on 7/20/13.
//  Copyright (c) 2013 Gilbert Creative. All rights reserved.
//

#import "LabelWithLinks.h"

@implementation LabelWithLinks

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    const CGFloat* colors = CGColorGetComponents(self.textColor.CGColor);
    
    CGContextSetRGBStrokeColor(ctx, colors[204], colors[0], colors[0], 1.0); // RGBA
    
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGSize tmpSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(200, 9999)];
    
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height);
    CGContextAddLineToPoint(ctx, tmpSize.width, self.bounds.size.height);
    
    //CGContextStrokePath(ctx);
    
    [super drawRect:rect];
}



@end
