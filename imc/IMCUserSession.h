//
//  IMCUserSession.h
//  imc
//
//  Created by Andry Rozdolsky on 4/4/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMCMainContentProvider.h"


@interface IMCUserSession : NSObject {
    IMCMainContentProvider* rootContentProvider;
}

+(IMCUserSession*) currentSession;

-(void) clear;
-(void) createContentProviderWithXML:(NSData*)xml;

-(IMCMainContentProvider*) rootContentProvider;


@end
