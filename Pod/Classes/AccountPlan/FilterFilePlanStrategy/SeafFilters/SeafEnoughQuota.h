//
//  SeafEnoughQuota.h
//  Seafile
//
//  Created by apps meytel on 26/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "SeafFileProtocol.h"
#import "SeafFileFilterStrategy.h"
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafEnoughQuota : NSObject<SeafFileFilterStrategy>

-(id)initWithConnection:(SeafConnection *)connection;

@end

NS_ASSUME_NONNULL_END

