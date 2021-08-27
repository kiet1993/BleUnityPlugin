//
//  NSString+IntFromHexString.m
//  SwiftPlugin
//
//  Created by Macintosh on 8/27/21.
//

#import "NSString+IntFromHexString.h"

@implementation NSString (IntFromHexString)
- (int)hexStringToIntWith:(NSRange)range
{
    NSString * stringResult = [self substringWithRange:range];
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:stringResult];
    [scanner scanHexInt:&result];
    return result;
}

- (int)stringToIntWith:(NSRange)range
{
    NSString * stringResult = [self substringWithRange:range];
    return [stringResult intValue];
}
@end
