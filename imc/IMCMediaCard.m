//
//  IMCMediaCard.m
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCMediaCard.h"
#import "XMLReader.h"

@implementation IMCMediaCard

-(id) initWithCardDictionary:(NSDictionary*)dictionary {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        NSArray* items = [dictionary xmlGetAllChildNodes:@"item"];
        views = [[NSMutableArray alloc] init];
        
        NSMutableArray* imageViews = [NSMutableArray array];
        
        for (NSDictionary* itemDict in items) {
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"image"]) {
                IMCImageItem* imageView = [[IMCImageItem alloc]
                                           initWithItemDictionary:itemDict showLabel:YES];
                [views addObject:imageView];
                [imageView addShadow];
                [self addSubview:imageView];
                
                [imageViews addObject:[imageView getImageView]];
                
            }
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"video"]) {
                IMCVideoItem* videoView = [[IMCVideoItem alloc]
                                           initWithItemDictionary:itemDict];
                [views addObject:videoView];
                [self addSubview:videoView];
                
            }
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"audio"]) {
                IMCVideoItem* videoView = [[IMCVideoItem alloc]
                                           initWithItemDictionary:itemDict];
                [views addObject:videoView];
                [self addSubview:videoView];
                
            }
        }
        
        for (UIView *v in views) {
            if ([v isKindOfClass:[IMCImageItem class]]) {
                [(IMCImageItem*)v setAllImageViews:imageViews];
            }
        }
        
        
        
        
    }
    
    return self;
}

-(void) layoutSubviews {
    
    int cnt = [views count];
    
    float itemWidth = self.frame.size.width + 220;
    itemWidth = (cnt>2)?itemWidth/2.5:itemWidth/cnt;
    
    for (int i = 0; i < cnt; i++) {
        
        IMCImageItem* imageView = [views objectAtIndex:i];
        
       
             
        
        [imageView setFrame:CGRectMake(itemWidth*i+15, 10,
                                       itemWidth-10, self.frame.size.height-20)];
        
    }
    
    [self setContentSize:CGSizeMake(itemWidth*cnt, self.frame.size.height)];
    
    [super layoutSubviews];
}

@end
