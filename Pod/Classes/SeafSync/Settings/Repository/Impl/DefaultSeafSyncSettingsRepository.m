/**
 * @file DefaultSeafSyncSettingsRepository.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the DefaultSeafSyncSettingsRepository class.
 *
 * This file contains the implementation of the DefaultSeafSyncSettingsRepository class, which provides a default implementation of the SeafSyncSettingsRepository protocol.
 */

#import "DefaultSeafSyncSettingsRepository.h"
#import "SeafStorage.h"

@interface DefaultSeafSyncSettingsRepository()

@property (nonatomic, strong) NSMutableArray<SeafSyncSettings *> *settings; /**< The array of SeafSyncSettings stored in the repository. */
@property (nonatomic, strong)NSString *storageKey; /**< The key used for storage. */
@property (nonatomic, strong)NSString *storageKeyTemplate; /**< The template for generating storage keys. */

/**
 * Reloads all settings from storage.
 */
- (void)reload;

/**
 * Saves the settings to SeafStorage.
 */
- (void)save;

@end

@implementation DefaultSeafSyncSettingsRepository

/**
 * Initializes a DefaultSeafSyncSettingsRepository with a storage key.
 *
 * @param key The key associated with the repository used for storage.
 * @return An instance of DefaultSeafSyncSettingsRepository.
 */
- (id)initWithStorageKey:(NSString *)key{
    self = [super init];
    if(self){
        self.storageKey = key;
        self.storageKeyTemplate = @"sync_settings_for_%@";
        
        [self all];
    }
    return self;
}

/**
 * Retrieves all SeafSyncSettings from the repository.
 *
 * @return An array containing all SeafSyncSettings stored in the repository.
 */
- (NSArray<SeafSyncSettings *> *)all{
    if(self.settings != nil){
        return self.settings;
    }
    
    self.settings = [self loadSettingsFromStorage];
    
    return self.settings;
}


/**
 * Retrieves filtered SeafSyncSettings from the repository.
 *
 * @return An array containing all SeafSyncSettings stored in the repository.
 */
- (NSArray<SeafSyncSettings *> *)filter:(NSPredicate *) predicate{
    return [[self all] filteredArrayUsingPredicate:predicate];
}



/**
 * Load stored settings from SeafStorage with the given key in constructor.
 *
 * @return An array containing SeafSyncSettings loaded from storage.
 */
- (NSMutableArray<SeafSyncSettings *> *)loadSettingsFromStorage{
    NSMutableArray<SeafSyncSettings *> *settings = [NSKeyedUnarchiver unarchiveObjectWithData:[SeafStorage.sharedObject objectForKey:[NSString stringWithFormat:self.storageKeyTemplate, self.storageKey]]];
    
    //If no key exists, initialize settings array
    if(settings == nil){
        settings = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return settings;
}

/**
 * Inserts a new SeafSyncSettings into the repository.
 *
 * @param setting The SeafSyncSettings to insert into the repository.
 */
- (void)insert:(SeafSyncSettings *)setting{
    [self remove:setting];
    [self.settings addObject:setting];
    [self save];
}

/**
 * Updates an existing SeafSyncSettings in the repository.
 *
 * @param setting The SeafSyncSettings to update in the repository.
 */
- (void)update:(SeafSyncSettings *)setting{
    [self insert:setting];
}

/**
 * Removes a SeafSyncSettings item from the repository.
 *
 * @param setting The SeafSyncSettings to remove from the repository.
 */
- (void)remove:(SeafSyncSettings *)setting{
    
    SeafSyncSettings * settingToRemove = [self findById:setting.identifier];
    
    if(settingToRemove){
        [self.settings removeObject:settingToRemove];
        [self save];
    }
}


/**
 * Removes all SeafSyncSettings items from the repository.
 */
- (void)clear{
    [self.settings removeAllObjects];
    [self save];
}

/**
 * Stores the settings in SeafStorage.
 */
- (void)save{
    [SeafStorage.sharedObject setObject:[NSKeyedArchiver archivedDataWithRootObject:self.settings] forKey:[NSString stringWithFormat:self.storageKeyTemplate, self.storageKey]];
}

/**
 * Force reload all settings.
 */
- (void)reload{
    self.settings = nil;
    [self all];
}

-(SeafSyncSettings *) findById:(NSString *) settingId{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafSyncSettings *evaluatedSetting, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedSetting.identifier isEqualToString:settingId];
    }];
     
    return [[[self all] filteredArrayUsingPredicate:predicate] firstObject];
    
}

@end

