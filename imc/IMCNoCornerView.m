//
//  IMCNoCornerView.m
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCNoCornerView.h"
#import "QuartzCore/QuartzCore.h"

@implementation IMCNoCornerView

@synthesize visibleBackgroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self setBackgroundColor:[UIColor clearColor]];
            visibleBackgroundColor = [UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1];
        } else {
            [self setBackgroundColor:[UIColor whiteColor]];
        }
    }
    return self;
}

-(void) awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self setBackgroundColor:[UIColor clearColor]];
        visibleBackgroundColor = [UIColor colorWithRed:0.882f green:0.882f blue:0.882f alpha:1];
    } else {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void) layoutSubviews {
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorRef fillColor = [visibleBackgroundColor CGColor];
        CGContextSetFillColorWithColor(context, fillColor);
        
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, self.bounds.size.height);
        CGContextAddLineToPoint(context, self.bounds.size.width-16, self.bounds.size.height);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height-16);
        CGContextAddLineToPoint(context, self.bounds.size.width, 0);
        
        CGContextFillPath(context);

    }
}

@end
