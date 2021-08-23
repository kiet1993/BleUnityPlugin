//
//  BloodPressureData.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import "BloodPressureData.h"

@implementation BloodPressureData
@synthesize systolic, diastolic, pulseRate, bodyMovementDetected;
@synthesize bodyMovementCount, irregularPulseDetected, irregularPulseRate, isCuffFitting;
@synthesize errorCode;

- (void)errorSetup:(int)errorCode_ {
    errorCode = errorCode_;
}

- (NSDictionary*)toNSDictionary {
    return  [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:systolic], @"systolic",
             [NSNumber numberWithInt:diastolic], @"diastolic",
             [NSNumber numberWithInt:pulseRate], @"pulseRate",
             [NSNumber numberWithInt:bodyMovementDetected], @"bodyMovementDetected",
             [NSNumber numberWithInt:bodyMovementCount], @"bodyMovementCount",
             [NSNumber numberWithInt:irregularPulseDetected], @"irregularPulseDetected",
             [NSNumber numberWithInt:irregularPulseRate], @"irregularPulseRate",
             [NSNumber numberWithInt:isCuffFitting], @"isCuffFitting",
             [NSNumber numberWithInt:errorCode], @"errorCode",
             nil
             ];
}

+ (int)successCode
{
    return  0;
}

+ (int)timeOutCode
{
    return  -300;
}

@end
