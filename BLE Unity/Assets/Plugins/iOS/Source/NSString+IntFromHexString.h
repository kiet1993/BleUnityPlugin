//
//  NSString+IntFromHexString.h
//  SwiftPlugin
//
//  Created by Macintosh on 8/27/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (IntFromHexString)
- (int)hexStringToIntWith:(NSRange)range;
- (int)stringToIntWith:(NSRange)range;
@end

NS_ASSUME_NONNULL_END
