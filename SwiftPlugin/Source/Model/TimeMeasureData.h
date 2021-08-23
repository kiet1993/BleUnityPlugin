//
//  TimeMeasureData.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeMeasureData : NSObject
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int hourMor;
@property (nonatomic, assign) int minuteMor;
@property (nonatomic, assign) int hourAf;
@property (nonatomic, assign) int minuteAf;

@property (nonatomic, assign) int checksum;

@property (nonatomic, assign) int errorCode;

- (void)errorSetup:(int)errorCode_;
- (NSDictionary*)toNSDictionary;

+ (int)successCode;
+ (int)errorDisconneced;
+ (int)timeOutCode;
+ (int)errorCode;

@end

NS_ASSUME_NONNULL_END
