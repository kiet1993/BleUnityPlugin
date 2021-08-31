//
//  SwiftPluginBirdge.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/12/21.
//

#import <Foundation/Foundation.h>
#import "NetServiceBrowserDelegate.h"
#import "OhqBluetoothManager.h"

static NetServiceBrowserDelegate* delegateObject = nil;
static NSNetServiceBrowser *serviceBrowser = nil;
static OhqBluetoothManager *bleManager = nil;

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
        bleManager = [OhqBluetoothManager sharedInstance];
    }

    void _StartScan()
    {
        [bleManager startScan];
    }

    void _StopScan()
    {
        [bleManager stopScan];
    }

    const char* retrieveConnectedDevices()
    {
        return MakeStringCopy([[bleManager retrieveConnectedPeripherals] UTF8String]);
    }

    void _ConnectToScanDeviceWith(const char* identifier)
    {
        [bleManager connectToScanDeviceWith:CreateNSString(identifier)];
    }

    void _StartMeasureBloodPressure()
    {
        [bleManager startMeasureBloodPressure];
    }

    void _DisconnectDevice()
    {
        [bleManager disconnectDevice];
    }
}
