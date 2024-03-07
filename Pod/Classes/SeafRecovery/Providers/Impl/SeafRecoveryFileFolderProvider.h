//
//  SeafRecoveryFileFolderProvider.h
//  Seafile
//
//  Created by apps meytel on 18/12/23.
//

#import <Foundation/Foundation.h>
#import "SeafRecoveryItemsProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafRecoveryFileFolderProvider : NSObject<SeafRecoveryItemsProvider>

-(id) initWithConnection:(SeafConnection *) connection andRepository:(NSString *) repositoryId andPath:(NSString *) path;

@end

NS_ASSUME_NONNULL_END
