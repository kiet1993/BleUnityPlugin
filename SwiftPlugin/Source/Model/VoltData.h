//
//  VoltData.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoltData : NSObject
@property (nonatomic, assign) int count;
@property (nonatomic, assign) int ad;
@property (nonatomic, assign) int dec;
@property (nonatomic, assign) int errorCode;

- (void)errorSetup:(int)errorCode_;
- (NSDictionary*)toNSDictionary;

+ (int)successCode;
+ (int)errorDisconneced;
+ (int)timeOutCode;

@end

NS_ASSUME_NONNULL_END
