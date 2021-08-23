//
//  ViewController.m
//  BleSampleApp
//
//  Created by Macintosh on 8/13/21.
//

#import "ViewController.h"
#import <SwiftPlugin/SwiftPlugin.h>

@interface ViewController () <OhqBluetoothManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray * deviceList;
}
@property (weak, nonatomic) IBOutlet UILabel *labelResult;
@property (weak, nonatomic) IBOutlet UILabel *labelDiscoverDevice;
@property (weak, nonatomic) IBOutlet UITableView *tableviewDevices;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    deviceList = [[NSMutableArray alloc] init];
    bleManager = [OhqBluetoothManager sharedInstance];
    bleManager.delegate = self;
    self.tableviewDevices.dataSource = self;
    self.tableviewDevices.delegate = self;
}

- (IBAction)btnStartScanTapped:(id)sender {
    [bleManager startScan];
}

- (IBAction)btnStopScanTapped:(id)sender {
    [bleManager stopScan];
}

#pragma mark - UITableViewDataSource delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SimpleTableId";
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    CBPeripheral * model = deviceList[indexPath.row];
    NSString *stringForCell = [NSString stringWithFormat:@"%@ \n %@", model.name, model.identifier];
    [cell.textLabel setText:stringForCell];
    return cell;
}

#pragma mark - UITableViewDelegate delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral * model = deviceList[indexPath.row];
    [bleManager connectToDeviceWith:model.identifier.UUIDString];
}
#pragma mark - OhqBluetoothManagerDelegate delegate methods

- (void)didConnectToDeviceWith:(BleConnectResponse)result {
    switch (result) {
        case BleConnectResponseSuccess:
            self.labelResult.text = @"Connect device success";
            break;
        case BleConnectResponseFailed:
            self.labelResult.text = @"Connect device failed";
            break;
    }
}

- (void)didDiscoverZealLe0:(nonnull CBPeripheral *)device {
    [deviceList addObject:device];
    [self.tableviewDevices reloadData];
}

- (void)didReceiveBloodPressureData:(nonnull NSString *)data {
    NSString *textResult = [NSString stringWithFormat:@"Blood Pressure data:\n%@", data];
    self.labelResult.text = textResult;
}

- (void)didDiscoverBleDevice:(CBPeripheral *)device
{
    if (device.name != nil) {
        self.labelDiscoverDevice.text = [NSString stringWithFormat:@"Device: %@", device.name];
    }
}

@end
