//
//  SeafAssetFileAdapter.m
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafAssetFileAdapter.h"
#import "SeafUploadFile.h"
#import "SeafFile.h"

@implementation SeafAssetFileAdapter

- (instancetype)initWithPhotoAsset:(SeafSyncAssetItem *)photoAsset {
    self = [super init];
    if (self) {
        self.photoAsset = photoAsset;
    }
    return self;
}

- (NSString *)fileName {
   return self.photoAsset.fileName;
}

- (long long)sizeInBytes{
    return self.photoAsset.sizeInBytes;
}

- (NSURL *)path {
    return self.photoAsset.path;
}

@synthesize fileName;

@synthesize creationDate;

@synthesize identifier;

@synthesize path;

@synthesize sizeInBytes;

@synthesize extension;

@end
