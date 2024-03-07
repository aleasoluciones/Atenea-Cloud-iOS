//
//  SeafSyncFileProviderFactory.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 1/9/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncProviderProtocol.h"
#import "SeafSyncSettings.h"
#import "SeafSyncFileProviderFilterStrategy.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncFileProviderFactory
 * @brief A factory class for creating SeafSyncProviderProtocol instances.
 */
@interface SeafSyncFileProviderFactory : NSObject

/**
 * Creates an instance of SeafSyncProviderProtocol based on the provided SeafSyncSettings.
 *
 * @param settings The SeafSyncSettings object containing synchronization settings.
 * @return An instance of SeafSyncProviderProtocol.
 */
+ (id<SeafSyncProviderProtocol>)getProviderFor:(SeafSyncSettings * ) settings;

/**
 * Creates an instance of SeafSyncProviderProtocol for a specific folder URL and settings.
 *
 * @param folderURL The NSURL representing the folder's URL.
 * @param settings The SeafSyncSettings object containing synchronization settings.
 * @return An instance of SeafSyncProviderProtocol.
 */
+ (id<SeafSyncProviderProtocol>)getProviderForURL:(NSURL * ) folderURL withSettings:(SeafSyncSettings * ) settings;


/**
 * Returns an array of default file provider filter strategies based on the provided sync settings.
 *
 * @param settings The synchronization settings used to determine the default filters.
 * @return An array of objects conforming to the SeafSyncFileProviderFilterStrategy protocol.
 */
+ (NSArray<id<SeafSyncFileProviderFilterStrategy>> *)getDefaultFiltersWith:(SeafSyncSettings *)settings;

@end

NS_ASSUME_NONNULL_END

