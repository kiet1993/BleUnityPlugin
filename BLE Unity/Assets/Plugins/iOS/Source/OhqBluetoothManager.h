//
//  OhqBluetoothManager.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/12/21.
//

#import <Foundation/Foundation.h>
#import "Model/BloodPressureData.h"
#import "Model/DeviceData.h"
#import "Model/ConnectResponse.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OhqBluetoothManagerDelegate <NSObject>

@optional
- (void)didBleManagerChangeStateWith:(CBManagerState)result;
- (void)didScanTimeOut;
- (void)didConnectPeripheralWith:(BleConnectDeviceResponse)state;
- (void)didDiscoverZealLe0:(CBPeripheral *)device;
- (void)didReceiveBloodPressureData:(NSString *)data;
- (void)deviceDidChangeStatePowerOff;
- (void)didUpdateMeasureStep:(NSString *)stepsString;

@end

@interface OhqBluetoothManager : NSObject

@property (nonatomic, weak) id <OhqBluetoothManagerDelegate> delegate;

+ (OhqBluetoothManager *)sharedInstance;

- (void)initBleManager;
- (void)startScan;
- (void)stopScan;
- (NSArray<CBPeripheral *> *)retrieveConnectedDevices;
- (NSString *)retrieveConnectedPeripherals;
- (void)connectToScanDeviceWith:(NSString *)identifier;
- (void)startMeasureBloodPressure;
- (void)disconnectDevice;
@end

NS_ASSUME_NONNULL_END
