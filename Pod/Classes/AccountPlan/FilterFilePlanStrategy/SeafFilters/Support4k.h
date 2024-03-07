//
//  Support4k.h
//  Seafile
//
//  Created by apps meytel on 26/10/23.
//
#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "SeafFileProtocol.h"
#import "SeafFileFilterStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface Support4k : NSObject<SeafFileFilterStrategy>

-(id)initWithPlan:(SeafPlanUser *)planUser;

@end

NS_ASSUME_NONNULL_END

