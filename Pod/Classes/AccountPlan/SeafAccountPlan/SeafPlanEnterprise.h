//
//  SeafPlanEnterprise.h
//  Seafile
//
//  Created by apps meytel on 23/10/23.
//

#import "SeafPlanStandard.h"

/**
 * @class SeafPlanEnterprise
 * @brief Class representing an enterprise plan, which inherits from SeafPlanStandard.
 */
@interface SeafPlanEnterprise : SeafPlanStandard



/**
 * @brief Initializes an instance of SeafPlanEnterprise.
 *
 * This method sets the uploadSpeed to an initial value.
 *
 * @return An initialized instance of SeafPlanEnterprise.
 */
- (instancetype)init;

@end
