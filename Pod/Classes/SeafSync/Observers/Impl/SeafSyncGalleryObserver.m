//
//  SeafSyncGalleryObserver.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import "SeafSyncGalleryObserver.h"
#import <Photos/Photos.h>
#import "SeafSyncAssetsListProvider.h"
#import "SeafSyncGalleryEnqueuer.h"
#import "SeafSyncFilteredProvider.h"
#import "SeafSyncFileProviderFactory.h"


/**
 This class observes changes in the photo gallery using the Photos framework.
 */
@interface SeafSyncGalleryObserver ()

/**
 A callback block to be executed when changes in the photo library are detected.
 */
@property (nonatomic) SeafSyncObserverProtocolCallback callback;
@property (atomic, strong) PHFetchResult *lastFetchResult;
@property (nonatomic,retain) SeafSyncSettings *settings;

@end

@implementation SeafSyncGalleryObserver

/**
 Initializes a new instance of SeafSyncGalleryObserver.
 @return An initialized instance of SeafSyncGalleryObserver.
 */
- (instancetype)initWithSetting:(SeafSyncSettings *) settings{
    self = [super init];
    if (self) {
        self.settings = settings;
        //Sets the current fetch stat to check later when photoLibraryDidChange runs
        self.lastFetchResult = [self currentFetchResult];
    }
    return self;
}

- (PHFetchResult *)currentFetchResult {
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    
    // Image & Video
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d || mediaType == %d", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
    
    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
    return assetsFetchResult;
}

/**
 Returns an identifier for the observer.
 @return An identifier string.
 */
- (id)observerIdentifier {
    return @"gallery";
}

/**
 Starts observing changes in the photo library.
 @param callback A callback block to be executed when changes are detected.
 */
- (void)start:(nullable SeafSyncObserverProtocolCallback)callback {
    self.callback = callback;
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

/**
 Stops observing changes in the photo library.
 */
- (void)stop {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

/**
 Callback method invoked when the photo library changes.
 @param changeInstance The instance containing information about the changes.
 */
- (void)photoLibraryDidChange:(nonnull PHChange *)changeInstance {

    
    //Get changes from last fetch
    PHFetchResultChangeDetails *detailedChanges = [changeInstance changeDetailsForFetchResult:self.lastFetchResult];
    
    //Get the new items
    NSArray<PHAsset *> *insertedAssets = [detailedChanges insertedObjects];
    
    if([insertedAssets count] > 0){
        [self enqueueNewAssets:insertedAssets];
    }
    
    //TODO: Revisar esto de abajo comentado. Al setear de nuevo self.lastFetchResult = [self currentFetchResult], los siguientes cambios si llegan varios no se toman en cuenta
    //Comentamos esto para que los cambios se comprueben contra la instancia del constructor
    //Set last fetchResult with current status
    //self.lastFetchResult = detailedChanges.fetchResultBeforeChanges;
    
    
    //DO NOT CALL THE 'CALLBACK'. READ THIS:
    //Yes, we do not call the callback because we are already handling the change.
    //If we call the "callback" the syncronizer will run the entire gallery.
    
    // ==> self.callback(self.lastChange);

}

/**
  Enqueues new `PHAsset` objects for synchronization.
  This method adds the specified array of `PHAsset` objects to the synchronization queue for processing.
  @param assets An array of `PHAsset` objects representing the assets to be synchronized.
 */

-(void) enqueueNewAssets:(NSArray<PHAsset *> *) assets {
    
    //Provider
    SeafSyncAssetsListProvider *provider = [[SeafSyncAssetsListProvider alloc] initWithPHAssets:assets];
    
    //Filter provider
    SeafSyncFilteredProvider *filteredProvider = [[SeafSyncFilteredProvider alloc] initWithProvider:provider andFilters:[SeafSyncFileProviderFactory getDefaultFiltersWith:self.settings]];
    
    //Enquer
    SeafSyncGalleryEnqueuer *enqueuer = [[SeafSyncGalleryEnqueuer alloc]
                                         init:self.settings
                                         connection:self.settings.connection
                                         andFileProvider:filteredProvider];
    //Enqueue!
    [enqueuer enqueue];
}



@end
