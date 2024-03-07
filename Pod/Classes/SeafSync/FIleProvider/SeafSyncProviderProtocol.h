//
//  SeafSyncProviderProtocol.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 1/9/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @protocol SeafSyncProviderProtocol
 * @brief A protocol for providing synchronization items.
 */
@protocol SeafSyncProviderProtocol 

/**
 * Gets the list of synchronization items.
 * @param onError An optional error pointer.
 * @return An array of objects conforming to the SeafSyncItemProtocol representing the synchronization items.
 */
- (NSMutableArray<id<SeafSyncItemProtocol>> *)getFiles:(NSError **)onError;

@end

NS_ASSUME_NONNULL_END

