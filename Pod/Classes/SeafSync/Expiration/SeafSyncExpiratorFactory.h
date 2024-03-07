/**
 * @file SeafSyncExpiratorFactory.h
 * @brief Declaration of SeafSyncExpiratorFactory class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncExpiratorProtocol.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class SeafSyncExpiratorFactory
 * @brief Factory for creating synchronization expirators.
 *
 * The SeafSyncExpiratorFactory class is responsible for creating instances of classes conforming
 * to the SeafSyncExpiratorProtocol. It provides a method to get the appropriate expirator based on
 * the provided synchronization settings.
 */
@interface SeafSyncExpiratorFactory : NSObject

/**
 * @brief Gets the expirator for the given synchronization settings.
 * @param setting The synchronization settings for which to obtain the expirator.
 * @return An object conforming to the SeafSyncExpiratorProtocol.
 */
- (id<SeafSyncExpiratorProtocol>)getExpiratorFor:(SeafSyncSettings *)setting;

@end

NS_ASSUME_NONNULL_END
