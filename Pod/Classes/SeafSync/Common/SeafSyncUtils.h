//
//  SeafSyncUtils.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 24/9/23.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncUtils
 * @brief A utility class for various synchronization-related functions.
 */
@interface SeafSyncUtils : NSObject

/**
 * Creates an NSURL from the provided bookmark data.
 *
 * @param bookmark The NSData representing the bookmark data.
 * @return An NSURL created from the bookmark data.
 */
+ (NSURL*)urlFromBookmark:(NSData*)bookmark;

/**
 * Calculates the hash value for the input string using the MD5 algorithm.
 *
 * @param inputString The input string for which the hash needs to be calculated.
 * @return The calculated hash value as an NSString.
 */
+(NSString *)calculateHash:(NSString *)inputString;

/**
 * Checks if the provided date is older than another date.
 *
 * @param date The date to be checked.
 * @param dateToCompare The date to compare against.
 * @return YES if the provided date is older; otherwise, NO.
 */
+(BOOL) date:(NSDate *) date isOlderThan:(NSDate *) dateToCompare;

/**
 * Checks if the provided date is earlier than another date.
 *
 * @param date The date to be checked.
 * @param dateToCompare The date to compare against.
 * @return YES if the provided date is earlier; otherwise, NO.
 */
+(BOOL) date:(NSDate *) date isPreviousThan:(NSDate *) dateToCompare;


/**
 Gets the relative path from the provided URL.

 This method takes a URL as input and returns the relative path component of that URL.

 @param url The NSURL for which to determine the relative path.
 @return A string representing the relative path of the provided URL.


 @note The returned string may be empty if the URL does not have a relative path.
 */
+ (NSString *)getRelativePath:(NSURL *)url;


@end

NS_ASSUME_NONNULL_END
