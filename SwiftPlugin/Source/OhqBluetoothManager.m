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
#define TOTAL_STEP 5

#import "OhqBluetoothManager.h"
#import <Foundation/Foundation.h>
#import "Model/Enum.h"
#import "Model/BloodPressureData.h"
#import "NSString+IntFromHexString.h"
#import "BleUnitySender.h"

@interface OhqBluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    NSMutableArray * peripherals;
    NSArray<CBPeripheral *> *connectedDevices;
    NSTimer * timer;
    int countTime;
    BleState processingState;
    BloodPressureData * bloodData;
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
        processingState = BleStateNone;
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
    connectedPeripheral = nil;
    [peripherals removeAllObjects];
    processingState = BleStateNone;
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
        [self.delegate didScanTimeOut];
        [BleUnitySender didScanTimeOut];
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

- (NSString *) retrieveConnectedPeripherals {
    CBUUID *uuid = [CBUUID UUIDWithString:SERVICE_UUID];
    connectedDevices = [self.centralManager retrieveConnectedPeripheralsWithServices:@[uuid]];
    NSMutableArray *arrayObject = [[NSMutableArray alloc] init];
    [connectedDevices enumerateObjectsUsingBlock:^(CBPeripheral * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DeviceData * device = [[DeviceData alloc] initWith:obj.name uuid:obj.identifier.UUIDString];
        [arrayObject addObject:device.toNSDictionary];
        }];
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrayObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return error ? nil : jsonString;
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

- (void)startMeasureBloodPressure {
    bloodData = nil;
    if (processingState == BleStateNone || processingState == BleStateOff) {
        [self writeData:BleOrderSetup];
    } else if(processingState == BleStateWait) {
        [self writeData:BleOrderMeasureBloodPressure];
    }
}

- (void)disconnectDevice
{
    if (!(self.centralManager == nil || connectedPeripheral == nil)) {
        [self cleanup];
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
    if ([response containsString:@"WUP"]) {
        return BleResponseChangeNormalMode;
    } else if ([response containsString:@"OFF"]) {
        return BleResponsePowerOff;
    } else if ([response containsString:@"WAI"]) {
        return BleResponseStandBy;
    } else if ([response containsString:@"COM"]) {
        return BleResponseReadyForMeasure;
    } else if ([response containsString:@"ERR"]) {
        return BleResponseError;
    } else if ([response containsString:@"EXH"]) {
        return BleResponseMeasureEnd;
    } else if ([response hasPrefix:@"rx"] || [response hasPrefix:@"x"]) {
        return BleResponseBloodPressureResult1;
    } else if ([response containsString:@"ra"]) {
        return BleResponseBloodPressureResult2;
    }
    return  BleResponseUnknown;
}

- (void)writeData:(BleOrder)order
{
    NSString *orderString = [self bleOrderToString:order];
    NSData *data = [orderString  dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", [NSString stringWithFormat:@"writeData %@", orderString]);
    [self.connectedPeripheral writeValue:data forCharacteristic:self.transferCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void) handleDataResponse:(NSString *) responseString
{
    NSLog(@"%@", [NSString stringWithFormat:@"handleDataResponse %@", responseString]);
    BleResponse response = [self bleResponseStringToEnum: responseString];
    switch (response) {
        case BleResponseChangeNormalMode:
            processingState = BleStateNormal;
            [self writeData:BleOrderSetup];
            [self.delegate didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",1,TOTAL_STEP]];
            [BleUnitySender didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",1,TOTAL_STEP]];
            break;
        case BleResponsePowerOff:
            processingState = BleStateOff;
            [self.delegate deviceDidChangeStatePowerOff];
            [BleUnitySender deviceDidChangeStatePowerOff];
            break;
        case BleResponseStandBy:
            processingState = BleStateWait;
            [self writeData:BleOrderSetup];
            break;
        case BleResponseReadyForMeasure:
            if (processingState == BleStateWait)
            {
                [self writeData:BleOrderPowerOff];
            } else {
                [self.delegate didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",2,TOTAL_STEP]];
                [BleUnitySender didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",2,TOTAL_STEP]];
                [self writeData:BleOrderMeasureBloodPressure];
            }
            processingState = BleStateReady;
            break;
        case BleResponseError:
            processingState = BleStateError;
            [self writeData:BleOrderPowerOff];
            [self cleanup];
            break;
        case BleResponseBloodPressureResult1:
            [self.delegate didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",4,TOTAL_STEP]];
            [BleUnitySender didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",4,TOTAL_STEP]];
            [self parseBloodDataWith:responseString];
            break;
        case BleResponseBloodPressureResult2:
            [self.delegate didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",5,TOTAL_STEP]];
            [BleUnitySender didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",5,TOTAL_STEP]];
            [self parseBloodDataWith:responseString];
            break;
        case BleResponseMeasureEnd:
            [self.delegate didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",3,TOTAL_STEP]];
            [BleUnitySender didUpdateMeasureStep:[NSString stringWithFormat:@"%d/%d",3,TOTAL_STEP]];
            break;
        case BleResponseUnknown:
            break;
    }
}

- (void) parseBloodDataWith:(NSString *) result
{
    if (bloodData == nil) {
        bloodData = [[BloodPressureData alloc] init];
    }
    bool isFirstResult = [result hasPrefix:@"rx"] || [result hasPrefix:@"x"];
    if (isFirstResult) {
        NSString * stringResult = [[result componentsSeparatedByString:@"x"] lastObject];
        bloodData.errorCode = [stringResult hexStringToIntWith:NSMakeRange(0, 2)];
        bloodData.systolic = [stringResult hexStringToIntWith:NSMakeRange(2, 4)] / 128;
        bloodData.diastolic = [stringResult hexStringToIntWith:NSMakeRange(6, 4)] / 128;
        bloodData.pulseRate = [stringResult hexStringToIntWith:NSMakeRange(10, 2)];
    } else if ([result containsString:@"ra"]) {
        NSString * stringResult = [[result componentsSeparatedByString:@"ra"] lastObject];
        bloodData.bodyMovementDetected = [stringResult stringToIntWith:NSMakeRange(4, 2)] == 1;
        bloodData.bodyMovementCount = [stringResult stringToIntWith:NSMakeRange(0, 2)];
        bloodData.irregularPulseDetected = [stringResult stringToIntWith:NSMakeRange(6, 2)] == 1;
        bloodData.irregularPulseRate = [stringResult stringToIntWith:NSMakeRange(2, 2)];
        bloodData.isCuffFitting = [stringResult stringToIntWith:NSMakeRange(8, 2)] == 1;
        [self.delegate didReceiveBloodPressureData:[NSString stringWithFormat:@"%@", [bloodData toNSDictionary]]];
        
        // Send data to Unity
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:bloodData.toNSDictionary options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        if (err == nil) {
            [BleUnitySender didReceiveBloodPressureData:[NSString stringWithFormat:@"%@", myString]];
        } else {
            NSLog(@"%@", err.localizedDescription);
        }
    } else {
        NSLog(@"Unsupport blood result format");
    }
}

#pragma mark - CBCentralManager delegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBManagerStatePoweredOn) {
        [self.delegate didBleManagerChangeStateWith:BleManagerStatePoweredOn];
        [BleUnitySender didBleManagerChangeStateWith:[NSString stringWithFormat:@"%li", BleManagerStatePoweredOn]];
    } else {
        [self.delegate didBleManagerChangeStateWith:BleManagerStatePoweredOff];
        [BleUnitySender didBleManagerChangeStateWith:[NSString stringWithFormat:@"%li", BleManagerStatePoweredOff]];
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
        
        // Notify to Unity
        DeviceData * device = [[DeviceData alloc] initWith:peripheral.name uuid:peripheral.identifier.UUIDString];
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:device.toNSDictionary options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
        if (err == nil) {
            [BleUnitySender didDiscoverZealLe0:myString];
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"Object to json string error: %@", err.localizedDescription]);
        }
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"--- didConnectPeripheral");
    [self stopScan];

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
    [BleUnitySender didConnectPeripheralWith:[NSString stringWithFormat:@"%li", BleConnectDeviceResponseFailed]];
}

#pragma mark - CBPeripheralDelegate delegate methods

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    NSLog(@"--- didDiscoverServices");
    if (error) {
        [self cleanup];
        [self.delegate didConnectPeripheralWith:BleConnectDeviceResponseFailed];
        [BleUnitySender didConnectPeripheralWith:[NSString stringWithFormat:@"%li", BleConnectDeviceResponseFailed]];
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
        [BleUnitySender didConnectPeripheralWith:[NSString stringWithFormat:@"%li", BleConnectDeviceResponseFailed]];
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
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (error) {
        [self cleanup];
        return;
    }
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    NSString *trimmedString = [stringFromData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self handleDataResponse: trimmedString];
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
        [self.delegate didConnectPeripheralWith:BleConnectDeviceResponseSuccess];
        [BleUnitySender didConnectPeripheralWith:[NSString stringWithFormat:@"%li", BleConnectDeviceResponseSuccess]];
    } else {
        // Notification has stopped
        [self cleanup];
    }
}

@end
