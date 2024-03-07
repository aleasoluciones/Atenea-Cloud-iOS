//
//  SeafSyncObserverProtocol.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 27/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A callback block type used by SeafSyncObserverProtocol to notify changes.
 @param object The object representing the changes.
 */
typedef void (^SeafSyncObserverProtocolCallback)(id object);

/**
 The protocol defines methods for an observer that watches for synchronization events.
 */
@protocol SeafSyncObserverProtocol 

/**
 Returns an identifier for the observer.
 @return An identifier string.
 */
- (id)observerIdentifier;

/**
 Starts the observer and registers a callback block to be executed when changes are detected.
 @param callback A callback block to be executed when changes are detected.
 */
- (void)start:(nullable SeafSyncObserverProtocolCallback)callback;

/**
 Stops the observer.
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
