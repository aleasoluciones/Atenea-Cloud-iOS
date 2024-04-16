//
//  iCloudAvailableAssetFilterStrategy.m
//  Pods
//
//  Created by apps meytel on 11/4/24.
//

#import "iCloudAvailableAssetFilterStrategy.h"
#import "SeafSyncItemProtocol.h"
#import "SeafSyncUtils.h"
#import "SeafSyncSettings.h"
#import "Utils.h"

@interface iCloudAvailableAssetFilterStrategy ()
@property SeafSyncSettings *settings;
@end


/**
 Este filtro se usa para evitar que se encolen ficheros que , aunque son visibles en la galería, no están físicamente en la galería pero aparecen por estar en iCloud
 Este filtro lo que hace es comprobar que tengamos este fichero fisicamente en nuestro dispositivo local.
 
 */
@implementation iCloudAvailableAssetFilterStrategy


-(id)initWithSettings:(SeafSyncSettings *)settings{
    self = [super init];
    if(self){
        self.settings = settings;
    }
    
    return self;
}


-(BOOL) meetsCondition:(id<SeafSyncItemProtocol>) itemToEvaluate{
    
    if(itemToEvaluate.itemType == SeafSyncItemTypeAsset){
        PHAsset *asset = [Utils getAssetByIdentifier:itemToEvaluate.identifier];
        if(asset){
            
            
            PHAssetResource *assetResource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];

            bool isLocallyAvailable = [[assetResource valueForKey:@"locallyAvailable"] boolValue];
            bool isCurrent = [[assetResource valueForKey:@"isCurrent"] boolValue];
            
            if (isLocallyAvailable ==FALSE && isCurrent == FALSE){
                bool kk = FALSE;
            }
            
            return ( isLocallyAvailable && isCurrent);
                
        }
    }
    
    return TRUE;
    
}

@end
