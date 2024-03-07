/**
 * @file SeafSyncronizer.m
 * @brief Implementation of the SeafSyncronizer class.
 *
 * This class acts as a facade for synchronization.
 * It allows adding synchronization settings, removing synchronization settings, and executing synchronizations.
 * For each active synchronization, it will instantiate a "SeafSyncUploader" through the "SeafSyncEnqueuerFactory".
 * This "SeafSyncUploader" will be responsible for adding files to the upload queue.
 */
#import "SeafSyncronizer.h"
#import "SeafEnqueuerProtocol.h"
#import "SeafSyncEnqueuerFactory.h"
#import "SeafSyncSettings.h"
#import "SeafSyncSettingsService.h"
#import "SeafSyncNetworkerService.h"
#import "SeafSyncObserverFactory.h"
#import "SeafSyncObserverProtocol.h"
#import "SeafUIBridge.h"
#import "SeafSyncExpirationManager.h"
#import "SeafSyncLocationObserver.h"


@interface SeafSyncronizer()

@property (nonatomic, strong) NSMutableArray<SeafSyncSettings *> *settings; ///< List of synchronization settings.
@property (nonatomic, strong) NSMutableArray<id<SeafSyncObserverProtocol>> *observers; ///< List of synchronization observers.
@property (nonatomic, strong) SeafSyncNetworkerService *networkService; ///< Synchronization network service.
@property (nonatomic, strong) SeafConnection *connection; ///< The Seafile connection.
@property (nonatomic, strong) SeafSyncSettingsService *settingsService; ///< Service for synchronization settings.

@end

@implementation SeafSyncronizer

static NSMutableArray<SeafSyncronizer *> *sharedInstances = nil; ///< List of shared SeafSyncronizer instances.


+(NSArray<SeafSyncronizer *> *)allInstances{
    return sharedInstances;
}


/**
 * Gets SeafSyncronizer instance for connection.
 *
 * @param connection The SeafConnection instance.
 * @return A shared instance of SeafSyncronizer.
 */
+ (instancetype)sharedInstanceFor:(SeafConnection *)connection {
    
    if(sharedInstances == nil){
        sharedInstances = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    SeafSyncronizer *synchronizer = [SeafSyncronizer getInstaceFor:connection];
    if(synchronizer != nil){
        return synchronizer;
    }

    // Create for this connection
    synchronizer = [[SeafSyncronizer alloc] initWithConnection:connection];
    [sharedInstances addObject:synchronizer];
    return synchronizer;
}

/**
 * Gets the unique instance for a connection.
 *
 * @param connection The SeafConnection instance.
 * @return The unique instance of SeafSyncronizer for the specified connection.
 */
+ (instancetype)getInstaceFor:(SeafConnection *)connection {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafSyncronizer  *syncrhonizer, NSDictionary<NSString *,id> * _Nullable bindings) {
        return syncrhonizer.connection == connection;
    }];
    return [[sharedInstances filteredArrayUsingPredicate:predicate] firstObject];
}

/**
 * Initializes a new instance of SeafSyncronizer with a SeafConnection instance and the default SeafSyncSettingsRepository.
 *
 * @param connection The SeafConnection instance.
 * @return A new instance of SeafSyncronizer.
 */
- (instancetype)initWithConnection:(SeafConnection *)connection {
    return [self initWithConnection:connection settingsService:[[SeafSyncSettingsService alloc] initWithConnection:connection]];
}

/**
 * Initializes a new instance of SeafSyncronizer with a SeafConnection instance and a SeafSyncSettingsRepository.
 *
 * @param connection The SeafConnection instance.
 * @param settingsService The SeafSyncSettingsRepository.
 * @return A new instance of SeafSyncronizer.
 */
- (instancetype)initWithConnection:(SeafConnection *)connection settingsService:(SeafSyncSettingsService *)settingsService {
    self = [super init];
    if (self) {
        self.settingsService = settingsService;
        self.connection = connection;
        self.networkService = [SeafSyncNetworkerService sharedInstanceFor:self.connection];
        self.observers =  [[NSMutableArray alloc] initWithCapacity:0];
        
        [self loadSettings];
        [self initializeObservers];
    }
    
    return self;
}

/**
 * Loads synchronization settings.
 */
- (void)loadSettings {
    self.settings = [NSMutableArray arrayWithArray:[self.settingsService activeSettings]];
}


