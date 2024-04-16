/**
 * @file SeafSyncCoreDataLogRepository.m
 * @author: Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncCoreDataLogRepository class.
 *
 * This file contains the implementation of the SeafSyncCoreDataLogRepository class, which is responsible for managing synchronization log entries using CoreData.
 *
 * @author: Javier Godoy (javigodoy@meytel.net)
 */

#import "SeafSyncCoreDataLogRepository.h"
#import "CoreData/CoreData.h"
#import "SeafSyncLog.h"

@interface SeafSyncCoreDataLogRepository ()

@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, strong) NSString *uploadedFileModel;
@property (nonatomic, strong) NSString *modelName;

@end

@implementation SeafSyncCoreDataLogRepository

/**
 * @brief Initializes a new instance of SeafSyncCoreDataLogRepository.
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.modelName = @"Model";
        self.uploadedFileModel = @"UploadedLog";
        [self initializePersistentContainer];
    }
    return self;
}

/**
 * @brief Initializes the persistent container for CoreData.
 */
- (void)initializePersistentContainer {
    self.persistentContainer = [[NSPersistentContainer alloc] initWithName:self.modelName];
    
    [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (error != nil) {
            NSLog(@"Error al cargar el almacén persistente: %@", error);
            abort();
        }
    }];
}

/**
 * @brief Retrieves all synchronization log entries.
 * @return An array containing all synchronization log entries.
 */
- (nonnull NSMutableArray<SeafSyncLog *> *)all {
  
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.uploadedFileModel];

    NSError *fetchError = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];

    if (fetchError) {
        NSLog(@"Error al recuperar datos de CoreData: %@", fetchError);
    } else {
        return [self map:results];
    }
    
    //No data. Empty array
    return [[NSMutableArray alloc] init];
}

/**
 * @brief Clears all synchronization log entries.
 */
- (void)clear {
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.uploadedFileModel];

    NSError *fetchError = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];

    if (!fetchError) {
        for (NSManagedObject *object in results) {
            [context deleteObject:object];
        }
        [self saveContext:context];
    }
}

/**
 * @brief Inserts a new synchronization log entry.
 * @param log The SeafSyncLog object representing the synchronization log entry to be inserted.
 */
- (void)insert:(nonnull SeafSyncLog *)log {
    
    [self remove:log];
    
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    NSManagedObject *coreDataLogItem = [NSEntityDescription insertNewObjectForEntityForName:self.uploadedFileModel inManagedObjectContext:context];
    [coreDataLogItem setValue:log.resourceId forKey:@"resourceId"];
    [coreDataLogItem setValue:log.targetId forKey:@"targetId"];
    [coreDataLogItem setValue:log.uploadedDate forKey:@"uploadedDate"];
    [coreDataLogItem setValue:log.resourceHash forKey:@"resourceHash"];
    [coreDataLogItem setValue:log.accountId forKey:@"accountId"];
    [coreDataLogItem setValue:log.syncSettingId forKey:@"syncSettingId"];
    [coreDataLogItem setValue:log.remoteName forKey:@"remoteName"];
    [coreDataLogItem setValue:log.remoteIdentifier forKey:@"remoteIdentifier"];
    [coreDataLogItem setValue:log.remotePath forKey:@"remotePath"];
    [coreDataLogItem setValue:log.expirationRanOn forKey:@"expirationRanOn"];
    [self saveContext:context];
}

/**
 * @brief Removes a synchronization log entry.
 * @param log The SeafSyncLog object representing the synchronization log entry to be removed.
 */
- (void)remove:(nonnull SeafSyncLog *)log {
    NSManagedObjectContext *managedObjectContext = self.persistentContainer.viewContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.uploadedFileModel];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"syncSettingId == %@ AND resourceId == %@",log.syncSettingId, log.resourceId]];

    NSError *error;
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (!error && result.count > 0) {
        [managedObjectContext deleteObject:[result firstObject]];
        [self saveContext:managedObjectContext];
    }
}



/**
 * @brief Removes a synchronization log entry.
 * @param predicate The NSPredicate object representing the synchronization log entry to be removed.
 */
- (void)removeWith:(NSPredicate *)predicate {
    NSManagedObjectContext *managedObjectContext = self.persistentContainer.viewContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.uploadedFileModel];
    [fetchRequest setPredicate:predicate];

    NSError *error;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (!error && results.count > 0) {
        
        for (NSManagedObject *logToDelete in results) {
            [managedObjectContext deleteObject:logToDelete];
        }

        [self saveContext:managedObjectContext];
    }
}


/**
 * @brief Updates a synchronization log entry.
 * @param log The SeafSyncLog object representing the synchronization log entry to be updated.
 */
- (void)update:(nonnull SeafSyncLog *)log {
    [self remove:log];
    [self insert:log];
}

/**
 * @brief Filters synchronization log entries based on a predicate.
 * @param predicate The NSPredicate used for filtering log entries.
 * @return An array containing synchronization log entries that match the predicate.
 */
- (NSArray<SeafSyncLog *> *)find:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.uploadedFileModel];

    // Assign the predicate to the fetchRequest
    [fetchRequest setPredicate:predicate];

    // Get a reference to the Core Data context (managedObjectContext)
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSManagedObjectContext *managedObjectContext = context;

    // Perform the query
    NSError *error;
    NSArray<SeafSyncLog *> *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if (!error) {
        return [self map:results];
    } else {
        NSLog(@"Error al realizar la consulta: %@", error.localizedDescription);
    }

    return @[];
}

/**
 * @brief Saves changes to the CoreData context.
 * @param context The NSManagedObjectContext to be saved.
 */
- (void)saveContext:(NSManagedObjectContext *)context {
    NSError *saveError = nil;
    @synchronized(context) {
        if (![context save:&saveError]) {
            NSLog(@"Error al guardar en CoreData: %@", saveError);
        }
    }
}


/**
 * @brief Maps an array of NSManagedObject results to an array of SeafSyncLog objects.
 *
 * This method takes an array of NSManagedObject results and maps each object to a SeafSyncLog object, extracting values from the corresponding attributes.
 *
 * @param results An array of NSManagedObject results to be mapped.
 *
 * @return An NSMutableArray containing SeafSyncLog objects mapped from the provided NSManagedObject results.
 */
- (NSMutableArray<SeafSyncLog *> *)map:(NSArray *)results {
    NSMutableArray<SeafSyncLog *> *logs = [[NSMutableArray<SeafSyncLog *> alloc] initWithCapacity:0];
    
    for (NSManagedObject *object in results) {
        SeafSyncLog *log = [[SeafSyncLog alloc] init];
        log.resourceId = [object valueForKey:@"resourceId"];
        log.targetId = [object valueForKey:@"targetId"];
        log.uploadedDate = [object valueForKey:@"uploadedDate"];
        log.resourceHash = [object valueForKey:@"resourceHash"];
        log.accountId = [object valueForKey:@"accountId"];
        log.syncSettingId = [object valueForKey:@"syncSettingId"];
        log.remoteName = [object valueForKey:@"remoteName"];
        log.remoteIdentifier = [object valueForKey:@"remoteIdentifier"];
        log.remotePath = [object valueForKey:@"remotePath"];
        log.expirationRanOn = [object valueForKey:@"expirationRanOn"];
        [logs addObject:log];
    }
    
    return logs;
}


@end

