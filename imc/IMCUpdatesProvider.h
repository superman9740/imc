//
//  IMCUpdatesProvider.h
//  imc
//
//  Created by Andry Rozdolsky on 3/21/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMCUpdateMessage: NSObject

@property NSDate* messageDate;
@property NSString* messageTitle;
@property NSString* messageText;

@end

@interface IMCUpdatesProvider : NSObject {
    NSArray* messages;
}

-(void) loadData;

-(int) updatesCount;

-(IMCUpdateMessage*) getUpdateMessageAtIndex:(int) index;

@end
