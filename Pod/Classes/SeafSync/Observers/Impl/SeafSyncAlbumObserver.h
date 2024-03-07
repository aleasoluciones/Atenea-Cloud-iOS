//
//  SeafSyncAlbumObserver.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 16/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncObserverProtocol.h"
#import <Photos/Photos.h>
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncAlbumObserver : NSObject<SeafSyncObserverProtocol, PHPhotoLibraryChangeObserver>

- (instancetype)initWithSetting:(SeafSyncSettings *) settings;


@end

NS_ASSUME_NONNULL_END
