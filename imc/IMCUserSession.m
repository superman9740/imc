//
//  IMCUserSession.m
//  imc
//
//  Created by Andry Rozdolsky on 4/4/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCUserSession.h"

static IMCUserSession* _currentSession = nil;

@implementation IMCUserSession


+(IMCUserSession*) currentSession {
    if (!_currentSession) {
        _currentSession = [[IMCUserSession alloc] init];
    }
    
    return _currentSession;
}

-(id) init {
    self = [super init];
    
    if (self) {
        rootContentProvider = nil;
    }
    
    return self;
}

-(void) clear {
    _currentSession = nil;
}

-(void) createContentProviderWithXML:(NSData*)xml {
    rootContentProvider = [[IMCMainContentProvider alloc] initWithXML:xml];
}


-(IMCMainContentProvider*) rootContentProvider {
    return rootContentProvider;
}

@end
