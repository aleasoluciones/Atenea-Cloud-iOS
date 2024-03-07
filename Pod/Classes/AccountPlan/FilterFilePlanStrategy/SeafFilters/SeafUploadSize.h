//
//  SeafUploadSize.h
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//
#import "SeafFileFilterStrategy.h"
#import "SeafPlanUser.h"
#import "SeafFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafUploadSize : NSObject<SeafFileFilterStrategy>

-(id)initWithPlan:(SeafPlanUser *)planUser;

@end

NS_ASSUME_NONNULL_END

