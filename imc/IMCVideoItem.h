//
//  IMCVideoItem.h
//  imc
//
//  Created by Andry Rozdolsky on 3/28/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCImageItem.h"

@interface IMCVideoItem : UIView {
    IMCAutoLoadableImageView* thumbnailImage;
    NSMutableArray* thumbnailLabels;
    UIButton* clickButton;
    UIButton* scriptButton;
    NSString* videoUrl;
    
    NSString* script;
}

- (id)initWithItemDictionary:(NSDictionary*)dictionary;

@end
