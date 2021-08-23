//
//  TimeNowData.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeNowData : NSObject
@property (nonatomic, assign) int year;
@property (nonatomic, assign) int month;
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int second;

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
