//
//  DeviceData.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/30/21.
//

#import "DeviceData.h"

@implementation DeviceData
@synthesize name, uuid;

- (id)initWith:(NSString *)name uuid:(NSString *)uuid
{
    self.name = name;
    self.uuid = uuid;
    return  self;
}

- (NSDictionary*)toNSDictionary {
    return  [NSDictionary dictionaryWithObjectsAndKeys:
             name, @"name",
             uuid, @"uuid",
             nil
             ];
}

@end
