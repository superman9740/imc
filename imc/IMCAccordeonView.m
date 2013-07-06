//
//  IMCAccordeonView.m
//  imc
//
//  Created by Andry Rozdolsky on 2/20/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCAccordeonView.h"
#import "IMCContentLoader.h"
#import "globalDefines.h"
#import "QuartzCore/CALayer.h"

@implementation IMCAccordeonView


- (id)initWithFrame:(CGRect)frame andHorizontalOrientation:(BOOL)horizontalOrientation
{
    self = [super initWithFrame:frame];
    if (self) {
        bHorizontalOrientation = horizontalOrientation;
        self.visibleBackgroundColor = [UIColor whiteColor];
        contentView = [[UIView alloc] initWithFrame:frame];
        [contentView setBackgroundColor:[UIColor clearColor]];
        //[contentView setOpaque:NO];
        [contentView setClipsToBounds:YES];
  
    }
    return self;
}

-(void) layoutSubviews {
    [super layoutSubviews];
}

-(void) clear {
    for (UIView* v in [self subviews]) {
        [v removeFromSuperview];
    }
    [self addSubview:contentView];
}


-(void) setDataSource:(IMCCardDataSource*)source {
    dataSource = source;
    if ([dataSource count]) {
        [self buildUI];
    } else {
        [self clear];
    }
}


-(void)buildUI {
    
    [self clear];
    
    
    
    buttons = [NSMutableArray array];
    delimiters = [NSMutableArray array];
    if (bHorizontalOrientation) {
        inButtonRects = [NSMutableArray array];
    }
    
    BOOL bFirst = YES;
    
    for(int i = [dataSource count]-1; i >= 0 ; i--) {
        
        NSString* title = [dataSource titleForItem:i];
        
        if (!bFirst) {
            UIView* delimiter = [[UIView alloc] initWithFrame:CGRectZero];
            [delimiter setBackgroundColor:[UIColor colorWithRed:0.882f green:0.882f
                                                           blue:0.882f alpha:1.f]];
            [self addSubview:delimiter];
            [delimiters addObject:delimiter];
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn setTitleColor:IMC_COKE_RED_COLOR forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        [[btn titleLabel] setFont:[UIFont fontWithName:IMC_MEDIUM_FONT_NAME size:14]];
        
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(5, 10, 0, 0)];
        
        if (bHorizontalOrientation) {
            
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(5, 28, 0, 0)];
            
            [btn setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
            
            UIView* rect = [[UIView alloc] initWithFrame:CGRectMake(9, 11, 15, 15)];
            [btn addSubview:rect];
            [rect setBackgroundColor:IMC_COKE_RED_COLOR];
            rect.layer.cornerRadius = 3.f;
            
            [inButtonRects addObject:rect];
        }
        
        [btn addTarget:self action:@selector(activeCardChangedByBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
        [buttons addObject:btn];
        bFirst = NO;
    }
    
    activeCard = 0;
    [self setActiveCard:[buttons count] - 1 animated:NO];
    
    if (bHorizontalOrientation) {
        [self updateCardLayoutHorizontal];
    } else {
        [self updateCardLayoutVertical];
    }
    
}


-(void)updateCardLayoutHorizontal {
    
    int offset = 0;
    
    for(int i = 0; i <= activeCard; i ++) {
        
        if (i>0) {
            UIView* delimiter = [delimiters objectAtIndex:i-1];
            [delimiter setFrame:CGRectMake(offset, 0, 3, self.frame.size.height)];
            
            offset+= 3;
        }
        
        UIButton *btn = [buttons objectAtIndex:i];
        
        [btn setFrame:CGRectMake(offset,
                                 0, 40, self.frame.size.height)];
        offset+= 40;
    }
    
    int offset2 = self.frame.size.width;
    
    for(int i = [buttons count] - 1; i > activeCard; i--) {
        
        offset2-= 40;
        
        UIButton *btn = [buttons objectAtIndex:i];
        
        [btn setFrame:CGRectMake(offset2, 0, 40, self.frame.size.height)];
        
            
        offset2-= 3;
        
        UIView* delimiter = [delimiters objectAtIndex:i-1];
        [delimiter setFrame:CGRectMake(offset2, 0, 3, self.frame.size.height)];
        
    }
    
    
    contentViewFrame = CGRectMake(offset, 0, offset2-offset-5, self.frame.size.height-5);
    [contentView setFrame:contentViewFrame];
    
}

-(void)updateCardLayoutVertical {
    
    int offset = 0;
    
    for(int i = 0; i <= activeCard; i ++) {
        
        if (i>0) {
            UIView* delimiter = [delimiters objectAtIndex:i-1];
            [delimiter setFrame:CGRectMake(0, offset, self.frame.size.width, 3)];
            
            offset+= 3;
        }
        
        UIButton *btn = [buttons objectAtIndex:i];
        
        [btn setFrame:CGRectMake(0,
                                 offset, self.frame.size.width, 40)];
        offset+= 40;
    }
    
    int offset2 = self.frame.size.height;
    
    for(int i = [buttons count] - 1; i > activeCard; i--) {
        
        offset2-= 40;
        
        UIButton *btn = [buttons objectAtIndex:i];
        
        [btn setFrame:CGRectMake(0, offset2, self.frame.size.width, 40)];
        
        
        offset2-= 3;
        
        UIView* delimiter = [delimiters objectAtIndex:i-1];
        [delimiter setFrame:CGRectMake(0, offset2, self.frame.size.width, 3)];
        
    }
    
    
    contentViewFrame = CGRectMake(15, offset-10, self.frame.size.width-20, offset2-offset+5);
    [contentView setFrame:contentViewFrame];
    
}

-(void) setActiveCard:(int)index animated:(BOOL)bAnimated {
    [[buttons objectAtIndex:index] setEnabled:NO];
    if (activeCard != index) {
        [[buttons objectAtIndex:activeCard] setEnabled:YES];    
    }
    if (inButtonRects) {
        [[inButtonRects  objectAtIndex:index] setBackgroundColor:[UIColor blackColor]];
        if (activeCard != index) {
            [[inButtonRects objectAtIndex:activeCard] setBackgroundColor:IMC_COKE_RED_COLOR];
        }
    }
    
    activeCard = index;
    
    if (bAnimated) {
        
        [contentView setAlpha:0.f];
        
        [UIView animateWithDuration:0.25f animations:^{
            if (bHorizontalOrientation) {
                [self updateCardLayoutHorizontal];
            } else {
                [self updateCardLayoutVertical];
            }
        } completion:^(BOOL finished) {
            [contentView setAlpha:1.f];
            
        }];
    } else {
        if (bHorizontalOrientation) {
            [self updateCardLayoutHorizontal];
        } else {
            [self updateCardLayoutVertical];
        }
    }
    
    [self updateActiveContent];
}

-(void) updateActiveContent {
    for (UIView* child in [contentView subviews]) {
        [child removeFromSuperview];
    }
    IMCBaseCard* newContentView = [dataSource getCardViewForItem:[dataSource count] - activeCard- 1];
    [contentView addSubview:newContentView];
    
    [newContentView setFrame:CGRectMake(0, 0, [contentView frame].size.width,
                                        [contentView frame].size.height)];
}


-(void) activeCardChangedByBtn:(UIButton*)btn {

    [self setActiveCard:[buttons indexOfObject:btn] animated:YES];
    

}

@end
