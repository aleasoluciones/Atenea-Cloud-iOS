//
//  SeafSyncAssetItem.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Represents an asset item for Seafile synchronization.
 */
@interface SeafSyncAssetItem : NSObject<SeafSyncItemProtocol>

/**
 * @brief Initializes a new instance of the asset item with the specified Photo Library asset.
 *
 * @param asset The Photo Library asset to be represented by the item.
 * @return An initialized instance of the asset item.
 */
-(id)initWithPHAsset:(PHAsset *)asset;

/**
 * @brief Retrieves the Photo Library asset represented by the item.
 *
 * @return The Photo Library asset represented by the item.
 */
-(PHAsset *)getAsset;


@end

NS_ASSUME_NONNULL_END

