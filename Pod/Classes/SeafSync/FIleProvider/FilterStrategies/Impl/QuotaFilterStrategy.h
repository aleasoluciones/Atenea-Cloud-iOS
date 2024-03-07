//
//  QuotaFilterStrategy.h
//  Seafile
//
//  Created by apps Javier Godoy (javigodoy@meytel.net) on 10/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncFileProviderFilterStrategy.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Represents a filter strategy based on quota for Seafile synchronization.
 */
@interface QuotaFilterStrategy : NSObject<SeafSyncFileProviderFilterStrategy>

/**
 * @brief Initializes a new instance of the filter strategy with the specified synchronization settings.
 *
 * @param settings The synchronization settings to be used by the filter strategy.
 * @return An initialized instance of the filter strategy.
 */
-(id)initWithSettings:(SeafSyncSettings *)settings;

@end

NS_ASSUME_NONNULL_END
