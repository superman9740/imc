//
//  IMCImageOnlyCard.m
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCImageOnlyCard.h"
#import "XMLReader.h"

@implementation IMCImageOnlyCard


-(id) initWithCardDictionary:(NSDictionary*)dictionary {
    self = [super initWithCardDictionary:dictionary];
    if (self) {
        
        NSArray* items = [dictionary xmlGetAllChildNodes:@"item"];
        imageView = nil;
        
        for (NSDictionary* itemDict in items) {
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"image"]) {
                imageView = [[IMCImageItem alloc] initWithItemDictionary:itemDict showLabel:NO];
                break;
            }
        }
        [self addSubview:imageView];
        
        [imageView setAllImageViews:@[[imageView getImageView]]];
        
    }
    
    return self;
}

-(void) layoutSubviews {
    [imageView setFrame:CGRectMake(0, 0,
                                   self.frame.size.width, self.frame.size.height)];
    [super layoutSubviews];
}

@end
