//
//  IMCUpdatesProvider.m
//  imc
//
//  Created by Andry Rozdolsky on 3/21/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCUpdatesProvider.h"
#import "IMCContentLoader.h"
#import "XMLReader.h"


@implementation IMCUpdateMessage

@synthesize messageDate;
@synthesize messageTitle;
@synthesize messageText;

@end




@implementation IMCUpdatesProvider

-(void) loadData {
    
    NSError *parseError = nil;
    NSData* updateXml = [[IMCContentLoader instance] getUpdateXML];
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:updateXml error:&parseError];
    
    NSArray* entries = [[xmlDictionary xmlGetLastChildNode:@"feed"] xmlGetAllChildNodes:@"entry"];
    
    NSMutableArray* resultItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary* item in entries) {
        IMCUpdateMessage* message = [[IMCUpdateMessage alloc] init];
        
        NSString* dateStr = [[item xmlGetLastChildNode:@"updated"] xmlGetNodeText];
        dateStr = [dateStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSDictionary* content = [item xmlGetLastChildNode:@"content"];
        NSDictionary* properties = [content xmlGetLastChildNode:@"m:properties"];
        
        NSDictionary* titleDict = [properties xmlGetLastChildNode:@"d:Title"];
        NSDictionary* bodyDict = [properties xmlGetLastChildNode:@"d:Body"];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        
        dateStr = [dateStr stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange([dateStr length] - 5,5)];
        [message setMessageDate:[dateFormatter dateFromString:dateStr]];
        
        [message setMessageText:[[bodyDict xmlGetNodeText]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet
                                                                  whitespaceAndNewlineCharacterSet]]];
        [message setMessageTitle:[[titleDict xmlGetNodeText]
                                  stringByTrimmingCharactersInSet:[NSCharacterSet
                                                                   whitespaceAndNewlineCharacterSet]]];
        
        [resultItems addObject:message];
    }
    
    messages = resultItems;
    
}

-(int) updatesCount {
    return [messages count];
}


-(IMCUpdateMessage*) getUpdateMessageAtIndex:(int) index {
    return [messages objectAtIndex:[messages count] - index - 1];
}


@end
