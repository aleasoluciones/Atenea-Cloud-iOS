//
//  SeafSyncNetworkerService.h
//  Seafile
//
// Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncNetworkerServiceObserverDelegate.h"
#import "SeafSyncEnums.h"
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The SeafSyncNetworkerService class provides network-related functionality for synchronization.
 */
@interface SeafSyncNetworkerService : NSObject

/**
 Returns a shared instance of SeafSyncNetworkerService for the specified SeafConnection.
 @param connection The SeafConnection for which the networker service is associated.
 @return An instance of SeafSyncNetworkerService.
 */
+ (instancetype)sharedInstanceFor:(SeafConnection *)connection;

/**
 Checks if there is an active network connection.
 @return YES if a connection is available, NO otherwise.
 */
- (BOOL)hasConnection;

/**
 Checks if a Wi-Fi connection is available.
 @return YES if a Wi-Fi connection is available, NO otherwise.
 */
- (BOOL)wifiConnectionAvailable;

/**
 Returns the current network state.
 @return The current network state as a SeafSyncNetworkState enum.
 */
- (SeafSyncNetworkState)networkState;

/**
 Subscribes an observer to receive network-related notifications.
 @param observer The observer conforming to the SeafSyncNetworkerServiceObserverDelegate protocol.
 */
- (void)subscribe:(id<SeafSyncNetworkerServiceObserverDelegate>)observer;

/**
 Unsubscribes an observer from receiving network-related notifications.
 @param observer The observer to be unsubscribed.
 */
- (void)unSubscribe:(id<SeafSyncNetworkerServiceObserverDelegate>)observer;

@end

NS_ASSUME_NONNULL_END
