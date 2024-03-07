//
//  SeafPermissionManager.h
//  Seafile
//
//  Created by apps meytel on 20/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafPermissibleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafPermissionManager : NSObject

+ (instancetype)sharedInstance;

-(BOOL) canRead:(id<SeafPermissibleProtocol>) permissible;

-(BOOL) canWrite:(id<SeafPermissibleProtocol>) permissible;

@end

NS_ASSUME_NONNULL_END
