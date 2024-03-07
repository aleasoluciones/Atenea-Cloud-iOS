//
//  SeafSyncLegacyMigrator.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 23/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncLegacyMigrator : NSObject

+(void) migrate:(SeafConnection *) connection;

@end

NS_ASSUME_NONNULL_END
