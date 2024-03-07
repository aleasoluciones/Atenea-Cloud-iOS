//
//  NSError+SeafFileProvierError.h
//  SeafFileProvider
//
//  Created by three on 2018/6/13.
//  Copyright © 2018年 Seafile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SeafFileFilterStrategy.h"

@interface NSError (SeafFileProvierError)

+ (NSError *)fileProvierErrorServerUnreachable;
+ (NSError *)fileProvierErrorNotAuthenticated;
+ (NSError *)fileProvierErrorNoSuchItem;
+ (NSError *)fileProvierErrorPageExpired;
+ (NSError *)fileProvierErrorFilenameCollision;
+ (NSError *)fileProvierErrorInsufficientQuota;
+ (NSError *)fileProvierErrorNoAccount;
+ (NSError *)fileProvierErrorFeatureUnsupported;
+(NSError *)fileProvierErrorFeatureUnsupportedPlan;
+(NSError *)fileProvierErrorFeatureUnsupportedPlanFilter:(id<SeafFileFilterStrategy>)filterStrategy;
+ (NSError *)fileProviderErrorRenameFileExtension;
@end
