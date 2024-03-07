/**
 * @file SeafSyncCoreDataSettingsRepository.h
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Header file for the SeafSyncCoreDataSettingsRepository class.
 *
 * This file contains the definition of the SeafSyncCoreDataSettingsRepository class, which provides a default implementation of the SeafSyncSettingsRepository protocol.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncSettingsRepository.h"
#import "SeafSyncSettings.h"
#import "CoreData/CoreData.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncCoreDataSettingsRepository : NSObject <SeafSyncSettingsRepository>

@end

NS_ASSUME_NONNULL_END
