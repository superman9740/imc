//
//  IMCMainContentProvider.m
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCMainContentProvider.h"
#import "XMLReader.h"
#import "IMCMenuDataSource.h"

@implementation IMCMainContentProvider

-(id) initWithXML:(NSData*) configXml {
    
    self = [super init];

    if (self) {
        
        NSError *parseError = nil;
        NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:configXml error:&parseError];
        
        NSDictionary *config = [xmlDictionary xmlGetLastChildNode:@"config"];
        
        menuTree = [config xmlGetLastChildNode:@"menus"];
        
        webConfig = [config xmlGetLastChildNode:@"web"];
        locationConfig = [config xmlGetLastChildNode:@"locations"];
        contactConfig = [[config xmlGetLastChildNode:@"contacts"] xmlGetAllChildNodes:@"contact"];
        NSArray* _linksConfig = [[config xmlGetLastChildNode:@"links"] xmlGetAllChildNodes:@"link"];
        stringsConfig = [config xmlGetLastChildNode:@"strings"];
        NSArray* _emailsConfig = [[config xmlGetLastChildNode:@"emails"] xmlGetAllChildNodes:@"email"];
        helpConfig = [config xmlGetLastChildNode:@"help"];
        
        linksConfigById = [NSMutableDictionary dictionary];
        
        for (NSDictionary* link in _linksConfig) {
            NSString* linkId = [link xmlGetNodeAttribute:@"id"];
            [linksConfigById setObject:link forKey:linkId];
        }
        
        emailsConfigById = [NSMutableDictionary dictionary];
        
        for (NSDictionary* email in _emailsConfig) {
            NSString* emailId = [email xmlGetNodeAttribute:@"id"];
            [emailsConfigById setObject:email forKey:emailId];
        }
        
        contactsById = [NSMutableDictionary dictionary];

        for (NSDictionary* contact in contactConfig) {
            NSString* contactId = [contact xmlGetNodeAttribute:@"id"];
            [contactsById setObject:contact forKey:contactId];
        }

    }
    
    return self;
}

-(IMCMenuDataSource*) getRootMenuDataSource {
    NSArray* rootNodes = [menuTree xmlGetAllChildNodes:@"layer"];
    return [[IMCMenuDataSource alloc] initWithMenuItems:[rootNodes subarrayWithRange:NSMakeRange(0, 4)] useCategoryMode:YES];
}

-(IMCMenuDataSource*) getHelpMenuDataSource {
    
    IMCDataSource* ds = nil;
    
    NSArray* rootNodes = [menuTree xmlGetAllChildNodes:@"layer"];
    if ([rootNodes count]>4) {
        for (int i = 0; i < [rootNodes count]; i++) {
            if ([[rootNodes[i] xmlGetNodeAttribute:@"id" ] isEqualToString:@"Help"]) {
                ds = [[IMCMenuDataSource alloc] initWithMenuItems:@[rootNodes[5]]
                                                  useCategoryMode:YES] ;
            }
            
        }
        
    }
    return ds;
}

-(NSDictionary*) getHelpConfig {
    return helpConfig;
}

-(NSArray*) getContacts {
    return contactConfig;
}


-(NSDictionary*) getEmailConfigById:(NSString*)eid {
    return [emailsConfigById objectForKey:eid];
}


-(NSDictionary*) getLinkConfigById:(NSString*)lid {
    return [linksConfigById objectForKey:lid];
}

-(NSDictionary*) getContactById:(NSString*)cid {
    return [contactsById objectForKey:cid];
}


@end
