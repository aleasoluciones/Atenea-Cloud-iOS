/**
 * @file SeafSyncExpiratorProtocol.h
 * @brief Header file for the SeafSyncExpiratorProtocol protocol.
 *
 * Created by Javier Godoy (javigodoy@meytel.net).
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @protocol SeafSyncExpiratorProtocol
 * @brief A protocol for handling synchronization expiration.
 *
 * The SeafSyncExpiratorProtocol protocol defines the methods required for handling
 * synchronization expiration. Classes conforming to this protocol are responsible
 * for implementing the logic to expire synchronization data.
 */
@protocol SeafSyncExpiratorProtocol

/**
 * @brief Initiates the process of handling synchronization expiration.
 */
- (void)run;

@end

NS_ASSUME_NONNULL_END


