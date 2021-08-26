//
//  OhqBluetoothManager.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/12/21.
//

#define SERVICE_UUID @"27ADC9CA-35EB-465A-9154-B8FF9076F3E8"
#define CHARACTERISTIC_NOTIFY_UUID @"27ADC9CB-35EB-465A-9154-B8FF9076F3E8"
#define CHARACTERISTIC_WRITE_UUID @"27ADC9CC-35EB-465A-9154-B8FF9076F3E8"

#define SCAN_TIMEOUT 60

#import "OhqBluetoothManager.h"
#import <Foundation/Foundation.h>
#import "Model/Enum.h"

@interface OhqBluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    NSMutableArray * peripherals;
    NSArray<CBPeripheral *> *connectedDevices;
    NSTimer * timer;
    int countTime;
    BleState state;
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) CBCharacteristic *transferCharacteristic;

@end


@implementation OhqBluetoothManager

@synthesize connectedPeripheral;

+ (OhqBluetoothManager *)sharedInstance {
    static OhqBluetoothManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[OhqBluetoothManager alloc] init];
    });

    return _sharedInstance;
}

- (id)init {
    self = [super init];

    if(self) {
        peripherals = [[NSMutableArray alloc] init];
        countTime = 0;
        state = BleStateNone;
    }
    return self;
}

- (void)cleanup {
    // See if we are subscribed to a characteristic on the peripheral
    if (connectedPeripheral.services != nil) {
        for (CBService *service in connectedPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY_UUID]]) {
                        if (characteristic.isNotifying) {
                            [connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
 
    [self.centralManager cancelPeripheralConnection:connectedPeripheral];
    state = BleStateNone;
}

- (void)initBleManager
{
    if (self.centralManager == nil) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
}

- (void)startScan
{
    if (self.centralManager.isScanning) {
        NSLog(@"centralManager is scanning already");
        return;
    }
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [self.centralManager scanForPeripheralsWithServices:nil options:options];
        NSLog(@"Scanning started");
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(onTick:)
                                               userInfo:nil
                                                repeats:YES
                 ];
    } else {
        NSLog(@"self.centralManager.state not PoweredOn");
    }
}

-(void)onTick:(NSTimer *)timer {
    if (countTime >= SCAN_TIMEOUT) {
        [self stopScan];
    } else {
        countTime += 1;
    }
}

- (void)stopScan
{
    if (self.centralManager) {
        [self.centralManager stopScan];
    }
    [timer invalidate];
    timer = nil;
    countTime = 0;
    NSLog(@"Scanning stopped");
}

- (NSArray<CBPeripheral *> *)retrieveConnectedDevices
{
    CBUUID *uuid = [CBUUID UUIDWithString:SERVICE_UUID];
    connectedDevices = [self.centralManager retrieveConnectedPeripheralsWithServices:@[uuid]];
    return connectedDevices;
}

- (void)selectConnectedDeviceWith:(NSString *)identifier {
    for (CBPeripheral* item in connectedDevices) {
        NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:identifier];
        if (item.identifier == uuid) {
            connectedPeripheral = item;
            break;
        }
    }
}

- (void)connectToScanDeviceWith:(NSString *)identifier
{
    for (CBPeripheral* item in peripherals) {
        NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:identifier];
        if ([item.identifier isEqual:uuid]) {
            [self.centralManager connectPeripheral:item options:nil];
            break;
        }
    }
}

- (void)sendMeasureCommandToDevice {
}

- (void)disconnectDevice
{
    if (!(self.centralManager == nil || connectedPeripheral == nil)) {
        [self.centralManager cancelPeripheralConnection: connectedPeripheral];
        connectedPeripheral = nil;
        [peripherals removeAllObjects];
    }
}

- (NSString *)bleOrderToString: (BleOrder)order
{
    switch (order) {
        case BleOrderSetup:
            return @"M6\0\0\r\n";
        case BleOrderMeasureBloodPressure:
            return  @"MA\r\n";
        case BleOrderPowerOff:
            return @"MB\r\n";
    }
}

