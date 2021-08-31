//
//  BleUnitySender.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/30/21.
//

#import "BleUnitySender.h"

extern void UnitySendMessage(const char *, const char *, const char *);

@implementation BleUnitySender
static NSString* recieverObjectName = @"BleReceiver";

+ (void)didBleManagerChangeStateWith:(NSString *)state
{
//    UnitySendMessage([recieverObjectName UTF8String], [@"didBleManagerChangeStateWith" UTF8String], [state UTF8String]);
}

+ (void)didScanTimeOut
{
//    UnitySendMessage([recieverObjectName UTF8String], [@"didScanTimeOut" UTF8String], nil);
}

+ (void)didConnectPeripheralWith:(NSString *)state
{
//    UnitySendMessage([recieverObjectName UTF8String], [@"didConnectPeripheralWith" UTF8String], [state UTF8String]);
}

+ (void)didDiscoverZealLe0:(NSString *)device
{
//    UnitySendMessage([recieverObjectName UTF8String], [@"didDiscoverZealLe0" UTF8String], [device UTF8String]);
}

+ (void)didReceiveBloodPressureData:(NSString *)data
{
//    UnitySendMessage([recieverObjectName UTF8String], [@"didReceiveBloodPressureData" UTF8String], [data UTF8String]);
}

+ (void)deviceDidChangeStatePowerOff
{
//    UnitySendMessage([recieverObjectName UTF8String], [@"deviceDidChangeStatePowerOff" UTF8String], nil);
}

+ (void)didUpdateMeasureStep:(NSString *)stepsString
{
//    UnitySendMessage([recieverObjectName UTF8String], [@"didUpdateMeasureStep" UTF8String], [stepsString UTF8String]);
}
@end
