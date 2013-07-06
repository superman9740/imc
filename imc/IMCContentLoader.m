//
//  ContentLoader.m
//  imc
//
//  Created by Andry Rozdolsky on 2/28/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCContentLoader.h"
#import "IMCKeyChainWrapper.h"



//#define SERVER_BASE_URL @"http://gilbertcreative.herokuapp.com"
#define SERVER_BASE_URL @"http://coke-imc.com/portal"

#define SERVER_BASE_URL_TEMPLATE SERVER_BASE_URL@"/%@"
#define LOGIN_PATH @"users/sign_in"
#define MAIN_XML_PATH @"config/data.xml"
#define UPDATE_XML_PATH @"config/updates.xml"
#define TOOLKIT_XML_PATH_TEMPLATE @"media/xml/%@.xml"
#define MENUITEM_RESOURCE_PATH_TEMPLATE @"media/jpg/%@"



//#define LOCAL_XML

static IMCContentLoader* _instance = nil;


@implementation IMCContentLoader

+ (IMCContentLoader *)instance
{
    if (!_instance)
    {
        _instance = [[IMCContentLoader alloc] init];
    }
    
    return _instance;
}

-(NSURL*) getBaseUrl {
    return [NSURL URLWithString:SERVER_BASE_URL];
}

-(NSString*) getBaseUrlString {
    return SERVER_BASE_URL;
}



-(NSString*) urlEscapeString:(NSString*)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string,
                                                               NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8 ));
}

-(NSString*) getMenuitemResourceSubPathForName:(NSString*)name {
    return [NSString stringWithFormat:MENUITEM_RESOURCE_PATH_TEMPLATE, name];
}

-(BOOL) tryAutoLogin {
    
    BOOL bRes = NO;

    
    NSString* name = [IMCKeychainWrapper getUserName];
    NSString* pwd = [IMCKeychainWrapper getPassword];
    
    if (name&&pwd) {
        bRes = [self setCredentialsWithName:name andPassword:pwd  rememberMe:NO];
    }
    
    return bRes;
}

-(BOOL) setCredentialsWithName:(NSString*)name andPassword:(NSString*)password rememberMe:(BOOL) bRemeberMe {
    
#ifdef LOCAL_XML
    return YES;
#endif
    
    if (bRemeberMe) {
        [IMCKeychainWrapper storeUserName:name andPwd:password];
    } 
    
    NSString* url = [NSString stringWithFormat:SERVER_BASE_URL_TEMPLATE, LOGIN_PATH];    
    
    NSURLResponse *response;
    NSError *error = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        return NO;
    }
    
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
    
    NSString *authenticityToken = [[httpResp allHeaderFields] objectForKey:@"X-Authenticity-Token"];
    
    NSString *loginForm = [NSString stringWithFormat:@"user[email]=%@&user[password]=%@&authenticity_token=%@&commit=1&utf8=✓", [self urlEscapeString:name], [self urlEscapeString:password],
                           [self urlEscapeString:authenticityToken]];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[loginForm dataUsingEncoding:NSUTF8StringEncoding]];
    

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ((nil != error) || (nil == data))
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed to load data" message:error.debugDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        });
        
        NSLog(@"Error while data loading:\nData:%@\nRequest:%@\nResponse:%@\nError:%@\n", data, request, response, error.debugDescription);
        data = nil;
        
    }
    
    

    NSLog(@"Response: %@, len: %d", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding], [data length]);
    

    
    return data && ([[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] rangeOfString:@"name=\"user[password]\""].length == 0);
}

-(void) logOut {
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [IMCKeychainWrapper removeCredentials];
}

-(NSData*) getMainXML {
    
#ifdef LOCAL_XML
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"xml"]];
#endif

    
    NSString* url = [NSString stringWithFormat:SERVER_BASE_URL_TEMPLATE, MAIN_XML_PATH];
    return [self performRequestForURL:[NSURL URLWithString:url]];
}

-(NSData*) getUpdateXML {
    
#ifdef LOCAL_XML
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"updates" ofType:@"xml"]];
#endif

    
    NSString* url = [NSString stringWithFormat:SERVER_BASE_URL_TEMPLATE, UPDATE_XML_PATH];
    return [self performRequestForURL:[NSURL URLWithString:url]];    
}

-(NSData*) getToolkitXML:(NSString*)fileName {
    
#ifdef LOCAL_XML
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"]];
#endif
    
    NSString* urlEnding = [NSString stringWithFormat:TOOLKIT_XML_PATH_TEMPLATE, fileName];
    
    NSString* url = [NSString stringWithFormat:SERVER_BASE_URL_TEMPLATE, urlEnding];
    return [self performRequestForURL:[NSURL URLWithString:url]];
    
}

-(NSData*) getMenuitemResource:(NSString*)name {
    
    NSString* urlEnding = [self getMenuitemResourceSubPathForName:name];;
    
    NSString* url = [NSString stringWithFormat:SERVER_BASE_URL_TEMPLATE, urlEnding];
    return [self performRequestForURL:[NSURL URLWithString:url]];
    
}

-(NSData*) getMenuitemResourceCached:(NSString*)name {
    
    NSData* res = nil;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"menuItemResources"];
    filePath = [rootPath stringByAppendingPathComponent:name];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        res = [NSData dataWithContentsOfFile:filePath];
    } else {
        res = [self getMenuitemResource:name];
        [res writeToFile:filePath atomically:YES];
    }
    
    return res;
}

-(NSData*) getContentResource:(NSString*)name {
    
    NSString* url = @"";
    
    return [self performRequestForURL:[NSURL URLWithString:url]];
    
}

-(NSData*) getGenericResource:(NSString*)urlPath {
    
    NSString* url = [NSString stringWithFormat:SERVER_BASE_URL_TEMPLATE, urlPath ];
    
    return [self performRequestForURL:[NSURL URLWithString:url]];
    
}


- (NSData*) performRequestForURL:(NSURL*)url {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ((nil != error) || (nil == data))
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed to load data" message:error.debugDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
        });
        
        NSLog(@"Error while data loading:\nData:%@\nRequest:%@\nResponse:%@\nError:%@\n", data, request, response, error.debugDescription);
        data = nil;
    }
    
    NSLog(@"Response: %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    
    return data;
    
}


@end
