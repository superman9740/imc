//
//  IMCCardDataSource.m
//  imc
//
//  Created by Andry Rozdolsky on 2/20/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCCardDataSource.h"
#import "XMLReader.h"


#import "IMCTextCard.h"
#import "IMCImageAndTextCard.h"
#import "IMCImageOnlyCard.h"
#import "IMCMediaCard.h"
#import "IMCScriptsCard.h"

@implementation IMCCardDataSource

-(id)initWithMenuItems:(NSArray*)items {
    if (self = [super init]) {
        cards = items;
    }
    
    return self;
}


-(int) count {
    return [cards count];
}

-(NSString*) titleForItem:(int)itemIndex {
    NSDictionary* card = [cards objectAtIndex:itemIndex];
    return [card xmlGetNodeAttribute:@"title"];
}

-(IMCDataSource*) getChildDataSourceForItem:(int)itemIndex {
    return nil;
}

-(IMCBaseCard*) getCardViewForItem:(int)itemIndex {
    IMCBaseCard* res = nil;
    
    //'text_only', 'media_clips', 'image_full', 'image_left', 'image_right', 'scripts'
    
    NSDictionary* card = [cards objectAtIndex:itemIndex];
    
    NSString* cardKind = [card xmlGetNodeAttribute:@"kind"];
    
    if ([cardKind isEqualToString:@"text_only"]) {
        IMCTextCard* textCard = [[IMCTextCard alloc] initWithCardDictionary:card];
        res = textCard;
    } else if([cardKind isEqualToString:@"media_clips"] || [cardKind isEqualToString:@"auto_video"]) {
        IMCMediaCard* mediaCard = [[IMCMediaCard alloc] initWithCardDictionary:card];
        res = mediaCard;
        
    } else if([cardKind isEqualToString:@"image_full"]) {
        IMCImageOnlyCard* imageCard = [[IMCImageOnlyCard alloc] initWithCardDictionary:card];
        res = imageCard;
    } else if([cardKind isEqualToString:@"image_left"]) {
        IMCImageAndTextCard* imageAndTextCard = [[IMCImageAndTextCard alloc] initWithCardDictionary:card andSetImageFirst:YES];
        res = imageAndTextCard;
    } else if([cardKind isEqualToString:@"image_right"]) {
        IMCImageAndTextCard* imageAndTextCard = [[IMCImageAndTextCard alloc] initWithCardDictionary:card andSetImageFirst:NO];
        res = imageAndTextCard;
    } else if([cardKind isEqualToString:@"scripts"]) {
        IMCScriptsCard* scriptCard = [[IMCScriptsCard alloc] initWithCardDictionary:card];
        res = scriptCard;
    }
    
    
    return res;
    
}

-(BOOL) loadData {
    return YES;
}





@end
