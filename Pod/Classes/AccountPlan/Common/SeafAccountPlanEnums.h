//
//  SeafAccountPlanEnums.h
//  Seafile
//
//  Created by apps meytel on 19/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


///SeafPlanType

///
///Possible values:
///PlanTypeBasic => Account plan basic
///PlanTypeStandard => Account plan standard
///PlanTypeEnterprise => Account plan enterprise
///PlanTypePlatinum => Account plan platinium
///
typedef NS_ENUM(NSInteger, SeafPlanType) {
    PlanTypeBasic,
    PlanTypeStandard,
    PlanTypeEnterprise,
    PlanTypePlatinum

};

NS_ASSUME_NONNULL_END
