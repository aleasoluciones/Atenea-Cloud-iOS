//
//  SeafSyncErrorLogger.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 11/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncSettings.h"
#import "SeafSyncTargetNotFoundError.h"
#import "SeafSyncQuotaExceededError.h"
#import "SeafSyncSourceNotFoundError.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncErrorLogger : NSError

+ (instancetype)sharedInstance;

/**
 * Handles the provided error and registers it in the specified sync setting.
 *
 * @param error The error to be handled.
 * @param setting The sync setting to register the error in.
 */
- (void)log:(NSError *)error inSetting:(SeafSyncSettings *)setting;

@end

NS_ASSUME_NONNULL_END
