//
//  NetServiceBrowserDelegate.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/12/21.
//

#import "NetServiceBrowserDelegate.h"

@implementation NetServiceBrowserDelegate


- (id)init
{
    self = [super init];
    services = [[NSMutableArray alloc] init];
    searching = NO;
    status = @"Initializing";
    return self;
}


// Sent when browsing begins
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    searching = YES;
    status = @"Searching";
    
    [services removeAllObjects];
}



// Sent when browsing stops
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    searching = NO;
    status = @"Done";
}



// Sent if browsing fails
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
    searching = NO;
    NSString * msg = @"Failed.";
    status = [msg stringByAppendingString:[[errorDict objectForKey:NSNetServicesErrorCode] stringValue]];
}



// Sent when a service appears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [services addObject:aNetService];
}



// Sent when a service disappears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [services removeObject:aNetService];
}


- (int)getCount
{
    return [services count];
}

- (NSNetService *)getService:(int)serviceNo
{
    return [services objectAtIndex:serviceNo];
}

- (NSString *)getStatus
{
    return status;
}

@end
