//
//  IMCTextCard.m
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCTextCard.h"
#import "XMLReader.h"

@implementation IMCTextCard

-(id) initWithCardDictionary:(NSDictionary*)dictionary {
    self = [super initWithCardDictionary:dictionary];
    if (self) {
        
        NSArray* items = [dictionary xmlGetAllChildNodes:@"item"];
        textView = nil;
        
        for (NSDictionary* itemDict in items) {
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"text"]) {
                textView = [[IMCTextItem alloc] initWithCardItemDict:itemDict];
                break;
            }
        }
        [self addSubview:textView];
        
    }
    
    return self;
}

-(void) layoutSubviews {
    [textView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