/**
 Notifies errors if needed.

 This method checks for errors and notifies if any errors are present.
*/
-(void) notifyErrorsIfNeeded{
    for (SeafSyncSettings *setting in self.settings) {
        if(setting.lastRunError != SeafSyncErrorNoError){
            [[SeafUIBridge sharedInstance] alert:NSLocalizedString(@"Information", @"Seafile") message:NSLocalizedString(@"Some backups did not run successfully. Please review the settings.", @"Seafile")];
            return;
        }
    }
}

/**
 * Initializes synchronization observers for folder settings.
 */
- (void)initializeObservers {
    for (SeafSyncSettings *setting in [self.settings copy]) {
        //Only observe if active
        if(setting.active){
            
            id<SeafSyncObserverProtocol> observer = [SeafSyncObserverFactory createFor:setting];
            [observer start:^(id  _Nonnull object) {
                [self startSyncForSetting:setting];
            }];
            
            [self.observers addObject:observer];
            
        }
    }
}

/**
 * Reloads synchronization observers.
 */
-(void) reloadObservers{
    [self stopObservers];
    [self.observers removeAllObjects];
    [self initializeObservers];
}

/**
 * Stops synchronization observers.
 */
-(void) stopObservers{
    for ( id<SeafSyncObserverProtocol> observer in self.observers) {
        [observer stop];
    }
}

/**
 * Starts synchronization.
 */
- (void)sync {
    
    if([self.networkService hasConnection]){
        // Reload settings before sync.
        // If "wifi connection" was not available when 'sync' gets called, all the settings with "wifyOnly" were not loaded so
        // we need to reload to ensure all settings with wifiOnly are loaded now
        [self loadSettings];
        
        // Sync every single setting
        for (SeafSyncSettings *setting in [self.settings copy]) {
            NSLog(@"Starting setting %@",setting.identifier);
           
            [self startSyncForSetting:setting];
            
            [self removeExpiredFilesForSetting:setting];
            
        }
    }
    else{
        [self syncWhenConnectionAvailable];
    }
}

/**
 * Synchronizes when the connection becomes available.
 */
- (void)syncWhenConnectionAvailable {
    [self.networkService subscribe:self];
}

/**
 * Callback for SeafSyncNetworkerService network status change.
 *
 * @param state The new network state.
 */
- (void)onSeafSyncNetworkStatusChange:(SeafSyncNetworkState)state {
    // Unsubscribe from network changes
    [self.networkService unSubscribe:self];
    
    // Tries to sync again
    [self sync];
    
    // Reload observers
    // Necessary to load settings with wifiOnly or similar if when settings were loaded wifi was not activated
    [self reloadObservers];
}

/**
 * Starts synchronization for a SeafSyncSettings.
 *
 * @param setting The SeafSyncSettings to synchronize.
 */
- (void)startSyncForSetting:(SeafSyncSettings *)setting {
    
    //Only run if active
    if(setting.active){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            id<SeafEnqueuerProtocol> enqueuer = [SeafSyncEnqueuerFactory getEnqueuerFor:self.connection settings:setting];
            [enqueuer enqueue];
        });
    }
}

/**
 * Starts synchronization for a SeafSyncSettings.
 *
 * @param setting The SeafSyncSettings to synchronize.
 */
- (void)removeExpiredFilesForSetting:(SeafSyncSettings *)setting {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SeafSyncExpirationManager sharedInstance] run:setting];
    });
}

/**
 * Adds a new synchronization setting. Adds new settings to the configuration and starts synchronization for this unique setting.
 *
 * @param settings The SeafSyncSettings to add.
 */
- (void)add:(SeafSyncSettings *)settings {
    
    // Set the accountId
    settings.accountId = self.connection.username;
    
    [self.settingsService add:settings];
    self.settings = [NSMutableArray arrayWithArray:[self.settingsService getSettings]];
    [self startSyncForSetting:settings];
    [self reloadObservers];
}

/**
 * Removes a synchronization setting.
 *
 * @param settings The SeafSyncSettings to remove.
 */
- (void)remove:(SeafSyncSettings *)settings {
    // Set the accountId
    settings.accountId = self.connection.username;
    
    [self.settingsService remove:settings];
    self.settings = [NSMutableArray arrayWithArray:[self.settingsService getSettings]];
    [self reloadObservers];
}


/**
 * @brief Gets all settings in this syncronizer
 * @return An array of SeafSyncSettings.
 */
- (NSArray<SeafSyncSettings * > *)settings{
    return [self.settingsService getSettings];
}

/**
 * @brief Returns the current SeafConnection for this syncronizer
 *
 * @return An instance of SeafConnection.
 */
- (SeafConnection *)getConnectionInUse{
    return self.connection;
}



@end

