//
//  ContentLoader.h
//  imc
//
//  Created by Andry Rozdolsky on 2/28/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMCContentLoader : NSObject {
    
}

+ (IMCContentLoader *)instance;

-(BOOL) setCredentialsWithName:(NSString*)name andPassword:(NSString*)password rememberMe:(BOOL) bRemeberMe ;

-(BOOL) tryAutoLogin;
-(void) logOut;


-(NSURL*) getBaseUrl;
-(NSString*) getBaseUrlString;

-(NSData*) getMainXML;
-(NSData*) getUpdateXML;
-(NSData*) getToolkitXML:(NSString*)fileName;
-(NSData*) getMenuitemResource:(NSString*)name;

-(NSData*) getMenuitemResourceCached:(NSString*)name;

-(NSData*) getContentResource:(NSString*)name;
-(NSData*) getGenericResource:(NSString*)urlPath;

-(NSString*) getMenuitemResourceSubPathForName:(NSString*)name;


@end
