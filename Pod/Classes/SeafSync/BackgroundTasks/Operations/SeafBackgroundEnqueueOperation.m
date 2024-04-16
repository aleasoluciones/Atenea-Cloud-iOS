/**
 * @file SeafBackgroundEnqueueOperation.m
 * @brief Implementation of SeafBackgroundEnqueueOperation class.
 * @author apps meytel
 * @date 8/11/23
 */

#import "SeafBackgroundEnqueueOperation.h"
#import "SeafSyncronizer.h"
#import "SeafSyncEnqueuerFactory.h"

@interface SeafBackgroundEnqueueOperation()

@property (nonatomic, retain) NSMutableArray<SeafSyncSettings *> *settings;
@property (nonatomic, retain) dispatch_semaphore_t main_semaphore;

@end

@implementation SeafBackgroundEnqueueOperation

/**
 * The main method that is called when the operation is started.
 */
- (void)main {
    if ([self isCancelled]) {
        return;
    }
    
    self.main_semaphore = dispatch_semaphore_create(0);
    self.settings = [self loadSettings];
    if(self.settings.count > 0){
        
        [self enqueueFilesForSetting:[self.settings objectAtIndex:0]];
        
        // Semaphore will be signaled in enqueueFilesForSetting function when all settings are enqueued
        dispatch_semaphore_wait(self.main_semaphore, dispatch_time(DISPATCH_TIME_NOW, 600 * NSEC_PER_SEC));
    }

    if(self.completionBlock){
        self.completionBlock();
    }
}

/**
 * Loads the synchronization settings from all SeafSynchronizer instances.
 *
 * @return An array of SeafSyncSettings objects.
 */
- (NSMutableArray<SeafSyncSettings *> *)loadSettings {
    NSMutableArray<SeafSyncSettings *> *settings = [[NSMutableArray alloc] initWithCapacity:0];
    [[SeafSyncronizer allInstances] enumerateObjectsUsingBlock:^(SeafSyncronizer * _Nonnull syncronizer, NSUInteger idx, BOOL * _Nonnull stop) {
        [syncronizer.settings enumerateObjectsUsingBlock:^(SeafSyncSettings * _Nonnull setting, NSUInteger idx, BOOL * _Nonnull stop) {
            [settings addObject:setting];
        }];
    }];
    return settings;
}

/**
 * Enqueues files for the given synchronization setting.
 *
 * @param setting The SeafSyncSettings object for which files are to be enqueued.
 */
- (void)enqueueFilesForSetting:(SeafSyncSettings *)setting {
    if (setting == nil) {
        dispatch_semaphore_signal(self.main_semaphore);
        return;
    }

    id<SeafEnqueuerProtocol> enqueuer = [SeafSyncEnqueuerFactory getEnqueuerFor:setting.connection settings:setting];
    [enqueuer onEnqueueCompleted:^(BOOL success) {
        [self enqueueFilesForSetting:[self nextSetting:setting]];
    }];
    NSLog(@"#BACKGROUND_TASKS:: SeafBackgroundEnqueueOperation ENQUEUING SETTING: %@", setting.identifier);
    [enqueuer enqueue];
}

/**
 * Returns the next synchronization setting in the array.
 *
 * @param setting The current SeafSyncSettings object.
 * @return The next SeafSyncSettings object in the array, or nil if there are no more settings.
 */
- (SeafSyncSettings *)nextSetting:(SeafSyncSettings *)setting {
    NSInteger index = [self.settings indexOfObject:setting];
    NSInteger nextIndex = index + 1;

    if (nextIndex < [self.settings count]) {
        return [self.settings objectAtIndex:nextIndex];
    }

    return nil;
}

@end

