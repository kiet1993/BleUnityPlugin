//
//  Enum.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/26/21.
//

#import <Foundation/Foundation.h>

typedef enum BleOrder {
    BleOrderSetup,
    BleOrderMeasureBloodPressure,
    BleOrderPowerOff
    
} BleOrder;

typedef enum BleResponse {
    BleResponseUnknown,
    BleResponseChangeNormalMode, //@"WUP"
    BleResponsePowerOff, //@"OFF"
    BleResponseStandBy, //@"WAI"
    BleResponseReadyForMeasure, //@"COM"
    BleResponseError,//@"ERR"
    BleResponseBloodPressureResult1,//@"rx"
    BleResponseBloodPressureResult2 //@"ra"
} BleResponse;

typedef enum BleState {
    BleStateNone,
    BleStateNormal,
    BleStateReady,
    BleStateBlood,
    BleStateWait,
    BleStateOff,
    BleStateError
} BleState;
