//
//  IMCMediaCard.h
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCImageItem.h"
#import "IMCVideoItem.h"
#import "IMCBaseCard.h"

@interface IMCMediaCard : UIScrollView {
    NSMutableArray* views;
}

-(id) initWithCardDictionary:(NSDictionary*)dict;

@end
