//
//  ConnectResponse.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum BleManagerState : NSUInteger {
    BleManagerStatePoweredOn = 0,
    BleManagerStatePoweredOff = 1
} BleManagerState;

typedef enum BleConnectDeviceResponse : NSUInteger {
    BleConnectDeviceResponseSuccess = 0,
    BleConnectDeviceResponseFailed = 1
} BleConnectDeviceResponse;

NS_ASSUME_NONNULL_END
