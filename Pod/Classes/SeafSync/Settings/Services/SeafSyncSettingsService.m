/**
 * @file SeafSyncSettingsService.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncSettingsService class.
 *
 * This file contains the implementation of the SeafSyncSettingsService class, which provides a service for managing synchronization settings.
 */

#import "SeafSyncSettingsService.h"
#import "SeafSyncSettingsRepository.h"
#import "DefaultSeafSyncSettingsRepository.h"
#import "SeafSyncCoreDataSettingsRepository.h"
#import "SeafSyncUtils.h"
#import "SeafSyncNetworkerService.h"
#import "SeafDataTaskManager.h"
#import "SeafSyncLogsService.h"


@interface SeafSyncSettingsService()

@property (nonatomic, strong) id<SeafSyncSettingsRepository> settingsRepository;
@property (nonatomic, strong) SeafConnection *connection;
@property (nonatomic, strong) SeafSyncLogsService *logsService;

@end

@implementation SeafSyncSettingsService

/**
 * Initializes an instance of SeafSyncSettingsService with the default configuration.
 *
 * @return An instance of SeafSyncSettingsService.
 */
-(instancetype)initWithConnection:(SeafConnection *) connection{
    return [self initWith:[[SeafSyncCoreDataSettingsRepository alloc] init] andConnection:connection];
}

/**
 * Initializes an instance of SeafSyncSettingsService with a specific repository.
 *
 * @param repository The configuration repository to use.
 * @return An instance of SeafSyncSettingsService.
 */
-(instancetype)initWith:(id<SeafSyncSettingsRepository>) repository andConnection:(SeafConnection *) connection{
    self = [super self];
    if(self){
        self.settingsRepository = repository;
        self.connection = connection;
        self.logsService = [[SeafSyncLogsService alloc] initWithConnection:self.connection];
    }
    return self;
}

/**
 * Gets the list of all synchronization settings.
 *
 * @return An array of SeafSyncSettings objects.
 */
-(NSArray<SeafSyncSettings *> *) getSettings{
    return [self all];
}

/**
 * Adds a synchronization setting to the list.
 *
 * @param setting The synchronization setting to add.
 */
-(void) add:(SeafSyncSettings *) setting{
    
    [self.settingsRepository insert:setting];
    
    //If disable, clear pending tasks from queue
    if(!setting.active){
        // Remove files associated with the sync setting from the upload queue
        [self removeFilesInQueueFromSetting:setting];
    }
}

/**
 Removes a sync setting and its associated files from the synchronization manager.

 This method removes the specified sync setting from the settings repository and also removes
 any files associated with the setting from the upload queue.

 @param setting The `SeafSyncSettings` object representing the sync setting to be removed.
 */
- (void)remove:(SeafSyncSettings *)setting {
    // Remove the sync setting from the settings repository
    [self.settingsRepository remove:setting];

    //Remove logs
    [self.logsService removeFromSetting:setting];
    
    // Remove files associated with the sync setting from the upload queue
    [self removeFilesInQueueFromSetting:setting];
    
}


/**
 * Removes all settings from the database.
 */
-(void) clear{
    [self.settingsRepository clear];
}

/**
 * Gets the list of all synchronization settings.
 *
 * @return An array of SeafSyncSettings objects.
 */
-(NSArray<SeafSyncSettings *> *)all{
    
    NSPredicate *filter =[NSPredicate predicateWithBlock:^BOOL(SeafSyncSettings *setting, NSDictionary<NSString *,id> * _Nullable bindings) {
       return  [setting.accountId isEqualToString:self.connection.username];
    }];
    
    NSArray<SeafSyncSettings *> *settings = [self.settingsRepository filter: filter];
    
    //Sets the connection object
    [settings enumerateObjectsUsingBlock:^(SeafSyncSettings * _Nonnull setting, NSUInteger idx, BOOL * _Nonnull stop) {
        setting.connection = self.connection;
    }];
    
    return settings;
}

/**
 Finds and returns an array of SeafSyncSettings objects based on the specified predicate.

 This method searches for SeafSyncSettings objects in the collection that satisfy the given predicate.

 @param predicate The predicate to use for filtering the results.
 @return An array of SeafSyncSettings objects that match the specified predicate.

 @note The returned array may be empty if no matching objects are found.
 */
- (NSArray<SeafSyncSettings *> *)find:(NSPredicate *) predicate{
    return [[self all] filteredArrayUsingPredicate:predicate];
}

/**
 * Gets the list of all active synchronization settings.
 *
 * @return An array of SeafSyncSettings objects.
 */
-(NSArray<SeafSyncSettings *> *)activeSettings{
    
    NSPredicate *filter =[NSPredicate predicateWithBlock:^BOOL(SeafSyncSettings *setting, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        //No active
        if(!setting.active){
            return false;
        }
        
        //No expired settings
        NSDate *today = [NSDate date];
        if([SeafSyncUtils date:setting.availableUntilDate isPreviousThan:today]){
            return false;
        }
        
        //If this setting is only active with Wifi and is not available, do not return it
        if(setting.uploadOnlyOverWifi && ![[SeafSyncNetworkerService sharedInstanceFor:self.connection] wifiConnectionAvailable]){
            return false;
        }
        
        return true;
        
    }];
   
    return [[self all] filteredArrayUsingPredicate:filter];
}


/**
 * Updates the state of a synchronization setting.
 *
 * @param setting The synchronization setting whose state to update.
 * @param error The error
 */
-(void) registerErrorIn:(SeafSyncSettings *) setting withError:(NSError *) error{
    setting.state = SeafSyncStateError;
    setting.lastRunError = (SeafSyncError)error.code;
    [self.settingsRepository update:setting];
}

/**
 * Updates the state of a synchronization setting.
 *
 * @param setting The synchronization setting whose state to update.
 * @param state The new state of the setting.
 */
-(void) updateState:(SeafSyncSettings *) setting to:(SeafSyncState) state{
    setting.state = state;
    setting.lastRunError = SeafSyncErrorNoError;
    [self.settingsRepository update:setting];
}

/**
 * Sets the last run time for a synchronization setting.
 *
 * @param setting The synchronization setting for which to set the last run time.
 */
-(void) setLastRunTime:(SeafSyncSettings *) setting{
    setting.lastRunTime = [NSDate date];
    [self.settingsRepository update:setting];
}


/**
 Removes files from the upload queue associated with a specific sync setting.

 This method iterates through the tasks in the upload queue of the current account's connection
 and removes tasks that are associated with the specified sync setting.

 @param setting The `SeafSyncSettings` object representing the sync setting for which files should be removed from the queue.
 */
- (void)removeFilesInQueueFromSetting:(SeafSyncSettings *)setting {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Retrieve the upload queue associated with the current connection
        SeafTaskQueue *uploadQueue = [[SeafDataTaskManager.sharedObject accountQueueForConnection:self.connection] uploadQueue];
        
        // Get all tasks from this syncronization
        NSArray<SeafUploadFile *> *filesInQueue = [[uploadQueue allTasks] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SeafUploadFile * _Nonnull uploadFile, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [uploadFile.syncId isEqualToString:setting.identifier];
        }]];
        
        
        // Cancel each task (SeafUploadFile)
        [filesInQueue enumerateObjectsUsingBlock:^(SeafUploadFile * _Nonnull uploadFile, NSUInteger idx, BOOL * _Nonnull stop) {
                [uploadFile cancel];
        }];
    });
}

@end

