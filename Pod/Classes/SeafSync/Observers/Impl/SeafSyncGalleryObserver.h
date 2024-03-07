//
//  SeafSyncGalleryObserver.h
//  Seafile
//
// Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncObserverProtocol.h"
#import <Photos/Photos.h>
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncGalleryObserver : NSObject<SeafSyncObserverProtocol, PHPhotoLibraryChangeObserver>

- (instancetype)initWithSetting:(SeafSyncSettings *) settings;

@end

NS_ASSUME_NONNULL_END
