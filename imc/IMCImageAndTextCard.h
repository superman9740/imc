//
//  IMCImageAndTextCard.h
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCBaseCard.h"
#import "IMCTextItem.h"
#import "IMCImageItem.h"

@interface IMCImageAndTextCard : IMCBaseCard {
    IMCTextItem* textView;
    IMCImageItem* imageView;
    
    BOOL bImageFirst;
}

-(id) initWithCardDictionary:(NSDictionary*)dictionary andSetImageFirst:(BOOL)imageFirst;

@end
