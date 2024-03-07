//
//  SeafSyncFilteredProvider.h
//  Seafile
//
//  Created by apps Javier Godoy (javigodoy@meytel.net) on 10/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncProviderProtocol.h"
#import "SeafSyncFileProviderFilterStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Represents a filtered synchronization provider for Seafile.
 */
@interface SeafSyncFilteredProvider : NSObject<SeafSyncProviderProtocol>

/**
 * @brief Initializes a new instance of the filtered synchronization provider with the specified base provider and filters.
 *
 * @param provider The base provider to retrieve files from.
 * @param filters An optional array of filter strategies to apply to the files retrieved from the base provider.
 * @return An initialized instance of the filtered synchronization provider.
 */
-(id)initWithProvider:(id<SeafSyncProviderProtocol>)provider andFilters:(nullable NSArray<id<SeafSyncFileProviderFilterStrategy>> *)filters;

@end

NS_ASSUME_NONNULL_END
