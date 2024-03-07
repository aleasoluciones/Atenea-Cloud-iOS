//
//  SeafSyncUtils.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 24/9/23.
//

#import "SeafSyncUtils.h"
#import "AFNetworking.h"
#import "SeafSyncEnums.h"
#import "SeafSyncNetworkerService.h"

@implementation SeafSyncUtils

/**
 Tries to convert NSData to a NSURL bookmark.
 
 @param bookmark The NSData representing the bookmark.
 @return The NSURL obtained from the bookmark data, or nil if conversion fails.
 */
+ (NSURL *)urlFromBookmark:(NSData *)bookmark {
    BOOL bookmarkIsStale = NO;
    NSError *theError = nil;
    NSURL *bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmark
                                                   options:NSURLBookmarkResolutionWithoutUI
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&theError];
    
    if (bookmarkIsStale || (theError != nil)) {
        return nil;
    }
    
    return bookmarkURL;
}

/**
 Calculates the SHA-1 hash from a string.
 
 @param inputString The input string to calculate the hash from.
 @return The SHA-1 hash as a hexadecimal string.
 */
+ (NSString *)calculateHash:(NSString *)inputString {
    NSData *data = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [outputString appendFormat:@"%02x", digest[i]];
    }
    
    return outputString;
}

/**
 Checks if a date is older than another date.
 
 @param date The date to check.
 @param dateToCompare The date to compare against.
 @return YES if the first date is older, NO otherwise.
 */
+ (BOOL)date:(NSDate *)date isOlderThan:(NSDate *)dateToCompare {
    return [date compare:dateToCompare] == NSOrderedDescending;
}

/**
 Checks if a date is earlier than another date.
 
 @param date The date to check.
 @param dateToCompare The date to compare against.
 @return YES if the first date is earlier, NO otherwise.
 */
+ (BOOL)date:(NSDate *)date isPreviousThan:(NSDate *)dateToCompare {
    return [date compare:dateToCompare] == NSOrderedAscending;
}


/**
 Gets the relative path from the provided URL.

 This method takes a URL as input and returns the relative path component of that URL.

 @param url The NSURL for which to determine the relative path.
 @return A string representing the relative path of the provided URL.


 @note The returned string may be empty if the URL does not have a relative path.
 */
+(NSString *) getRelativePath:(NSURL *) url{
    
    NSEnumerator *reverseEnumerator = [[url pathComponents] reverseObjectEnumerator] ;
    
    // Iterar sobre los objetos en orden inverso
    NSString *pathComponent;
    NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:0];
    
    while (pathComponent = [reverseEnumerator nextObject]) {
        if([[pathComponent lowercaseString] isEqualToString:[@"File Provider Storage" lowercaseString]]){
            break;
        }
        [paths addObject:pathComponent];
    }
    
    return [paths componentsJoinedByString:@"/"];
}

@end

