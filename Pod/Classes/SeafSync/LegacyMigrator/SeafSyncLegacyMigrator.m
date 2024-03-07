/**
 * @file SeafSyncLegacyMigrator.m
 * @brief This file contains the implementation of the SeafSyncLegacyMigrator class.
 * @author Javier Godoy ( javigodoy@meytel.net)
 * @date 23/10/23
 */

#import "SeafSyncLegacyMigrator.h"
#import "SeafStorage.h"
#import "SeafSyncSettings.h"
#import "SeafSyncronizer.h"

@implementation SeafSyncLegacyMigrator

/**
 * @brief Get the key for the given SeafConnection.
 * @param connection The SeafConnection for which the key is needed.
 * @return The key for the SeafConnection.
 */
+(NSString *) keyFor:(SeafConnection *) connection{
    return [@"" stringByAppendingFormat:@"seaf_sync_migrated_for_conn_%@",connection.accountIdentifier];
}

/**
 * @brief Migrate camera settings for the given SeafConnection.
 * @param connection The SeafConnection for which camera settings need to be migrated.
 */
+(void) migrate:(SeafConnection *) connection{
    
   if([self legacyCameraSyncActiveIn:connection] && ! [self alreadyMigratedConnection:connection]){
        [self migrateCameraSettingsFor:connection];
    }
}

/**
 * @brief Migrate camera settings for the given SeafConnection.
 * @param connection The SeafConnection for which camera settings need to be migrated.
 */
+(void) migrateCameraSettingsFor:(SeafConnection *)connection{
    
    //Create Setting
    SeafSyncSettings *gallerySetting =  [self createSettingFrom:connection];
    
    //Add to syncronizer
    [[SeafSyncronizer sharedInstanceFor:connection] add:gallerySetting];

    //Set as migrated
    [self setMigratedFor:connection];
}

/**
 * @brief Check if legacy camera sync is active for the given SeafConnection.
 * @param connection The SeafConnection to check.
 * @return YES if legacy camera sync is active, NO otherwise.
 */
+(BOOL) legacyCameraSyncActiveIn:(SeafConnection *) connection{

    NSString *repo = [self getLegacyConfigFrom:connection withKey:@"autoSyncRepo"];
    BOOL autoSync = [[self getLegacyConfigFrom:connection withKey:@"autoSync"] booleanValue:TRUE];
    
    return (repo != nil && autoSync);
}

/**
 * @brief Create SeafSyncSettings from the given SeafConnection.
 * @param connection The SeafConnection from which to create the SeafSyncSettings.
 * @return The created SeafSyncSettings.
 */
+(SeafSyncSettings *) createSettingFrom:(SeafConnection *) connection {
    SeafSyncSettings *cameraSetting = [[SeafSyncSettings alloc] init];
    cameraSetting.repoId = [self getLegacyConfigFrom:connection withKey:@"autoSyncRepo"];
    cameraSetting.mode = Full;
    cameraSetting.targetId = @"Camera Uploads";
    cameraSetting.sourceType = Gallery;
    cameraSetting.uploadVideos = [[self getLegacyConfigFrom:connection withKey:@"videoSync"] booleanValue:TRUE];
    cameraSetting.uploadOnlyOverWifi = [[self getLegacyConfigFrom:connection withKey:@"wifiOnly"] booleanValue:TRUE];
    cameraSetting.accountId = connection.username;
    cameraSetting.lifeTime = SeafSyncLifetimeTypePermanent;
    cameraSetting.durationOfBackupFilesOnCloudInDays = 0; //Forever
    cameraSetting.active = TRUE;
    cameraSetting.fullSourceURL = @"gallery";
    cameraSetting.connection = connection;
    cameraSetting.creationDate = [NSDate date];
    return cameraSetting;
}

+(id) getLegacyConfigFrom:(SeafConnection *) connection withKey:(NSString *) key{
    return [connection getAttribute:key];
}

/**
 * @brief Check if the given SeafConnection has already been migrated.
 * @param connection The SeafConnection to check.
 * @return YES if the connection has already been migrated, NO otherwise.
 */
+(BOOL) alreadyMigratedConnection:(SeafConnection *) connection{
   return [SeafStorage.sharedObject objectForKey:[self keyFor:connection]] != nil;
}

/**
 * @brief Set the migration status for the given SeafConnection.
 * @param connection The SeafConnection for which to set the migration status.
 */
+(void) setMigratedFor:(SeafConnection *) connection{
    [SeafStorage.sharedObject setObject:[self keyFor:connection]  forKey: [self keyFor:connection]];
}

@end

