//
//  SeafSyncNetworkerServiceObserverDelegate.h
//  Seafile
//
// Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncEnums.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SeafSyncNetworkerServiceObserverDelegate

/**
 * Notifies the delegate when the network status changes.
 *
 * @param state The new network state.
 */
-(void)onSeafSyncNetworkStatusChange:(SeafSyncNetworkState)state;

@end

NS_ASSUME_NONNULL_END
