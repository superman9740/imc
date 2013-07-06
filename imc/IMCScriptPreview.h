//
//  IMCScriptPreview.h
//  imc
//
//  Created by Andry Rozdolsky on 4/4/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCScriptPreview : UIView {
    UIView* backgroundView;
    UIButton* closeBtn;
    
    UIScrollView* scrollView;
    
    NSMutableArray* scriptViews;
    NSArray* texts;
}

-(void) appearWithScriptsTexts:(NSArray*)scriptTexts activeScriptIndex:(int)index;

@end
