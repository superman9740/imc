//
//  IMCDataSource.m
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCDataSource.h"

@implementation IMCDataSource

-(int) count {
    return 0;
}

-(NSString*) titleForItem:(int)itemIndex {
    return nil;
}

-(IMCDataSource*) getChildDataSourceForItem:(int)itemIndex; {
    return nil;
}

-(BOOL) loadData {
    return NO;
}

@end
