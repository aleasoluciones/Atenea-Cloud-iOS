//
//  SeafSyncAlbumObserver.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 16/11/23.
//

#import "SeafSyncAlbumObserver.h"
#import <Photos/Photos.h>
#import "SeafSyncAssetsListProvider.h"
#import "SeafSyncGalleryEnqueuer.h"
#import "SeafSyncFilteredProvider.h"

/**
 This class observes changes in the photo gallery using the Photos framework.
 */
@interface SeafSyncAlbumObserver ()

/**
 A callback block to be executed when changes in the photo library are detected.
 */
@property (nonatomic) SeafSyncObserverProtocolCallback callback;
@property (nonatomic,retain) SeafSyncSettings *settings;
@property (nonatomic,retain) PHAssetCollection *album;
@property (atomic, strong) PHFetchResult *lastFetchResult;

@end

@implementation SeafSyncAlbumObserver


/**
 Initializes a new instance of SeafSyncGalleryObserver.
 @return An initialized instance of SeafSyncGalleryObserver.
 */
- (instancetype)initWithSetting:(SeafSyncSettings *) settings{
    self = [super init];
    if (self) {
        self.settings = settings;
        self.album = [self findAlbum];
        //Sets the current fetch stat to check later when photoLibraryDidChange runs
        self.lastFetchResult = [PHAsset fetchAssetsInAssetCollection:self.album options:nil];
    }
    return self;
}


/**
 Returns an identifier for the observer.
 @return An identifier string.
 */
- (id)observerIdentifier {
    return @"album";
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
 
    
    
    
    //If album exists, we compare the last FetchResult (or the initial setted in the constructor) with
    //the assets returned in "objectAfterChanges"
    //If the last Fetch do not contains items, we assume they are new items
    //Finaly, we set the lastFetchResult with 'objectAfterChanges' to store the last state

    if(self.album){
        
        // Check for changes in the album
        PHObjectChangeDetails *changes = [changeInstance changeDetailsForObject:self.album];
        if (changes) {
            // Access inserted objects using fetchResultAfterChanges
            PHFetchResult *afterChanges = [PHAsset fetchAssetsInAssetCollection:changes.objectAfterChanges options:nil];
            
            // Determine inserted objects by comparing before and after changes
            NSMutableArray *insertedAssets = [NSMutableArray array];
            for (PHAsset *asset in afterChanges) {
                if (![self.lastFetchResult containsObject:asset]) {
                    [insertedAssets addObject:asset];
                }
            }
            
            
            if([insertedAssets count] > 0){
                [self enqueueNewAssets:insertedAssets];
            }
            
            //TODO: This line is commented to check every change since constructor creation
            //If uncomment this line, the changes will be check against the las "afterChanges"
            //and some photos coulb be lost
            //Update last fetch
            //self.lastFetchResult = afterChanges;
        }
        
       
        
    }

    //DO NOT CALL THE 'CALLBACK'. READ THIS:
    //Yes, we do not call the callback because we are already handling the change.
    //If we call the "callback" the syncronizer will run the entire gallery.
    
    // ==> self.callback(self.lastChange);
    
}


/**
 * Finds a specific album by name.
 * @return The PHAssetCollection representing the found album.
 */
- (PHAssetCollection *)findAlbum {
    // All albums
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                              subtype:PHAssetCollectionSubtypeAny
                                                                                              options:nil];
    
    // Find album by name
    PHAssetCollection *targetCollection = nil;
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:self.settings.resourceId]) {
            targetCollection = collection;
            break;
        }
    }

    return targetCollection;
}

/**
 Enqueues new `PHAsset` objects for synchronization.
 This method adds the specified array of `PHAsset` objects to the synchronization queue for processing.
 @param assets An array of `PHAsset` objects representing the assets to be synchronized.
 */

-(void) enqueueNewAssets:(NSArray<PHAsset *> *) assets {
    
    //Provider
    SeafSyncAssetsListProvider *provider = [[SeafSyncAssetsListProvider alloc] initWithPHAssets:assets];
    
    //Enquer
    SeafSyncGalleryEnqueuer *enqueuer = [[SeafSyncGalleryEnqueuer alloc]
                                         init:self.settings
                                         connection:self.settings.connection
                                         andFileProvider:provider];
    //Enqueue!
    [enqueuer enqueue];
}



@end
