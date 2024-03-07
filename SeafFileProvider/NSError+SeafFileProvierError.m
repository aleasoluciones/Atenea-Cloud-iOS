//
//  NSError+SeafFileProvierError.m
//  SeafFileProvider
//
//  Created by three on 2018/6/13.
//  Copyright © 2018年 Seafile. All rights reserved.
//

#import "NSError+SeafFileProvierError.h"
#import <FileProvider/FileProvider.h>
#import "Utils.h"
#import "Support4k.h"
#import "SupportExtension.h"
#import "SeafUploadSize.h"
#import "SeafEnoughQuota.h"
#import "Support4kPreview.h"


@implementation NSError (SeafFileProvierError)

+ (NSError *)fileProvierErrorServerUnreachable {
    if (@available(iOS 11.0, *)) {
        return [[NSError alloc] initWithDomain:NSFileProviderErrorDomain code:NSFileProviderErrorServerUnreachable userInfo:nil];
    } else {
        return [Utils defaultError];
    }
}

+ (NSError *)fileProvierErrorNotAuthenticated {
    if (@available(iOS 11.0, *)) {
        return [[NSError alloc] initWithDomain:NSFileProviderErrorDomain code:NSFileProviderErrorNotAuthenticated userInfo:@{@"reason" : @"notAuthenticated"}];
    } else {
        return [Utils defaultError];
    }
}

+ (NSError *)fileProvierErrorNoAccount {
    if (@available(iOS 11.0, *)) {
        return [[NSError alloc] initWithDomain:NSFileProviderErrorDomain code:NSFileProviderErrorNotAuthenticated userInfo:@{@"reason" : @"noAccount"}];
    } else {
        return [Utils defaultError];
    }
}

+ (NSError *)fileProvierErrorNoSuchItem {
    if (@available(iOS 11.0, *)) {
        return [[NSError alloc] initWithDomain:NSFileProviderErrorDomain code:NSFileProviderErrorNoSuchItem userInfo:nil];
    } else {
        return [Utils defaultError];
    }
}

+ (NSError *)fileProvierErrorPageExpired {
    if (@available(iOS 11.0, *)) {
        return [[NSError alloc] initWithDomain:NSFileProviderErrorDomain code:NSFileProviderErrorPageExpired userInfo:nil];
    } else {
        return [Utils defaultError];
    }
}

+ (NSError *)fileProvierErrorFilenameCollision {
    if (@available(iOS 11.0, *)) {
        return [[NSError alloc] initWithDomain:NSFileProviderErrorDomain code:NSFileProviderErrorFilenameCollision userInfo:nil];
    } else {
        return [Utils defaultError];
    }
}

+ (NSError *)fileProvierErrorInsufficientQuota {
    if (@available(iOS 11.0, *)) {
        return [[NSError alloc] initWithDomain:NSFileProviderErrorDomain code:NSFileProviderErrorInsufficientQuota userInfo:nil];
    } else {
        return [Utils defaultError];
    }
}

+ (NSError *)fileProvierErrorFeatureUnsupported {
    return [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{}];
}


+ (NSError *)fileProvierErrorFeatureUnsupportedPlan {
    return [NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{@"reason" : @"This file is not supported with your current plan"}];
}


+(NSError *)fileProvierErrorFeatureUnsupportedPlanFilter:(id<SeafFileFilterStrategy>)filterStrategy{
    
    NSString *message = nil;
    
    if ([filterStrategy isKindOfClass:[Support4k class]]  || [filterStrategy isKindOfClass:[Support4kPreview class]]) {
        message = NSLocalizedString(@"ACCOUNT_4K_RESTRICTED_MSG_SIMPLE", @"Seafile");
    } else if ([filterStrategy isKindOfClass:[SupportExtension class]]) {
        message = NSLocalizedString(@"ACCOUNT_EXTENSION_RESTRICTED_MSG_SIMPLE", @"Seafile");
    } else if ([filterStrategy isKindOfClass:[SeafUploadSize class]]) {
        message = NSLocalizedString(@"ACCOUNT_UPLOAD_SIZE_LIMIT_MSG_SIMPLE", @"Seafile");
    } else if ([filterStrategy isKindOfClass:[SeafEnoughQuota class]]) {
        message = NSLocalizedString(@"ACCOUNT_QUOTA_EXCEEDED_MSG_SIMPLE", @"Seafile");
    }
    
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey:  NSLocalizedString(@"Warning", nil),
        NSLocalizedFailureReasonErrorKey:  message,
    };
    
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:1001
                                     userInfo:userInfo];
    
    return error;
}


+ (NSError *)fileProviderErrorRenameFileExtension {
    
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey:  NSLocalizedString(@"Warning", nil),
        NSLocalizedFailureReasonErrorKey:  @"Rename file extension is not allowed",
    };
    
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:1001
                                     userInfo:userInfo];
    
    return error;
    
    
}


@end
