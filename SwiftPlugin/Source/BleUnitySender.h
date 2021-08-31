//
//  BleUnitySender.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/30/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BleUnitySender : NSObject
+ (void)didBleManagerChangeStateWith:(NSString *)state;
+ (void)didScanTimeOut;
+ (void)didConnectPeripheralWith:(NSString *)state;
+ (void)didDiscoverZealLe0:(NSString *)device;
+ (void)didReceiveBloodPressureData:(NSString *)data;
+ (void)deviceDidChangeStatePowerOff;
+ (void)didUpdateMeasureStep:(NSString *)stepsString;
@end

NS_ASSUME_NONNULL_END
