#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BleUnitySender.h"
#import "BloodPressureData.h"
#import "ConnectResponse.h"
#import "DeviceData.h"
#import "Enum.h"
#import "NSString+IntFromHexString.h"
#import "OhqBluetoothManager.h"
#import "SwiftPlugin.h"

FOUNDATION_EXPORT double SwiftPluginVersionNumber;
FOUNDATION_EXPORT const unsigned char SwiftPluginVersionString[];

