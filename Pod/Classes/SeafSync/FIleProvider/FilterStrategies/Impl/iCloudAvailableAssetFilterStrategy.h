//
//  iCloudAvailableAssetFilterStrategy.h
//  Pods
//
//  Created by apps meytel on 11/4/24.
//

#import <Foundation/Foundation.h>
#import "SeafSyncFileProviderFilterStrategy.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface iCloudAvailableAssetFilterStrategy : NSObject<SeafSyncFileProviderFilterStrategy>

/**
 * @brief Initializes a new instance of the filter strategy with the specified synchronization settings.
 *
 * @param settings The synchronization settings to be used by the filter strategy.
 * @return An initialized instance of the filter strategy.
 */
- (id)initWithSettings:(SeafSyncSettings *)settings;

@end

NS_ASSUME_NONNULL_END
