//
//  SyncSettingBaseExpirator.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncSettings.h"
#import "SeafSyncLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface SyncSettingBaseExpirator : NSObject

- (id) initWithSettings: (SeafSyncSettings *) setting;

/**
 * @brief Removes a synchronization log from the cloud repository using the specified log information.
 * @param log The synchronization log to be removed.
 */
-(void) removeFileFromCloudUsing:(SeafSyncLog *) log;
@end

NS_ASSUME_NONNULL_END
