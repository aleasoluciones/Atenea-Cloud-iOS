//
//  SeafSyncSettingFolderObserver.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 27/9/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncFolderObserver.h"
#import "SeafSyncSettings.h"
#import "SeafSyncObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Folder observer for synchronization settings.
 *
 * The class `SeafSyncSettingFolderObserver` inherits from `SeafSyncFolderObserver` and implements the `SeafSyncObserverProtocol`.
 * This class is used to observe changes in folders related to synchronization settings.
 */
@interface SeafSyncSettingFolderObserver : SeafSyncFolderObserver<SeafSyncObserverProtocol>

/**
 * @brief Initializes a new instance of `SeafSyncSettingFolderObserver`.
 *
 * @param setting The synchronization settings associated with the observer.
 * @return An instance of `SeafSyncSettingFolderObserver`.
 */
-(id) initWith:(SeafSyncSettings *) setting;

@end

NS_ASSUME_NONNULL_END
