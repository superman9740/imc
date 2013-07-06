//
//  IMCAccordeonView.h
//  imc
//
//  Created by Andry Rozdolsky on 2/20/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCNoCornerView.h"
#import "IMCCardDataSource.h"
#import "IMCBaseCard.h"

@interface IMCAccordeonView : IMCNoCornerView {
    int activeCard;
    NSMutableArray* buttons;
    NSMutableArray* inButtonRects;
    NSMutableArray* delimiters;
    
    UIView* contentView;
    
    IMCCardDataSource* dataSource;
    CGRect contentViewFrame;
    
    BOOL bHorizontalOrientation;
}

- (id)initWithFrame:(CGRect)frame andHorizontalOrientation:(BOOL)horizontalOrientation;
-(void) setDataSource:(IMCCardDataSource*)source;

@end
