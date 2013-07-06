//
//  IMCMainContentProvider.h
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCMenuDataSource.h"


@interface IMCMainContentProvider : NSObject {

    NSDictionary* menuTree;
    NSDictionary* webConfig;
    NSDictionary* locationConfig;
    NSArray* contactConfig;
    NSDictionary* stringsConfig;
    NSDictionary* helpConfig;
    
    NSMutableDictionary* linksConfigById;
    NSMutableDictionary* emailsConfigById;
    NSMutableDictionary* contactsById;
}

-(id)initWithXML:(NSData*) configXml;
-(IMCMenuDataSource*) getRootMenuDataSource;

-(NSDictionary*) getHelpConfig;
-(NSArray*) getContacts;

-(NSDictionary*) getEmailConfigById:(NSString*)eid;
-(NSDictionary*) getLinkConfigById:(NSString*)lid;
-(NSDictionary*) getContactById:(NSString*)cid;

-(IMCDataSource*) getHelpMenuDataSource;


@end
