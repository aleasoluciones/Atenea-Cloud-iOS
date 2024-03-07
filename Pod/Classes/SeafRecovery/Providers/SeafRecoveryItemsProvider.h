/**
 *  @file SeafRecoveryItemsProvider.h
 *  @brief Header file for SeafRecoveryItemsProvider class.
 *
 *  Created by Javier Godoy (javigodoy@meytel.net) on 30/10/23.
 */

#import <Foundation/Foundation.h>
#import "SeafConnection.h"
#import "SeafRecoveryItem.h"

NS_ASSUME_NONNULL_BEGIN


/**
 *  @protocol SeafRecoveryItem
 *  Defines a protocol for recovery items.
 */
@protocol SeafRecoveryItemsProvider

- (void)getItems:(void (^ _Nullable)(NSArray<id<SeafRecoveryItem>> *items))callback;

@end

NS_ASSUME_NONNULL_END
