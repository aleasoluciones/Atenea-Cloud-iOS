//
//  SeafPermissionManager.m
//  Seafile
//
//  Created by apps meytel on 20/11/23.
//

#import "SeafPermissionManager.h"
#import "SeafPermissibleProtocol.h"
#import "SeafPermission.h"

@implementation SeafPermissionManager

+ (instancetype)sharedInstance {
    static SeafPermissionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


-(BOOL) permissible:(id<SeafPermissibleProtocol>) permissible hasPermission:(NSString *) permission{
    return [permissible.permissions containsString:permission];
}

-(BOOL) canRead:(id<SeafPermissibleProtocol>) permissible{
    return [self permissible:permissible hasPermission:SEAF_READ_PERMISSION];
}

-(BOOL) canWrite:(id<SeafPermissibleProtocol>) permissible{
    return [self permissible:permissible hasPermission:SEAF_WRITE_PERMISSION];
}

-(NSArray *) getPermissions:(id<SeafPermissibleProtocol>) permissible{
    NSMutableArray *permissions = [[NSMutableArray alloc] init];
    [SEAF_PERMISSIONS enumerateObjectsUsingBlock:^(id  _Nonnull permission, NSUInteger idx, BOOL * _Nonnull stop) {
        if([self permissible:permissible hasPermission:permission]){
            [permissions addObject:permission];
        }
    }];
    return permissions;
}


@end
