//
//  IMCScriptPreview.m
//  imc
//
//  Created by Andry Rozdolsky on 4/4/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCScriptPreview.h"
#import "globalDefines.h"
#import <CoreText/CoreText.h>
#import "IMCUserSession.h"
#import "XMLReader.h"

@implementation IMCScriptPreview

-(void) appearWithScriptsTexts:(NSArray*)scriptTexts activeScriptIndex:(int)index {
    
    
    texts = scriptTexts;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    scriptViews = [NSMutableArray array];
    
    backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    [backgroundView setAlpha:0.f];
    [self addSubview: backgroundView];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:scrollView];
    
    int pageIndex = 0;
    
    int frameBorder;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        frameBorder = 60;
    } else {
        frameBorder = 20;
    }
    
    
    for (NSString* textCard in scriptTexts) {
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(frameBorder + pageIndex*self.frame.size.width,
                                                                self.frame.size.height + frameBorder,
                                                                self.frame.size.width-frameBorder*2,
                                                                self.frame.size.height-frameBorder*2)];
        [scrollView addSubview: view];
        
        [view setBackgroundColor:[UIColor whiteColor]];
        
        NSAttributedString* attributedText = [self processScript:textCard];
        
        CGRect scriptFrame;
        int btnOffset = 3;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            scriptFrame = CGRectInset([view bounds], 40, 20);
            btnOffset = 25;
        } else {
            scriptFrame = CGRectInset([view bounds], 25, 20);
        }
        
        UIScrollView* itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                    view.frame.size.width,
                                                                    view.frame.size.height)];
        
        [view addSubview:itemScrollView];
        
        UILabel* scriptLabel = [[UILabel alloc] initWithFrame:scriptFrame];
        
        [itemScrollView addSubview:scriptLabel];
        [scriptLabel setAttributedText:attributedText];
        [scriptLabel setNumberOfLines:0];
        
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
        CGSize targetSize = CGSizeMake(scriptFrame.size.width, CGFLOAT_MAX);
        CGSize rectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedText length]), NULL, targetSize, NULL);
        CFRelease(framesetter);
        
        //rectSize.size.height = 1000;
        
        UIButton* sendEmailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemScrollView addSubview:sendEmailBtn];
        [sendEmailBtn setTitle:@"/Edit and Send" forState:UIControlStateNormal];
        
        [sendEmailBtn setTitleColor:IMC_COKE_RED_COLOR forState:UIControlStateNormal];
        
        scriptFrame.size.height = rectSize.height+20;
        
        
        
        [sendEmailBtn addTarget:self action:@selector(sendEmail:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [sendEmailBtn setTag:pageIndex];
        
        if (rectSize.height + 60 > itemScrollView.bounds.size.height) {
            
            [itemScrollView setContentSize:CGSizeMake(itemScrollView.frame.size.width, scriptFrame.size.height+90)];
            
            [sendEmailBtn setFrame:CGRectMake(btnOffset, scriptFrame.size.height+35, 160, 36)];
            
            
        } else {
            
            int offset = (itemScrollView.bounds.size.height - rectSize.height - 60)/2.- 10.;
            
            scriptFrame.origin.y += offset;
            
            [sendEmailBtn setFrame:CGRectMake(btnOffset, offset + scriptFrame.size.height+35, 160, 36)];
        }
        
        [scriptLabel setFrame:scriptFrame];
        
        [scriptViews addObject:view];
        pageIndex++;
    }
    
    [scrollView setContentSize:CGSizeMake(self.frame.size.width*pageIndex, self.frame.size.height)];
    [scrollView setPagingEnabled:YES];
    
    [scrollView setContentOffset:CGPointMake(self.frame.size.width*index, 0) animated:NO];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"Close-1.png"] forState:UIControlStateNormal];
    [self addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(disappear) forControlEvents:UIControlEventTouchUpInside];
    
    [closeBtn setFrame:CGRectMake(self.frame.size.width - 80, 0, 80, 80)];
    [backgroundView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    
    [UIView animateWithDuration:0.3f animations:^{

        int pageIndex = 0;
        for (UIView* view in scriptViews) {
            
            [view setFrame:CGRectMake(frameBorder + pageIndex*self.frame.size.width,
                                      frameBorder,
                                      self.frame.size.width-2*frameBorder,
                                      self.frame.size.height-2*frameBorder)];
            pageIndex++;
        }
        
        [backgroundView setAlpha:0.6f];
    }];
}



-(NSString*) urlEscapeString:(NSString*)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string,
                                                                                 NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 ));
}



-(void) sendEmail:(UIButton*)sender {
    
    NSDictionary* dict = [[[IMCUserSession currentSession] rootContentProvider]
                          getEmailConfigById:@"radio_scripts"];
    
    NSString* toId = [dict xmlGetNodeAttribute:@"to"];
    NSString* subject = [dict xmlGetNodeAttribute:@"subject"];
    NSString* message =[dict xmlGetNodeAttribute:@"message"];
    
    
    NSDictionary* toContact = [[[IMCUserSession currentSession] rootContentProvider]
                               getContactById:toId];
    
    NSString* toEmail = [toContact xmlGetNodeAttribute:@"email"];
    

    if (!toEmail) {
        toEmail = @"";
    }
    
    if (![subject length]) {
        subject = @"";
    }
    
    if (![message length]) {
        message = @"";
    }
    
    NSString* text = texts[sender.tag];
    
    if (text) {
        message = [message stringByAppendingFormat:@"\n\n %@", text];
    }
    
    
    subject = [self urlEscapeString:subject];
    message = [self urlEscapeString:message];
    
    NSString* linkUrl = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", toEmail,
                         subject, message];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkUrl]];

    
}



-(NSAttributedString*) processScript:(NSString*)text {
    
    NSString* resString = nil;
    
    NSArray* componets = [text componentsSeparatedByString:@"{{"];
    
    if ([componets count]) {
        resString = [componets objectAtIndex:0];
    }
    
    NSMutableArray* ranges = [NSMutableArray array];
    
    for (int i = 1; i < [componets count]; i++) {
        NSArray* subComponents = [componets[i] componentsSeparatedByString:@"}}"];
        
        if ([subComponents count] == 2) {
            NSRange range = NSMakeRange([resString length], [subComponents[0] length]);
            [ranges addObject:[NSValue valueWithRange:range]];
        }
        
        for (NSString* s in subComponents) {
            resString = [resString stringByAppendingString:s];
        }
        
    }
    
    NSMutableAttributedString* attrString  = [[NSMutableAttributedString alloc]
                                       initWithString:resString
                                       attributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:16.f]}];
    
    for (NSValue* val in ranges) {
        NSRange range = [val rangeValue];
        [attrString setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18.f]} range:range];
    }
    
    
    return attrString;
}



-(void) disappear {
    [UIView animateWithDuration:0.3f animations:^{
        [backgroundView setAlpha:0.0f];
        
        int frameBorder;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            frameBorder = 60;
        } else {
            frameBorder = 20;
        }
        
        int pageIndex = 0;
        for (UIView* view in scriptViews) {
            
            [view setFrame:CGRectMake(frameBorder + pageIndex*self.frame.size.width,
                                      self.frame.size.width+frameBorder,
                                      self.frame.size.width-frameBorder*2,
                                      self.frame.size.height-frameBorder*2)];
            pageIndex++;
        }
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
    
    
}

@end
