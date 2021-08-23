//
//  SwiftPluginBirdge.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/12/21.
//

#import <Foundation/Foundation.h>
#import "NetServiceBrowserDelegate.h"

static NetServiceBrowserDelegate* delegateObject = nil;
static NSNetServiceBrowser *serviceBrowser = nil;

// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
    if (string)
        return [NSString stringWithUTF8String: string];
    else
        return [NSString stringWithUTF8String: ""];
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

extern "C" {

    void _StartLookup (const char* service, const char* domain)
    {
        if (delegateObject == nil)
            delegateObject = [[NetServiceBrowserDelegate alloc] init];
        
        
        if (serviceBrowser == nil)
            serviceBrowser = [[NSNetServiceBrowser alloc] init];
        
        [serviceBrowser setDelegate:delegateObject];
        
        // Call "searchForServicesOfType" and pass NSStrings as parameters. By default mono
        // marshals all .Net strings as UTF-8 C style strings.
        [serviceBrowser searchForServicesOfType: CreateNSString(service) inDomain: CreateNSString(domain)];
    }
    
    const char* _GetLookupStatus ()
    {
        // By default mono string marshaler creates .Net string for returned UTF-8 C string
        // and calls free for returned value, thus returned strings should be allocated on heap
        return MakeStringCopy([[delegateObject getStatus] UTF8String]);
    }
    
    int _GetServiceCount ()
    {
        return [delegateObject getCount];
    }
    
    const char* _GetServiceName (int serviceNumber)
    {
        // By default mono string marshaler creates .Net string for returned UTF-8 C string
        // and calls free for returned value, thus returned strings should be allocated on heap
        return MakeStringCopy([[[delegateObject getService:serviceNumber] name] UTF8String]);
    }
    
    void _Stop()
    {
        [serviceBrowser stop];
    }
    
}
