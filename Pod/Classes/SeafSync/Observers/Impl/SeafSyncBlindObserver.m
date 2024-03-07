//
//  SeafSyncBlindObserver.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import "SeafSyncBlindObserver.h"

/**
 * @brief The SeafSyncBlindObserver class.
 *
 * This observer does not perform any observation. Used when no observer is founded in factory
 */
@implementation SeafSyncBlindObserver

/**
 * @brief Returns the identifier for the observer.
 *
 * @return The identifier for the observer.
 */
- (id)observerIdentifier {
    return @"blind_observer";
}

/**
 * @brief Starts the synchronization observer.
 *
 * @param callback The callback block to be executed when synchronization events occur.
 */
- (void)start:(nullable SeafSyncObserverProtocolCallback)callback {
    
}

/**
 * @brief Stops the synchronization observer.
 */
- (void)stop {

}

@end
