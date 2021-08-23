//
//  TimeMeasureData.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import "TimeMeasureData.h"

@implementation TimeMeasureData
@synthesize day, hourMor, minuteMor, hourAf, minuteAf;
@synthesize checksum, errorCode;

- (void)errorSetup:(int)errorCode_
{
    errorCode = errorCode_;
}

- (NSDictionary *)toNSDictionary {
    return  [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:day], @"day",
             [NSNumber numberWithInt:hourMor], @"hour_mor",
             [NSNumber numberWithInt:minuteMor], @"minute_mor",
             [NSNumber numberWithInt:hourAf], @"hour_af",
             [NSNumber numberWithInt:minuteAf], @"minute_af",
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
