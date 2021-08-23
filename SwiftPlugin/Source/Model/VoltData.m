//
//  VoltData.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import "VoltData.h"

@implementation VoltData

@synthesize count, errorCode, ad, dec;

- (void)errorSetup:(int)errorCode_
{
    errorCode = errorCode_;
}

- (NSDictionary*)toNSDictionary
{
    return  [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:count], @"count",
             [NSNumber numberWithInt:ad], @"ad",
             [NSNumber numberWithInt:dec], @"dec",
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

@end
