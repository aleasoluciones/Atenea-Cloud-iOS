// SeafSyncTreeFolderStateCoreDataRepository.m

#import "SeafSyncTreeFolderStateCoreDataRepository.h"
#import "CoreData/CoreData.h"
#import "SeafSyncTreeState.h"
#import "SeafSyncEnums.h"

@interface SeafSyncTreeFolderStateCoreDataRepository ()

@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (nonatomic, strong) NSString *foldersModel;
@property (nonatomic, strong) NSString *modelName;
@property (atomic, strong) NSManagedObjectContext *context;
@property (nonatomic, retain) dispatch_semaphore_t main_semaphore;

@end

@implementation SeafSyncTreeFolderStateCoreDataRepository

/**
 * Initializes a new instance of the SeafSyncTreeFolderStateCoreDataRepository class.
 * @return An initialized SeafSyncTreeFolderStateCoreDataRepository object.
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.modelName = @"Model";
        self.foldersModel = @"FolderState";
        self.main_semaphore = dispatch_semaphore_create(1);
        [self initializePersistentContainer];
    }
    return self;
}

/**
 * Initializes the persistent container with the specified model name.
 */
- (void)initializePersistentContainer {
    self.persistentContainer = [[NSPersistentContainer alloc] initWithName:self.modelName];
    
    [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (error != nil) {
            NSLog(@"Error loading persistent store: %@", error);
            abort();
        }
        self.context = [self.persistentContainer newBackgroundContext];
    }];
}

/**
 * Retrieves all synchronization tree states stored in CoreData.
 * @return An array of SeafSyncTreeState objects representing all stored synchronization tree states.
 */
- (nonnull NSMutableArray<SeafSyncTreeState *> *)all {
    NSMutableArray<SeafSyncTreeState *> *items = [[NSMutableArray<SeafSyncTreeState *> alloc] initWithCapacity:0];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.foldersModel];

    NSError *fetchError = nil;
    NSArray *results = [self.context executeFetchRequest:fetchRequest error:&fetchError];

    if (fetchError) {
        NSLog(@"Error fetching CoreData data: %@", fetchError);
    } else {
        items = [self mapArray:results];
    }

    return items;
}

/**
 * Clears all synchronization tree states from CoreData.
 */
- (void)clear {
    dispatch_semaphore_wait(self.main_semaphore, DISPATCH_TIME_FOREVER);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.foldersModel];

    NSError *fetchError = nil;
    NSArray *results = [self.context executeFetchRequest:fetchRequest error:&fetchError];

    if (!fetchError) {
        for (NSManagedObject *object in results) {
            [self.context deleteObject:object];
        }
        [self saveContext];
    }
}

/**
 * Inserts a synchronization tree state into CoreData.
 * @param state The SeafSyncTreeState object to insert.
 */
- (void)insert:(nonnull SeafSyncTreeState *)state {
    //Just remove the last one
    [self remove:state];
    
    dispatch_semaphore_wait(self.main_semaphore, DISPATCH_TIME_FOREVER);
    
    NSManagedObject *coreDataItem = [NSEntityDescription insertNewObjectForEntityForName:self.foldersModel inManagedObjectContext:self.context];
    
    [coreDataItem setValue:[state getSyncSettingId] forKey:@"syncSettingId"];
    [coreDataItem setValue:[state getId] forKey:@"identifier"];
    [coreDataItem setValue:[state getRelativeHash] forKey:@"relativeHash"];
    [coreDataItem setValue:[state getFullHash] forKey:@"fullHash"];
    [coreDataItem setValue:[[state getURL] absoluteString] forKey:@"folderUrl"];
    [coreDataItem setValue:@([state getType]) forKey:@"type"];
    
    [self saveContext];
}

/**
 * Removes a synchronization tree state from CoreData.
 * @param state The SeafSyncTreeState object to remove.
 */
- (void)remove:(nonnull SeafSyncTreeState *)state {
    dispatch_semaphore_wait(self.main_semaphore, DISPATCH_TIME_FOREVER);
  
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.foldersModel];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"folderUrl == %@ AND syncSettingId == %@ ", [state getURL],[state getSyncSettingId]]];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];

    if (!error && result.count > 0) {
        [self.context deleteObject:[result firstObject]];
        [self saveContext];
    }
    else{
        //Open semaphore
        dispatch_semaphore_signal(self.main_semaphore);
    }
}

/**
 * Updates a synchronization tree state in CoreData.
 * @param state The SeafSyncTreeState object to update.
 */
- (void)update:(nonnull SeafSyncTreeState *)state {
    [self insert:state];
}

/**
 * Checks if a synchronization tree state exists in CoreData.
 * @param state The SeafSyncTreeState object to check.
 * @return A boolean value indicating whether the state exists in CoreData.
 */
-(BOOL) exists:(SeafSyncTreeState *) state {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.foldersModel];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"folderUrl == %@ AND syncSettingId == %@ ", [state getURL],[state getSyncSettingId]]];

    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];

    if (!error) {
        return result.count > 0;
    }
    
    return false;
}

/**
 * Finds synchronization tree states in CoreData based on a predicate.
 * @param predicate The NSPredicate to filter results.
 * @return An array of SeafSyncTreeState objects that match the predicate.
 */
- (NSArray<SeafSyncTreeState *> *)find:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.foldersModel];

    // Assign the predicate to the fetchRequest
    [fetchRequest setPredicate:predicate];

    // Perform the query
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];

    if (!error) {
        return [self mapArray:result];
    } else {
        NSLog(@"Error executing the query: %@", error.localizedDescription);
    }

    return @[];
}

/**
 * Saves changes to the CoreData context.
 */
-(void) saveContext {
    NSError *saveError = nil;
    @synchronized (self.context) {
        if([self.context hasChanges]){
            [self.context save:&saveError];
            if(saveError != nil){
                NSLog(@"Error saving to CoreData: %@", saveError);
            }
        }
    }
    
    //Open semaphore
    dispatch_semaphore_signal(self.main_semaphore);
}

/**
 * Maps a CoreData managed object to a SeafSyncTreeState object.
 * @param object The NSManagedObject to map.
 * @return A SeafSyncTreeState object mapped from the NSManagedObject.
 */
-(SeafSyncTreeState *) map:(NSManagedObject *) object {
    SeafSyncTreeState *state = [[SeafSyncTreeState alloc] init];
    [state  setURL:[[NSURL alloc] initWithString:[object valueForKey:@"folderUrl"]]] ;
    [state  setType:(SyncTreeType)[object valueForKey:@"type"]] ;
    [state  setFullHash:[object valueForKey:@"fullHash"]] ;
    [state  setRelativeHash:[object valueForKey:@"relativeHash"]] ;
    [state  setSyncSettingId:[object valueForKey:@"syncSettingId"]] ;
    [state  setId:[object valueForKey:@"identifier"]] ;
    
    return state;
}

/**
 * Maps an array of CoreData managed objects to an array of SeafSyncTreeState objects.
 * @param objects The array of NSManagedObjects to map.
 * @return An array of SeafSyncTreeState objects mapped from the array of NSManagedObjects.
 */
-(NSMutableArray<SeafSyncTreeState *> *) mapArray:(NSArray<NSManagedObject *> *) objects {
    NSMutableArray<SeafSyncTreeState *>  *results = [[NSMutableArray alloc] initWithCapacity:0];
   
    for (NSManagedObject *state in objects) {
        [results addObject:[self map:state]];
    }
    
    return results;
}

@end
