//
//  SyncSettingBaseExpirator.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 17/11/23.
//

#import "SyncSettingBaseExpirator.h"
#import "SeafSyncSettings.h"
#import "SeafSyncLogsService.h"
#import "SeafSyncLog.h"
#import "SeafSyncUtils.h"
#import "Debug.h"
#import "ExtentedString.h"

/**
 * SyncSettingBaseExpirator()
 * @brief Private interface for SyncSettingBaseExpirator.
 */
@interface SyncSettingBaseExpirator()
@property (nonatomic, retain) SeafSyncSettings *setting;
@property (nonatomic, retain) SeafSyncLogsService *logsService;
@end


@implementation SyncSettingBaseExpirator

/**
 * @brief Initializes a new instance of the SyncSettingBaseExpirator class with the specified settings.
 * @param setting The synchronization settings.
 * @return An initialized instance of SyncSettingBaseExpirator.
 */
-(id) initWithSettings: (SeafSyncSettings *) setting{
    self = [super init];
    if(self){
        self.setting =  setting;
        self.logsService = [[SeafSyncLogsService alloc] initWithConnection:self.setting.connection];
    }
    return  self;
}


/**
 * @brief Removes a synchronization log from the cloud repository using the specified log information.
 * @param log The synchronization log to be removed.
 */
-(void) removeFileFromCloudUsing:(SeafSyncLog *) log{
    NSString *requestUrl = [NSString stringWithFormat:API_URL_V21"/repos/%@/file/?is_dir=false&p=%@/%@", self.setting.repoId, [log.remotePath escapedUrl],[log.remoteName escapedPostForm]];

    [self.setting.connection sendDelete:requestUrl success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull JSON) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
        [self updateLogExpirationState:log];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, id  _Nullable JSON, NSError * _Nullable error) {
        NSLog(@"resp=%ld\n", (long)response.statusCode);
    }];
}

/**
 * @brief Updates the expiration state of a synchronization log.
 *
 * This method sets the `expirationRanOn` property of the specified synchronization log to the current date and updates the log using the logs service.
 *
 * @param log The synchronization log to be updated.
 */
-(void) updateLogExpirationState:(SeafSyncLog *) log{
    log.expirationRanOn =  [NSDate date];
    [self.logsService update:log];
}



@end
