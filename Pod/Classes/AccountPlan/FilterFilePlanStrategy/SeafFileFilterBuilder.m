//
//  SeafFileFilterBuilder.m
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafFileProtocol.h"
#import "SeafFileFilterBuilder.h"
#import "SeafConnection+UserPlan.h"
#import "SupportExtension.h"
#import "Support4k.h"
#import "SeafUploadSize.h"
#import "SeafFile.h"
#import "SeafCompositeFilter.h"
#import "SeafAssetFileAdapter.h"
#import "SeafEnoughQuota.h"
#import "Support4kPreview.h"

@implementation SeafFileFilterBuilder : NSObject

/**
 Returns a filter strategy for upload.

 @param connection The SeafConnection object.
 @return An object conforming to the SeafFileFilterStrategy protocol.
 */
+ (id<SeafFileFilterStrategy>)getFilterForUpload:(SeafConnection *)connection {
    NSArray *defaultFilters = [self getUploadFiltersWith:connection];
    return [[SeafCompositeFilter alloc] initWithFilters:defaultFilters];
}

/**
 Returns a filter strategy for preview.

 @param connection The SeafConnection object.
 @param repoId The repository ID.
 @return An object conforming to the SeafFileFilterStrategy protocol.
 */
+ (id<SeafFileFilterStrategy>)getFilterForPreview:(SeafConnection *)connection repoId:(NSString *)repoId {
    NSArray *defaultFilters = [self getPreviewFiltersWith:connection repoId:repoId];
    return [[SeafCompositeFilter alloc] initWithFilters:defaultFilters];
}

/**
 Gets the SeafPlanUser object for the given connection.

 @param connection The SeafConnection object.
 @return A SeafPlanUser object.
 */
+ (SeafPlanUser *)getPlan:(SeafConnection *)connection {
    return connection.getPlan;
}

/**
 Returns an array of filter strategies for upload.

 @param connection The SeafConnection object.
 @return An array of objects conforming to the SeafFileFilterStrategy protocol.
 */
+ (NSArray<id<SeafFileFilterStrategy>> *)getUploadFiltersWith:(SeafConnection *)connection {
    SeafEnoughQuota *seafEnoughQuota = [[SeafEnoughQuota alloc] initWithConnection:connection];
    SupportExtension *supportExt = [[SupportExtension alloc] initWithPlan:[self getPlan:connection]];
    SeafUploadSize *uploadSize = [[SeafUploadSize alloc] initWithPlan:[self getPlan:connection]];
    Support4k *support4k = [[Support4k alloc] initWithPlan:[self getPlan:connection]];
    return @[support4k, seafEnoughQuota, supportExt, uploadSize];
}

/**
 Returns an array of filter strategies for preview.

 @param connection The SeafConnection object.
 @param repoId The repository ID.
 @return An array of objects conforming to the SeafFileFilterStrategy protocol.
 */
+ (NSArray<id<SeafFileFilterStrategy>> *)getPreviewFiltersWith:(SeafConnection *)connection repoId:(NSString *)repoId {
    SupportExtension *supportExt = [[SupportExtension alloc] initWithPlan:[self getPlan:connection]];
    SeafUploadSize *uploadSize = [[SeafUploadSize alloc] initWithPlan:[self getPlan:connection]];
    Support4kPreview *support4kpreview = [[Support4kPreview alloc] initWithPlan:connection repoId:repoId];
    return @[supportExt, uploadSize, support4kpreview];
}


@end
