//
//  SeafBackgroundExpireOperation.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 13/11/23.
//

#import "SeafBackgroundExpireOperation.h"
#import "SeafSyncronizer.h"
#import "SeafSyncExpirationManager.h"

@interface SeafBackgroundExpireOperation()

@end


@implementation SeafBackgroundExpireOperation

/**
 * The main method that is called when the operation is started.
 */
- (void)main {
    if ([self isCancelled]) {   return;  }
    
    [[self loadSettings]  enumerateObjectsUsingBlock:^(SeafSyncSettings *setting, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SeafSyncExpirationManager sharedInstance] run:setting] ;
    }];
    
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

@end
