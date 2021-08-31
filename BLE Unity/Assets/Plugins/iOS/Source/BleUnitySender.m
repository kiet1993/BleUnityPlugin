//
//  BleUnitySender.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/30/21.
//

#import "BleUnitySender.h"

@implementation BleUnitySender
static NSString* recieverObjectName = @"BleReceiver";

+ (void)didBleManagerChangeStateWith:(NSString *)state
{
   UnitySendMessage([recieverObjectName UTF8String], [@"DidBleManagerChangeStateWith" UTF8String], [state UTF8String]);
}

+ (void)didScanTimeOut
{
   UnitySendMessage([recieverObjectName UTF8String], [@"DidScanTimeOut" UTF8String], [@"" UTF8String]);
}

+ (void)didConnectPeripheralWith:(NSString *)state
{
   UnitySendMessage([recieverObjectName UTF8String], [@"DidConnectPeripheralWith" UTF8String], [state UTF8String]);
}

+ (void)didDiscoverZealLe0:(NSString *)device
{
   UnitySendMessage([recieverObjectName UTF8String], [@"DidDiscoverZealLe0" UTF8String], [device UTF8String]);
}

+ (void)didReceiveBloodPressureData:(NSString *)data
{
   UnitySendMessage([recieverObjectName UTF8String], [@"DidReceiveBloodPressureData" UTF8String], [data UTF8String]);
}

+ (void)deviceDidChangeStatePowerOff
{
   UnitySendMessage([recieverObjectName UTF8String], [@"DeviceDidChangeStatePowerOff" UTF8String], [@"" UTF8String]);
}

+ (void)didUpdateMeasureStep:(NSString *)stepsString
{
   UnitySendMessage([recieverObjectName UTF8String], [@"DidUpdateMeasureStep" UTF8String], [stepsString UTF8String]);
}
@end
