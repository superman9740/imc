//
//  IMCImageItem.m
//  imc
//
//  Created by Andry Rozdolsky on 3/26/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCImageItem.h"
#import "XMLReader.h"
#import "QuartzCore/CALayer.h"

#import "globalDefines.h"

@implementation IMCImageItem

@synthesize allImageViews;

- (id)initWithItemDictionary:(NSDictionary*)dictionary showLabel:(BOOL) bShowLabel
{
    self = [super init];
    if (self) {
        thumbnailImage = [[IMCAutoLoadableImageView alloc] init];
        [thumbnailImage setContentMode:UIViewContentModeScaleAspectFit];
        NSString* imageUrl = [dictionary xmlGetNodeAttribute:@"file"];
        if ([imageUrl hasSuffix:@".swf"]) {
            imageUrl = [imageUrl substringToIndex:[imageUrl length]-4];
            imageUrl = [imageUrl stringByAppendingString:@".jpg"];
        }
        [thumbnailImage loadFromURL:imageUrl];
        
        [self addSubview:thumbnailImage];
        
        if (bShowLabel) {
            thumbnailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [thumbnailLabel setShadowColor:[UIColor clearColor]];
            [thumbnailLabel setBackgroundColor:[UIColor clearColor]];
            [thumbnailLabel setText:[dictionary xmlGetNodeAttribute:@"title"]];
            [thumbnailLabel setTextAlignment:NSTextAlignmentCenter];
            [self addSubview:thumbnailLabel];
        }
        
        clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:clickButton];
        [clickButton addTarget:self action:@selector(showImage) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

-(void) addShadow {
    thumbnailImage.layer.shadowColor = [UIColor blackColor].CGColor;
    thumbnailImage.layer.shadowOffset = CGSizeMake(5, 5);
    thumbnailImage.layer.shadowOpacity = 1;
    thumbnailImage.layer.shadowRadius = 4.0;
    thumbnailImage.clipsToBounds = NO;
}

-(void) layoutSubviews {
    if (thumbnailLabel) {
        [thumbnailImage setFrame:CGRectMake(0, 0, self.frame.size.width, 2*self.frame.size.height/3)];
        [thumbnailLabel setFrame:CGRectMake(0, 2*self.frame.size.height/3,
                                            self.frame.size.width, 20)];
    }else {
        [thumbnailImage setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    [clickButton setFrame:thumbnailImage.frame];
    [super layoutSubviews];
}

-(UIImageView*) getImageView {
    return thumbnailImage;
}


-(void) showImage {
    int i = 0;
    for (; i < [allImageViews count]; i++) {
        if ([allImageViews objectAtIndex:i] == thumbnailImage) {
            break;
        }
    }
    
    if (i == [allImageViews count]) {
        i = 0;
    }
    
    NSDictionary* paramsDict = [NSDictionary dictionaryWithObjects:@[allImageViews,
                                                                     [NSNumber numberWithInt:i]]
                                                           forKeys:@[@"thumbnailImageViews", @"activeImageIndex"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_PREVIEW_NOTIFICATION object:nil userInfo:paramsDict];
}



@end
