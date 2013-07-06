//
//  IMCDataSource.h
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMCDataSource : NSObject<UITableViewDataSource>

-(int) count;
-(NSString*) titleForItem:(int)itemIndex;
-(IMCDataSource*) getChildDataSourceForItem:(int)itemIndex;

-(BOOL) loadData;

@end
