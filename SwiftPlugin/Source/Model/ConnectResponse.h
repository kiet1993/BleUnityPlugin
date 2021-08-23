//
//  ConnectResponse.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum BleManagerState : NSUInteger {
    BleManagerStatePoweredOn,
    BleManagerStatePoweredOff
} BleManagerState;

typedef enum BleConnectDeviceResponse : NSUInteger {
    BleConnectDeviceResponseSuccess,
    BleConnectDeviceResponseFailed
} BleConnectDeviceResponse;

NS_ASSUME_NONNULL_END