- (BleResponse)bleResponseStringToEnum:(NSString *) response
{
    if ([response isEqualToString:@"WUP"]) {
        return BleResponseChangeNormalMode;
    } else if ([response isEqualToString:@"OFF"]) {
        return BleResponsePowerOff;
    } else if ([response isEqualToString:@"WAI"]) {
        return BleResponseStandBy;
    } else if ([response isEqualToString:@"COM"]) {
        return BleResponseConnect;
    } else if ([response isEqualToString:@"ERR"]) {
        return BleResponseError;
    } else if ([response isEqualToString:@"rx"]) {
        return BleResponseBloodPressureResult1;
    } else if ([response isEqualToString:@"ra"]) {
        return BleResponseBloodPressureResult2;
    }
    return  BleResponseUnknown;
}

- (void)writeData:(BleOrder)order
{
    NSString *orderString = [self bleOrderToString:order];
    NSData *data = [orderString  dataUsingEncoding:NSUTF8StringEncoding];
    [self.connectedPeripheral writeValue:data forCharacteristic:self.transferCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void) handleDataResponse:(NSString *) responseString
{
    BleResponse response = [self bleResponseStringToEnum: responseString];
    switch (response) {
        case BleResponseUnknown:
            break;
        case BleResponseChangeNormalMode:
            break;
        case BleResponsePowerOff:
            break;
        case BleResponseStandBy:
            break;
        case BleResponseConnect:
            [self writeData: BleOrderMeasureBloodPressure];
            break;
        case BleResponseError:
            break;
        case BleResponseBloodPressureResult1:
            break;
        case BleResponseBloodPressureResult2:
            break;
    }
}

#pragma mark - CBCentralManager delegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn) {
        [self.delegate didBleManagerChangeStateWith:BleManagerStatePoweredOn];
    } else {
        [self.delegate didBleManagerChangeStateWith:BleManagerStatePoweredOff];
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    if (peripheral.name != nil && [peripheral.name containsString:@"ZEAL-LE0"]) {
        NSLog(@"%@", [NSString stringWithFormat:@"--didDiscoverPeripheral %@", peripheral.name]);
        [peripherals addObject:peripheral];
        [self.delegate didDiscoverZealLe0:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"--- didConnectPeripheral");
    [self stopScan];
    [self.delegate didConnectPeripheralWith:BleConnectDeviceResponseSuccess];

    NSLog(@"peripheral in didConnect function: %@", peripheral);
    NSLog(@"any services??: %@", peripheral.services);
    peripheral.delegate = self;
    connectedPeripheral = peripheral;
    CBUUID *uuid = [CBUUID UUIDWithString:SERVICE_UUID];
    [peripheral discoverServices:@[uuid]];
}


- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral
                 error:(nullable NSError *)error
{
    NSLog(@"--- did disconnect ConnectPeripheral");
    self.connectedPeripheral = nil;
}


- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    NSLog(@"Failed to connect");
    [self cleanup];
    [self.delegate didConnectPeripheralWith:BleConnectDeviceResponseFailed];
}

#pragma mark - CBPeripheralDelegate delegate methods

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    NSLog(@"--- didDiscoverServices");
    if (error) {
        [self cleanup];
        [self.delegate didConnectPeripheralWith:BleConnectDeviceResponseFailed];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSArray *characteristics = @[[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY_UUID],
                                     [CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID]];
        [peripheral discoverCharacteristics:characteristics forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
 didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    CBUUID *uuid = [CBUUID UUIDWithString:SERVICE_UUID];
    for (CBService *service in invalidatedServices) {
        if (service.UUID == uuid) {
            [peripheral discoverServices:@[uuid]];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    if (error) {
        [self cleanup];
        [self.delegate didConnectPeripheralWith:BleConnectDeviceResponseFailed];
        return;
    }
     
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY_UUID]]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.transferCharacteristic = characteristic;
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_WRITE_UUID]]) {
            self.transferCharacteristic = characteristic;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (error) {
        [self cleanup];
        return;
    }
    NSString *stringFromData = [[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self handleDataResponse: stringFromData];
         
    // Have we got everything we need?
    
//    if ([stringFromData isEqualToString:@"EOM"]) {
//        [self.delegate didReceiveBloodPressureData:stringFromData];
//        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
//        [self.centralManager cancelPeripheralConnection:peripheral];
//        connectedPeripheral = nil;
//        [peripherals removeAllObjects];
//    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY_UUID]]) {
        return;
    }
     
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
        if (state == BleStateNone) {
            [self writeData:BleOrderSetup];
        }
    } else {
        // Notification has stopped
        [self cleanup];
    }
}

@end
