//
//  Enum.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/26/21.
//

#import <Foundation/Foundation.h>

typedef enum BleOrder: NSString {
    BleOrderSetup = @"M6",
    BleOrderMeasureBloodPressure = @"MA",
    BleOrderPowerOff = @"MB"
} BleOrder;

typedef enum BleResponse: NSString {
    BleResponseChangeNormalMode = @"WUP",
    BleResponsePowerOff = @"OFF",
    BleResponseStandBy = @"WAI",
    BleResponseConnect = @"COM",
    BleResponseError = @"ERR",
    BleResponseBloodPressureResult1 = @"rx",
    BleResponseBloodPressureResult2 = @"ra"
} BleResponse;

typedef enum BleState: NSString {
    BleStateNone,
    BleStateStandBy,
    BleStateConnect,
    BleStateBlood,
    BleStateWait,
    BleStateOff,
    BleStateError
} BleState;
