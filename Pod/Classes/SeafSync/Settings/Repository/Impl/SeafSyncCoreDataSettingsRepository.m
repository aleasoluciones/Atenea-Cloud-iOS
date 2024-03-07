/**
 * @file SeafSyncCoreDataSettingsRepository.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncCoreDataSettingsRepository class.
 *
 * This file contains the implementation of the SeafSyncCoreDataSettingsRepository class, which provides a default implementation of the SeafSyncSettingsRepository protocol.
 */

#import "SeafSyncCoreDataSettingsRepository.h"


@interface SeafSyncCoreDataSettingsRepository ()

@property (nonatomic, strong) NSString *settingsModel;
@property (nonatomic, strong) NSString *modelName;

@end


@implementation SeafSyncCoreDataSettingsRepository

static NSManagedObjectContext *_managedObjectContext;


- (NSManagedObjectContext *)managedObjectContext {
    
    if (!_managedObjectContext){
        [self initializePersistentContainer];
    }
    
    return _managedObjectContext;
}


/**
 * @brief Initializes a new instance of SeafSyncCoreDatasettingRepository.
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.modelName = @"Model";
        self.settingsModel = @"SyncSettings";
       // [self initializePersistentContainer];
    }
    return self;
}

/**
 * @brief Initializes the persistent container for CoreData.
 */
- (void)initializePersistentContainer {
    NSPersistentContainer *persistentContainer = [[NSPersistentContainer alloc] initWithName:self.modelName];
    
    [persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (error != nil) {
            NSLog(@"Error al cargar el almacén persistente: %@", error);
            abort();
        }
        
        _managedObjectContext = [persistentContainer newBackgroundContext];
    }];
}

/**
 * @brief Retrieves all synchronization setting entries.
 * @return An array containing all synchronization setting entries.
 */
- (nonnull NSMutableArray<SeafSyncSettings *> *)all {
  
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.settingsModel];

    NSError *fetchError = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];

    if (fetchError) {
        NSLog(@"Error al recuperar datos de CoreData: %@", fetchError);
    } else {
        return [self map:results];
    }
    
    //No data. Empty array
    return [[NSMutableArray alloc] init];
}

/**
 * @brief Clears all synchronization setting entries.
 */
- (void)clear {
    
     NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.settingsModel];

    NSError *fetchError = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];

    if (!fetchError) {
        for (NSManagedObject *object in results) {
            [self.managedObjectContext deleteObject:object];
        }
        [self saveContext:self.managedObjectContext];
    }
}

/**
 * @brief Inserts a new synchronization setting entry.
 * @param setting The SeafSyncSettings object representing the synchronization setting entry to be inserted.
 */
- (void)insert:(nonnull SeafSyncSettings *)setting {
    
    [self remove:setting];
    

    NSManagedObject *coreDatasettingItem = [NSEntityDescription insertNewObjectForEntityForName:self.settingsModel inManagedObjectContext:self.managedObjectContext];
    [coreDatasettingItem setValue:@(setting.active) forKey:@"active"];
    [coreDatasettingItem setValue:setting.identifier forKey:@"identifier"];
    [coreDatasettingItem setValue:@(setting.state) forKey:@"state"];
    [coreDatasettingItem setValue:@(setting.mode) forKey:@"mode"];
    [coreDatasettingItem setValue:@(setting.sourceType) forKey:@"sourceType"];
    [coreDatasettingItem setValue:setting.repoId forKey:@"repoId"];
    [coreDatasettingItem setValue:setting.accountId forKey:@"accountId"];
    [coreDatasettingItem setValue:setting.availableUntilDate forKey:@"availableUntilDate"];
    [coreDatasettingItem setValue:@(setting.durationOfBackupFilesOnCloudInDays) forKey:@"durationOfBackupFilesOnCloudInDays"];
    [coreDatasettingItem setValue:setting.creationDate forKey:@"creationDate"];
    [coreDatasettingItem setValue:setting.lastRunTime forKey:@"lastRunTime"];
    [coreDatasettingItem setValue:@(setting.lastRunError) forKey:@"lastRunError"];
    [coreDatasettingItem setValue:setting.resourceId forKey:@"resourceId"];
    [coreDatasettingItem setValue:setting.targetId forKey:@"targetId"];
    [coreDatasettingItem setValue:@(setting.uploadVideos) forKey:@"uploadVideos"];
    [coreDatasettingItem setValue:@(setting.uploadOnlyOverWifi) forKey:@"uploadOnlyOverWifi"];
    [coreDatasettingItem setValue:setting.fullSourceURL forKey:@"fullSourceURL"];
    [coreDatasettingItem setValue:@(setting.deleteFilesOnExpire) forKey:@"deleteFilesOnExpire"];
    [coreDatasettingItem setValue:@(setting.lifeTime) forKey:@"lifeTime"];
    
    
    
    
    [self saveContext:self.managedObjectContext];
}

/**
 * @brief Removes a synchronization setting entry.
 * @param setting The SeafSyncSettings object representing the synchronization setting entry to be removed.
 */
- (void)remove:(nonnull SeafSyncSettings *)setting {
  
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.settingsModel];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@",setting.identifier]];

    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (!error && result.count > 0) {
        [self.managedObjectContext deleteObject:[result firstObject]];
        [self saveContext:self.managedObjectContext];
    }
}



/**
 * @brief Removes a synchronization setting entry.
 * @param predicate The NSPredicate object representing the synchronization setting entry to be removed.
 */
- (void)removeWith:(NSPredicate *)predicate {
   
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.settingsModel];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (!error && results.count > 0) {
        
        for (NSManagedObject *settingToDelete in results) {
            [self.managedObjectContext deleteObject:settingToDelete];
        }

        [self saveContext:self.managedObjectContext];
    }
}


