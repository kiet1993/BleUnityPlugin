//
//  SwiftPluginBirdge.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/12/21.
//

#import <Foundation/Foundation.h>
#import "OhqBluetoothManager.h"

// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
    if (string)
        return [NSString stringWithUTF8String: string];
    else
        return [NSString stringWithUTF8String: ""];
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

extern "C" {

    void _InitBleManager()
    {
        [[OhqBluetoothManager sharedInstance] initBleManager];
    }

    void _StartScan()
    {
        [[OhqBluetoothManager sharedInstance] startScan];
    }

    void _StopScan()
    {
        [[OhqBluetoothManager sharedInstance] stopScan];
    }

    const char* _RetrieveConnectedDevices()
    {
        return MakeStringCopy([[[OhqBluetoothManager sharedInstance] retrieveConnectedPeripherals] UTF8String]);
    }

    void _ConnectToScanDeviceWith(const char* identifier)
    {
        [[OhqBluetoothManager sharedInstance] connectToScanDeviceWith:CreateNSString(identifier)];
    }

    void _StartMeasureBloodPressure()
    {
        [[OhqBluetoothManager sharedInstance] startMeasureBloodPressure];
    }

    void _DisconnectDevice()
    {
        [[OhqBluetoothManager sharedInstance] disconnectDevice];
    }
}
