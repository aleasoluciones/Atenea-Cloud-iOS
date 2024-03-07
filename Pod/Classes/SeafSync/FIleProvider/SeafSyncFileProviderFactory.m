//
//  SeafSyncGalleryProviderFactory.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 1/9/23.
//

#import "SeafSyncFileProviderFactory.h"
#import "SeafSyncProviderProtocol.h"
#import "SeafSyncFolderProvider.h"
#import "SeafSyncSettings.h"
#import "SeafSyncEnums.h"
#import "SeafSyncGalleryProvider.h"
#import "SeafSyncFilteredProvider.h"
#import "SyncSettingsFilterStrategy.h"
#import "QuotaFilterStrategy.h"
#import "AlreadyUploadedFilterStrategy.h"
#import "PlanFilterStrategy.h"

/**
 * SeafSyncFileProviderFactory
 * @brief A factory class for creating SeafSyncProviderProtocol instances.
 */
@implementation SeafSyncFileProviderFactory

/**
 * Creates an instance of SeafSyncProviderProtocol based on the provided SeafSyncSettings.
 *
 * @param settings The SeafSyncSettings object containing synchronization settings.
 * @return An instance of SeafSyncProviderProtocol.
 */
+ (id<SeafSyncProviderProtocol>)getProviderFor:(SeafSyncSettings * ) settings{
    
    //Default filters
    NSArray *defaultFilters =[self  getDefaultFiltersWith:settings];
    
    switch(settings.sourceType){
            
        case Folder:
            return [[SeafSyncFilteredProvider alloc] initWithProvider:[self createFolderProviderFor:settings] andFilters:defaultFilters];
            
            break;
            
        case Album:
            
            return [[SeafSyncFilteredProvider alloc] initWithProvider:[[SeafSyncGalleryProvider alloc] initWithAlbumName:settings.resourceId] andFilters:defaultFilters];
            
            break;
            
        case Gallery:

            return [[SeafSyncFilteredProvider alloc] initWithProvider:[[SeafSyncGalleryProvider alloc] init] andFilters:defaultFilters];

    }
}

/**
 * Creates an instance of SeafSyncProviderProtocol for a specific folder URL and settings.
 *
 * @param folderURL The NSURL representing the folder's URL.
 * @param settings The SeafSyncSettings object containing synchronization settings.
 * @return An instance of SeafSyncProviderProtocol.
 */
+ (id<SeafSyncProviderProtocol>)getProviderForURL:(NSURL * ) folderURL withSettings:(SeafSyncSettings * ) settings{

    return [[SeafSyncFilteredProvider alloc]
            initWithProvider: [[SeafSyncFolderProvider alloc] initWithFolderURL:folderURL] andFilters:[self  getDefaultFiltersWith:settings]];
}



+(NSArray<id<SeafSyncFileProviderFilterStrategy>> *) getDefaultFiltersWith:(SeafSyncSettings * ) settings{
    
    SyncSettingsFilterStrategy *settingsFilter = [[SyncSettingsFilterStrategy alloc] initWithSettings:settings];
    
    QuotaFilterStrategy *quotaStrategy = [[QuotaFilterStrategy alloc] initWithSettings: settings];
    
    AlreadyUploadedFilterStrategy *alreadyUploaded = [[AlreadyUploadedFilterStrategy alloc] initWithSettings:settings];
    
    PlanFilterStrategy *planStrategy = [[PlanFilterStrategy alloc] initWithSettings:settings];
    
    return @[settingsFilter,quotaStrategy, alreadyUploaded, planStrategy];
}


/**
 * Creates a SeafSyncFolderProvider for a given SeafSyncSettings.
 *
 * @param setting The SeafSyncSettings object containing synchronization settings.
 * @return A SeafSyncFolderProvider instance.
 */
+ (SeafSyncFolderProvider *) createFolderProviderFor:(SeafSyncSettings * )  setting{
    
    BOOL bookmarkIsStale = NO;
    NSError* theError = nil;
    NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:setting.resourceId
                                                   options:NSURLBookmarkResolutionWithoutUI
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&theError];
    
    if (bookmarkIsStale || (theError != nil)) {
        return nil;
    }
    
    return [[SeafSyncFolderProvider alloc] initWithFolderURL:bookmarkURL];
}

@end

