//
//  IMCImageItem.h
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCAutoLoadableImageView.h"

@interface IMCImageItem : UIView {
    IMCAutoLoadableImageView* thumbnailImage;
    UIButton* clickButton;
}

@property (nonatomic, strong) UITextView* thumbnailLabel;

- (id)initWithItemDictionary:(NSDictionary*)dictionary showLabel:(BOOL) bShowLabel;
-(void) addShadow;
-(UIImageView*) getImageView;


@property NSArray* allImageViews;

@end
