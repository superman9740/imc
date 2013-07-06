//
//  IMCImageAndTextCard.m
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCImageAndTextCard.h"
#import "XMLReader.h"

@implementation IMCImageAndTextCard

-(id) initWithCardDictionary:(NSDictionary*)dictionary andSetImageFirst:(BOOL)imageFirst {
    self = [super initWithCardDictionary:dictionary];
    if (self) {
        
        bImageFirst = imageFirst;
        
        NSArray* items = [dictionary xmlGetAllChildNodes:@"item"];
        textView = nil;
        
        for (NSDictionary* itemDict in items) {
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"text"]) {
                textView = [[IMCTextItem alloc] initWithCardItemDict:itemDict];
                break;
            }
        }
        [self addSubview:textView];
        
        imageView = nil;
        for (NSDictionary* itemDict in items) {
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"image"]) {
                imageView = [[IMCImageItem alloc] initWithItemDictionary:itemDict showLabel:YES];
                break;
            }
        }
        [self addSubview:imageView];
        
        [imageView setAllImageViews:@[[imageView getImageView]]];
        
    }
    
    return self;
}

-(void) layoutSubviews {
    if (!bImageFirst) {
        [textView setFrame:CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height)];
        [imageView setFrame:CGRectMake(self.frame.size.width/2, 0,
                                       self.frame.size.width/2, self.frame.size.height)];
        
    } else {
        [textView setFrame:CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, self.frame.size.height)];
        [imageView setFrame:CGRectMake(0, 0,
                                       self.frame.size.width/2, self.frame.size.height)];
        
    }
}

@end
