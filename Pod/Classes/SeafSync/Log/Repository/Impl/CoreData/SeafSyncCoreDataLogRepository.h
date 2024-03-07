/**
 * @file SeafSyncCoreDataLogRepository.h
 * @author: Javier Godoy (javigodoy@meytel.net)
 *
 * @brief Header file for the SeafSyncCoreDataLogRepository class.
 *
 * This file declares the SeafSyncCoreDataLogRepository class, which implements the SeafSyncLogRepository protocol for managing synchronization log entries using CoreData.
 *
 */

#import <Foundation/Foundation.h>
#import "SeafSyncLogRepository.h"
#import "CoreData/CoreData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncCoreDataLogRepository
 * @brief The SeafSyncCoreDataLogRepository class implements the SeafSyncLogRepository protocol for managing synchronization log entries using CoreData.
 */
@interface SeafSyncCoreDataLogRepository : NSObject<SeafSyncLogRepository>

@end

NS_ASSUME_NONNULL_END