/**
 * @brief Updates a synchronization setting entry.
 * @param setting The SeafSyncSettings object representing the synchronization setting entry to be updated.
 */
- (void)update:(nonnull SeafSyncSettings *)setting {

    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.settingsModel];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@",setting.identifier]];

    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (!error && result.count > 0) {
        
        NSManagedObject *coreDatasettingItem = [result firstObject];
        [coreDatasettingItem setValue:@(setting.active) forKey:@"active"];
        [coreDatasettingItem setValue:@(setting.state) forKey:@"state"];
        [coreDatasettingItem setValue:@(setting.mode) forKey:@"mode"];
        [coreDatasettingItem setValue:@(setting.sourceType) forKey:@"sourceType"];
        [coreDatasettingItem setValue:setting.repoId forKey:@"repoId"];
        [coreDatasettingItem setValue:setting.accountId forKey:@"accountId"];
        [coreDatasettingItem setValue:setting.availableUntilDate forKey:@"availableUntilDate"];
        [coreDatasettingItem setValue:@(setting.durationOfBackupFilesOnCloudInDays) forKey:@"durationOfBackupFilesOnCloudInDays"];
        [coreDatasettingItem setValue:setting.creationDate forKey:@"creationDate"];
        [coreDatasettingItem setValue:setting.lastRunTime forKey:@"lastRunTime"];
        [coreDatasettingItem setValue:@(setting.lastRunError) forKey:@"lastRunError"];
        [coreDatasettingItem setValue:setting.resourceId forKey:@"resourceId"];
        [coreDatasettingItem setValue:setting.targetId forKey:@"targetId"];
        [coreDatasettingItem setValue:@(setting.uploadVideos) forKey:@"uploadVideos"];
        [coreDatasettingItem setValue:@(setting.uploadOnlyOverWifi) forKey:@"uploadOnlyOverWifi"];
        [coreDatasettingItem setValue:setting.fullSourceURL forKey:@"fullSourceURL"];
        [coreDatasettingItem setValue:@(setting.deleteFilesOnExpire) forKey:@"deleteFilesOnExpire"];
        [coreDatasettingItem setValue:@(setting.lifeTime) forKey:@"lifeTime"];

        [self saveContext:self.managedObjectContext];

    }
}


/**
 * @brief Filters synchronization setting entries based on a predicate.
 * @param predicate The NSPredicate used for filtering setting entries.
 * @return An array containing synchronization setting entries that match the predicate.
 */
- (NSArray<SeafSyncSettings *> *)filter:(NSPredicate *)predicate {

    NSArray<SeafSyncSettings *> *settings = [self all];

    return [settings filteredArrayUsingPredicate:predicate];

}

/**
 * @brief Saves changes to the CoreData context.
 * @param context The NSManagedObjectContext to be saved.
 */
- (void)saveContext:(NSManagedObjectContext *)context {
    NSError *saveError = nil;
    if (![context save:&saveError]) {
        NSLog(@"Error al guardar en CoreData: %@", saveError);
    }
}


/**
 * @brief Maps an array of NSManagedObject results to an array of SeafSyncSettings objects.
 *
 * This method takes an array of NSManagedObject results and maps each object to a SeafSyncSettings object, extracting values from the corresponding attributes.
 *
 * @param results An array of NSManagedObject results to be mapped.
 *
 * @return An NSMutableArray containing SeafSyncSettings objects mapped from the provided NSManagedObject results.
 */
- (NSMutableArray<SeafSyncSettings *> *)map:(NSArray *)results {
    NSMutableArray<SeafSyncSettings *> *settings = [[NSMutableArray<SeafSyncSettings *> alloc] initWithCapacity:0];
    
    for (NSManagedObject *object in results) {
        SeafSyncSettings *setting = [[SeafSyncSettings alloc] init];
        setting.active =  [[object valueForKey:@"active"] boolValue];
        setting.identifier =  [object valueForKey:@"identifier"];
        setting.state = (SeafSyncState) [[object valueForKey:@"state"] integerValue];
        setting.mode = (SeafSyncMode) [[object valueForKey:@"mode"] integerValue];
        setting.sourceType = (SeafSyncType) [[object valueForKey:@"sourceType"] integerValue];
        setting.repoId =  [object valueForKey:@"repoId"];
        setting.accountId =  [object valueForKey:@"accountId"];
        setting.availableUntilDate =  [object valueForKey:@"availableUntilDate"];
        setting.durationOfBackupFilesOnCloudInDays =  [[object valueForKey:@"durationOfBackupFilesOnCloudInDays"] integerValue];
        setting.creationDate =  [object valueForKey:@"creationDate"];
        setting.lastRunTime =  [object valueForKey:@"lastRunTime"];
        setting.lastRunError = (SeafSyncError)[[object valueForKey:@"lastRunError"] integerValue];
        setting.resourceId =  [object valueForKey:@"resourceId"];
        setting.targetId =  [object valueForKey:@"targetId"];
        setting.uploadVideos =  [[object valueForKey:@"uploadVideos"] boolValue];
        setting.uploadOnlyOverWifi =  [[object valueForKey:@"uploadOnlyOverWifi"] boolValue];
        setting.fullSourceURL =  [object valueForKey:@"fullSourceURL"];
        setting.deleteFilesOnExpire =  [[object valueForKey:@"deleteFilesOnExpire"] boolValue];
        setting.lifeTime = (SeafSyncLifetimeType) [[object valueForKey:@"lifeTime"] integerValue];
        
        [settings addObject:setting];
    }
    
    return settings;
}


@end
