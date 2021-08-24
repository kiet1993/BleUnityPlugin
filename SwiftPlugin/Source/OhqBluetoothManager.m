//
//  OhqBluetoothManager.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/12/21.
//

#define SERVICE_UUID @"27ADC9CA-35EB-465A-9154-B8FF9076F3E8"
#define CHARACTERISTIC_NOTIFY_UUID @"27ADC9CB-35EB-465A-9154-B8FF9076F3E8"
#define CHARACTERISTIC_WRITE_UUID @"27ADC9CC-35EB-465A-9154-B8FF9076F3E8"

#import "OhqBluetoothManager.h"

@interface OhqBluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    NSMutableArray * peripherals;
    NSArray<CBPeripheral *> *connectedDevices;
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBPeripheral *selectedPeripheral;

@end


@implementation OhqBluetoothManager

@synthesize selectedPeripheral;

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
    }
    return self;
}

- (void)cleanup {
    // See if we are subscribed to a characteristic on the peripheral
    if (selectedPeripheral.services != nil) {
        for (CBService *service in selectedPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY_UUID]]) {
                        if (characteristic.isNotifying) {
                            [selectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
 
    [self.centralManager cancelPeripheralConnection:selectedPeripheral];
}

- (void)initBleManager
{
    if (self.centralManager == nil) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
}

- (void)startScan
{
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        CBUUID *uuid = [CBUUID UUIDWithString:SERVICE_UUID];
        [self.centralManager scanForPeripheralsWithServices:@[uuid] options:nil];
        NSLog(@"Scanning started");
    } else {
        NSLog(@"self.centralManager.state not PoweredOn");
    }
}

- (void)stopScan
{
    if (self.centralManager) {
        [self.centralManager stopScan];
    }
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
            selectedPeripheral = item;
            break;
        }
    }
}

- (void)connectToScanDeviceWith:(NSString *)identifier
{
    for (CBPeripheral* item in peripherals) {
        NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:identifier];
        if (item.identifier == uuid) {
            [self.centralManager connectPeripheral:item options:nil];
            selectedPeripheral = item;
            break;
        }
    }
}

- (void)sendMeasureCommandToDevice {

    if (selectedPeripheral != nil) {
        
//        NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding];
//        [self.ourPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)disconnectDevice
{
    if (!(self.centralManager == nil || selectedPeripheral == nil)) {
        [self.centralManager cancelPeripheralConnection: selectedPeripheral];
        selectedPeripheral = nil;
        [peripherals removeAllObjects];
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
    NSLog(@"---didDiscoverPeripheral with name: %@", peripheral.name);
    [self.delegate didDiscoverBleDevice:peripheral];
    NSLog(@"--didDiscoverPeripheral ZEAL-LE0");
    [peripherals addObject:peripheral];
    [self.delegate didDiscoverZealLe0:peripheral];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"--- didConnectPeripheral");
    [self.centralManager stopScan];
    [self.delegate didConnectPeripheralWith:BleConnectDeviceResponseSuccess];
    NSLog(@"Scanning stopped");

    NSLog(@"peripheral in didConnect function: %@", peripheral);
    NSLog(@"any services??: %@", peripheral.services);
    peripheral.delegate = self;
    CBUUID *uuid = [CBUUID UUIDWithString:SERVICE_UUID];
    [peripheral discoverServices:@[uuid]];
}


- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral
                 error:(nullable NSError *)error
{
    NSLog(@"--- did disconnect ConnectPeripheral");
    self.selectedPeripheral = nil;
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
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_NOTIFY_UUID]] forService:service];
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
         
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        [self.delegate didReceiveBloodPressureData:stringFromData];
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        [self.centralManager cancelPeripheralConnection:peripheral];
        selectedPeripheral = nil;
        [peripherals removeAllObjects];
    }
}

@end
