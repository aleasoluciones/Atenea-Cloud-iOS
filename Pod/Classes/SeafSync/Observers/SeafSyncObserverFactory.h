//
//  SeafSyncObserverFactory.h
//  Seafile
//
// Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncObserverProtocol.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncObserverFactory : NSObject

/**
 * Create a synchronization observer based on the synchronization settings.
 *
 * @param setting The synchronization settings.
 * @return A synchronization observer conforming to the SeafSyncObserverProtocol.
 */
+(id<SeafSyncObserverProtocol>)createFor:(SeafSyncSettings *)setting;

@end

NS_ASSUME_NONNULL_END
