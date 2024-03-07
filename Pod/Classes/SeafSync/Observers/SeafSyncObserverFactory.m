//
//  SeafSyncObserverFactory.m
//  Seafile
//
// Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import "SeafSyncObserverFactory.h"
#import "SeafSyncSettingFolderObserver.h"
#import "SeafSyncGalleryObserver.h"
#import "SeafSyncBlindObserver.h"
#import "SeafSyncAlbumObserver.h"

/**
 * @brief The SeafSyncObserverFactory class.
 *
 * This factory class creates instances of classes conforming to the SeafSyncObserverProtocol based on the provided SeafSyncSettings.
 */
@implementation SeafSyncObserverFactory

/**
 * @brief Creates a synchronization observer for the given SeafSyncSettings.
 *
 * @param setting The SeafSyncSettings for which to create an observer.
 * @return An object conforming to the SeafSyncObserverProtocol.
 */
+ (id<SeafSyncObserverProtocol>)createFor:(SeafSyncSettings *)setting {
 
    switch (setting.sourceType) {
        case Folder:
            return [[SeafSyncSettingFolderObserver alloc] initWith:setting];
            break;
            
        case Album:
            return [[SeafSyncAlbumObserver alloc] initWithSetting:setting];
            break;
        case Gallery:
            return [[SeafSyncGalleryObserver alloc] initWithSetting:setting];
            break;
            
        default:
            return [[SeafSyncBlindObserver alloc] init];
    }
}

@end

