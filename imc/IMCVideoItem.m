//
//  IMCVideoItem.m
//  imc
//
//  Created by Andry Rozdolsky on 3/28/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCVideoItem.h"
#import "XMLReader.h"

#import "globalDefines.h"
#import "QuartzCore/CALayer.h"
#import "IMCContentLoader.h"



@implementation IMCVideoItem

- (id)initWithItemDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        
        BOOL bAudioOnly = [[dictionary xmlGetNodeAttribute:@"kind"] isEqualToString:@"audio"];
        
        thumbnailImage = [[IMCAutoLoadableImageView alloc] init];
        [thumbnailImage setContentMode:UIViewContentModeScaleAspectFit];
        
        if (bAudioOnly) {
            [thumbnailImage setImage:[UIImage imageNamed:@"audio_thumbnail.jpg"]];
        } else {
            NSString* imageUrl = [dictionary xmlGetNodeAttribute:@"thumbnail"];
            [thumbnailImage loadFromURL:imageUrl];
        }
        
        [self addSubview:thumbnailImage];
        
        thumbnailLabels = [[NSMutableArray alloc] init];
        
        videoUrl = [dictionary xmlGetNodeAttribute:@"file"];
        
        if ([videoUrl hasSuffix:@".flv"]) {
            videoUrl = [videoUrl substringToIndex:[videoUrl length]-4];
            videoUrl = [videoUrl stringByAppendingString:@".mp4"];
        }
        
        [self addLabelWithTitle:@"Title:" andText:[dictionary xmlGetNodeAttribute:@"title"]];
        [self addLabelWithTitle:@"Code:" andText:[dictionary xmlGetNodeAttribute:@"code"]];
        [self addLabelWithTitle:@"Length" andText:[dictionary xmlGetNodeAttribute:@"length"]];
        
        script = [[[dictionary xmlGetLastChildNode:@"copy"]
                   xmlGetLastChildNode:@"text"] xmlGetNodeText];
        
        if (!bAudioOnly && [script length]) {
            [self addLabelWithTitle:@"Live Read Copy:" andText:@"Click To See"];
            
            scriptButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:scriptButton];
            [scriptButton addTarget:self action:@selector(showScript)
                   forControlEvents:UIControlEventTouchDown];
        }
        [self addLabelWithTitle:@"" andText:@""];
        
        NSString* expBroadcast = [dictionary xmlGetNodeAttribute:@"exp_broadcast"];
        NSString* expInVenue = [dictionary xmlGetNodeAttribute:@"exp_in_venue"];
        NSString* expInternet = [dictionary xmlGetNodeAttribute:@"exp_internet"];
        
        if ([expBroadcast length] || [expInVenue length] || [expInternet length]) {
            [self addLabelWithTitle:@"EXPIRATION DATES:" andText:@""];
        }
        
        if ([expBroadcast length]) {
            [self addLabelWithTitle:@"Broadcast:" andText:expBroadcast];
        }
        
        if ([expInVenue length]) {
            [self addLabelWithTitle:@"In-Venue:" andText:expInVenue];
        }
        
        if ([expInternet length]) {
            [self addLabelWithTitle:@"Internet:" andText:expInternet];
        }
        
        thumbnailImage.layer.shadowColor = [UIColor blackColor].CGColor;
        thumbnailImage.layer.shadowOffset = CGSizeMake(5, 5);
        thumbnailImage.layer.shadowOpacity = 1;
        thumbnailImage.layer.shadowRadius = 4.0;
        thumbnailImage.clipsToBounds = NO;
        
        clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:clickButton];
        [clickButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchDown];


    }
    return self;
}

-(void) addLabelWithTitle:(NSString*)title andText:(NSString*)text {
    
    if([title isEqualToString:@"Code:"])
    {
    
        NSString* labelText = [NSString stringWithFormat:@"%@ %@\n",title, text];
        
        CopyLabel* thumbnailLabel = [[CopyLabel alloc] initWithFrame:CGRectZero];
        
        
        
        
        const CGFloat fontSize = 11;
        UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
        UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
        UIColor *foregroundColor = IMC_RED_COLOR;
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName,
                                  [UIColor blackColor],NSForegroundColorAttributeName, nil];
        const NSRange range = NSMakeRange([title length]+1,[text length]);
        
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:labelText
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        
        // Set it in our UILabel and we are done!
        [thumbnailLabel setAttributedText:attributedText];
        
        [thumbnailLabel setBackgroundColor:[UIColor clearColor]];
        
        [thumbnailLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:thumbnailLabel];
        [thumbnailLabels addObject:thumbnailLabel];
        
    }
    else
    {
    
        NSString* labelText = [NSString stringWithFormat:@"%@ %@\n",title, text];
        
        UILabel* thumbnailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        
        
        
        const CGFloat fontSize = 11;
        UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
        UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
        UIColor *foregroundColor = IMC_RED_COLOR;
        
        // Create the attributes
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName,
                                  [UIColor blackColor],NSForegroundColorAttributeName, nil];
        const NSRange range = NSMakeRange([title length]+1,[text length]);
        
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:labelText
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        
        // Set it in our UILabel and we are done!
        [thumbnailLabel setAttributedText:attributedText];
        
        [thumbnailLabel setBackgroundColor:[UIColor clearColor]];
        
        [thumbnailLabel setTextAlignment:NSTextAlignmentCenter];
        [thumbnailLabel becomeFirstResponder];
        
        [self addSubview:thumbnailLabel];
        [thumbnailLabels addObject:thumbnailLabel];
    }
    
}


-(void) showScript {
    NSDictionary* paramsDict = [NSDictionary dictionaryWithObjects:@[@[script],
                                [NSNumber numberWithInt:0]]
                                                           forKeys:@[@"scripArray", @"activeScriptIndex"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCRIPT_PREVIEW_NOTIFICATION object:nil userInfo:paramsDict];

}

-(void) layoutSubviews {

    [thumbnailImage setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
    [clickButton setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
    int i = 1;
    
    if ([thumbnailLabels count] == 9) {
        [scriptButton setFrame:CGRectMake(0, self.frame.size.height/2+13*3,
                                          self.frame.size.width, 52)];
    }
    
    for (UILabel* thumbnailLabel in thumbnailLabels) {
        [thumbnailLabel setFrame:CGRectMake(0, self.frame.size.height/2+13*i,
                                            self.frame.size.width, 26)];
        i++;
    }


    [super layoutSubviews];
}

-(void) playVideo {
    
    NSString* fullURl = [[IMCContentLoader instance] getBaseUrlString];
    fullURl = [fullURl stringByAppendingString:videoUrl];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:@[fullURl, thumbnailImage]
                                                          forKeys:@[@"videoUrlString", @"thumbnailImageView"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VIDEO_PREVIEW_NOTIFICATION object:nil userInfo:userInfo];
}

@end
