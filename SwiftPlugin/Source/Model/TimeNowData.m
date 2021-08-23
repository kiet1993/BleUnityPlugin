//
//  TimeNowData.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import "TimeNowData.h"

@implementation TimeNowData

@synthesize year, month, day, hour, minute, second;
@synthesize checksum, errorCode;

- (void)errorSetup:(int)errorCode_ {
    errorCode = errorCode_;
}

- (NSDictionary*)toNSDictionary {
    return  [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:year], @"year",
             [NSNumber numberWithInt:month], @"month",
             [NSNumber numberWithInt:day], @"day",
             [NSNumber numberWithInt:hour], @"hour",
             [NSNumber numberWithInt:minute], @"minute",
             [NSNumber numberWithInt:second], @"second",
             [NSNumber numberWithInt:checksum], @"checksum",
             [NSNumber numberWithInt:errorCode], @"errorCode",
             nil
             ];
}

+ (int)successCode
{
    return  0;
}

+ (int)errorDisconneced
{
    return  -2;
}

+ (int)timeOutCode
{
    return  -300;
}

+ (int)errorCode
{
    return  -200;
}

@end
