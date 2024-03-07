//
//  SyncSettingsFilterStrategy.m
//  Seafile
//
//  Created by apps Javier Godoy (javigodoy@meytel.net) on 10/10/23.
//

#import "SyncSettingsFilterStrategy.h"
#import "SeafSyncItemProtocol.h"
#import "SeafSyncUtils.h"
#import "SeafSyncSettings.h"

@interface SyncSettingsFilterStrategy ()
@property SeafSyncSettings *settings;
@end

@implementation SyncSettingsFilterStrategy

/**
 * @brief Initializes a new instance of the filter strategy with the specified synchronization settings.
 *
 * @param settings The synchronization settings to be used by the filter strategy.
 * @return An initialized instance of the filter strategy.
 */
-(id)initWithSettings:(SeafSyncSettings *)settings{
    self = [super init];
    if(self){
        self.settings = settings;
    }
    
    return self;
}

/**
 * @brief Determines whether the provided item meets the specified conditions based on synchronization settings.
 *
 * @param itemToEvaluate The item to evaluate against the conditions.
 * @return YES if the item meets the conditions, NO otherwise.
 */
-(BOOL) meetsCondition:(id<SeafSyncItemProtocol>) itemToEvaluate{
    
    // If no video upload is allowed and this item is a video => out!
    if (FALSE == self.settings.uploadVideos && itemToEvaluate.fileType == SeafSyncItemFileTypeVideo) {
        return FALSE;
    }
    
    // If the mode is incremental, only return items newer than the creation setting date
    if (self.settings.mode == Incremental && ([SeafSyncUtils date:itemToEvaluate.creationDate isPreviousThan:self.settings.creationDate] && [SeafSyncUtils date:itemToEvaluate.addedToDirectoryDate isPreviousThan:self.settings.creationDate])) {
        return FALSE;
    }
    
    return TRUE;
    
}

@end
