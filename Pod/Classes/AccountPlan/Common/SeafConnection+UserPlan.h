//
//  SeafConnection+UserPlan.h
//  Seafile
//
//  Created by apps meytel on 10/10/23.
//
#define SeafConnection_UserPlan_h
#import "SeafConnection.h"
#import "SeafPlanUser.h"


/**
 * @file SeafConnection_UserPlan.h
 * @brief This header file declares an extension to the SeafConnection class for determining the user's plan type.
 */
@interface SeafConnection (Extension)

/**
 * @brief Determine the user's plan type based on their quota and update the PlanType property accordingly.
 *
 * This method calculates the user's plan type based on their storage quota and updates the PlanType property of the SeafConnection instance.
 */

- (SeafPlanUser*)getPlan;


@end
