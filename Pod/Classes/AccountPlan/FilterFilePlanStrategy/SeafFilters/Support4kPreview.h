//
//  Support4kPreview.h
//  Seafile
//
//  Created by apps meytel on 30/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "SeafFileProtocol.h"
#import "SeafFileFilterStrategy.h"
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface Support4kPreview : NSObject<SeafFileFilterStrategy>

-(id)initWithPlan:(SeafConnection *)connection repoId:(NSString *)repoId ;

@end

NS_ASSUME_NONNULL_END
