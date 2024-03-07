//
//  SeafSyncFileProviderFilterStrategy.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Protocol for implementing file provider filter strategies.
 */
@protocol SeafSyncFileProviderFilterStrategy

/**
 * @brief Determines whether the provided item meets the specified condition.
 *
 * @param itemToEvaluate The item to evaluate against the condition.
 * @return YES if the item meets the condition, NO otherwise.
 */
-(BOOL) meetsCondition:(id<SeafSyncItemProtocol>) itemToEvaluate;

@end

NS_ASSUME_NONNULL_END
