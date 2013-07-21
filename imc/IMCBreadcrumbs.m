//
//  IMCBreadcrumbs.m
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCBreadcrumbs.h"
#import "globalDefines.h"



@implementation IMCBreadcrumbsItem

@synthesize callback;
@synthesize dataSource;
@synthesize title;

@end



@implementation IMCBreadcrumbs


@synthesize delegate;



-(id) initWithRootItem:(IMCBreadcrumbsItem*)item
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        breadcrumbs = [NSMutableArray arrayWithObject:item ];
        [self buildUI];

    }
    return self;
}


-(void) pushBreadcrumbsItem:(IMCBreadcrumbsItem*)item {
    [breadcrumbs addObject:item];
    [self buildUI];
}


-(void) buildUI {
    
    int rowHeight = 30;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        rowHeight = 40;
        
    }

    
    int offset = 0;
    int offsetY = 0;
    
    [self clear];
    
    UIButton* btn = nil;
    
    int i = 0;
    
    for (IMCBreadcrumbsItem* itm in breadcrumbs) {
        
        btn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[NSString stringWithFormat:@"/ %@", [itm title]] forState:UIControlStateNormal];
        [btn setTitleColor:IMC_COKE_RED_COLOR forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1] forState:UIControlStateDisabled];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [[btn titleLabel] setFont:[UIFont boldSystemFontOfSize:22.]];
    } else {
        [[btn titleLabel] setFont:[UIFont boldSystemFontOfSize:18]];
    }
     
        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:itm.title];
        NSInteger strLength = [itm.title length];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:2];
        [str addAttribute:NSParagraphStyleAttributeName   value:style  range:NSMakeRange(0, strLength)];
       
        btn.titleLabel.attributedText = str;
        
        CGSize size = [[itm title] sizeWithFont:[[btn titleLabel] font]];
        
        if (offset && offset+size.width+10 > self.frame.size.width) {
            offset = 0;
            offsetY += rowHeight;
            if (size.width+20 > self.frame.size.width) {
                size.width = self.frame.size.width-30;
            }
        }
        
       // [btn.titleLabel setLineBreakMode:NSLine];
        
//        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(offset, offsetY, 8, rowHeight)];
//        [lbl setText:@"/"];
//        [lbl setBackgroundColor:[UIColor clearColor]];
//        [lbl setTextColor:[UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1]];
//        [lbl setFont:[UIFont boldSystemFontOfSize:20.]];
//        [self addSubview:lbl];


        
        btn.frame = CGRectMake(offset+4, offsetY, size.width+20, rowHeight);
        
        [btn addTarget:self action:@selector(breadcrumpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag = i++;
        
        offset += size.width+20;
        
        [self addSubview:btn];
        
        
    }
    
    height = offsetY + 40;
    
    
    //Disabling last button
    [btn setEnabled:false];
}


-(float) getHeight {
    return (height > 40)? height : 40;
}


-(void)breadcrumpBtnClicked:(UIButton*)btn {
    IMCBreadcrumbsItem* itm = [breadcrumbs objectAtIndex:btn.tag];
    
    for (int i = [breadcrumbs count]-1; i>btn.tag ; i--) {
        [breadcrumbs removeLastObject];
    }
    
    [self buildUI];
    
    if (delegate && [(NSObject*)delegate respondsToSelector:@selector(breadcrumbsItemSelected:)]) {
        [delegate breadcrumbsItemSelected:itm];
    }
    
}

-(void) resetBredcrumpsToRoot {
    
    for (int i = [breadcrumbs count]-1; i>0 ; i--) {
        [breadcrumbs removeLastObject];
    }
    [self buildUI];
}


-(void) clear {
    for (UIView* v in [self subviews]) {
        [v removeFromSuperview];
    }
}

-(int) lenght {
    return [breadcrumbs count];
}

@end
