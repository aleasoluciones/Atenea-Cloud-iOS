//
//  SeafAssetFileAdapter.h
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//
#import <Foundation/Foundation.h>
#import "SeafFileProtocol.h"
#import "SeafUploadFile.h"
#import "SeafFile.h"
#import "SeafSyncAssetItem.h"



@interface SeafAssetFileAdapter : NSObject <SeafFileProtocol>
@property (nonatomic, strong) SeafSyncAssetItem *photoAsset;
- (instancetype)initWithPhotoAsset:(SeafSyncAssetItem *)photoAsset;


@end
