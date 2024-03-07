//
//  SeafConnection+UserPlan.m
//  Seafile
//
//  Created by apps meytel on 10/10/23.


#import "SeafConnection+UserPlan.h"
#import "SeafConnection.h"
#import "SeafAccountPlanEnums.h"

#import "SeafPlanUser.h"
#import "SeafPlanBasic.h"
#import "SeafPlanStandard.h"
#import "SeafPlanEnterprise.h"
#import "SeafPlanPlatinum.h"


/**
*
* This category extends the SeafConnection class to provide a method for determining the user's plan type based on their quota.
*/
@implementation SeafConnection (Extension)

/**
* Determine the user's plan type based on their quota and update the PlanType property accordingly.
*
* This method calculates the user's plan type based on their storage quota and updates the PlanType property of the SeafConnection instance.
*/

- (SeafPlanUser *)getPlan {
   NSInteger myQuota = self.quota;
   switch (myQuota) {
       case 100000000000:
           return [[SeafPlanBasic alloc] init];
           break;
       case 200000000000:
           return [[SeafPlanStandard alloc] init];
           break;
       case 500000000000:
           return [[SeafPlanEnterprise alloc] init];
           break;
       case 2000000000000:
           return [[SeafPlanPlatinum alloc] init];
           break;
       default:
           return [[SeafPlanBasic alloc] init];
           break;
   }
    
}

@end
