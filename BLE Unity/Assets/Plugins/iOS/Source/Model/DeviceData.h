//
//  DeviceData.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceData : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;

- (id)initWith:(NSString *)name uuid:(NSString *)uuid;
- (NSDictionary*)toNSDictionary;
@end

NS_ASSUME_NONNULL_END
