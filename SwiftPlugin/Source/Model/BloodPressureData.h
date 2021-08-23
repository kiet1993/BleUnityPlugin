//
//  BloodPressureData.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BloodPressureData : NSObject
@property (nonatomic, assign) int systolic;
@property (nonatomic, assign) int diastolic;
@property (nonatomic, assign) int pulseRate;
@property (nonatomic, assign) BOOL bodyMovementDetected;
@property (nonatomic, assign) int bodyMovementCount;
@property (nonatomic, assign) BOOL irregularPulseDetected;
@property (nonatomic, assign) int irregularPulseRate;
@property (nonatomic, assign) BOOL isCuffFitting;

@property (nonatomic, assign) int errorCode;

- (void)errorSetup:(int)errorCode_;
- (NSDictionary*)toNSDictionary;

+ (int)successCode;
+ (int)timeOutCode;

@end

NS_ASSUME_NONNULL_END
