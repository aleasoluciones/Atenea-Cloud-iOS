//
//  SeafSyncErrorFactory.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncErrorFactory : NSError

+(NSError *) createFrom:(SeafSyncError) errorCode;

@end

NS_ASSUME_NONNULL_END
