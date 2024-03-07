//
//  AlreadyUploadedFilterStrategy.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 13/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncFileProviderFilterStrategy.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlreadyUploadedFilterStrategy :  NSObject<SeafSyncFileProviderFilterStrategy>

/**
 * @brief Initializes a new instance of the filter strategy with the specified synchronization settings.
 *
 * @param settings The synchronization settings to be used by the filter strategy.
 * @return An initialized instance of the filter strategy.
 */
- (id)initWithSettings:(SeafSyncSettings *)settings;

@end

NS_ASSUME_NONNULL_END
