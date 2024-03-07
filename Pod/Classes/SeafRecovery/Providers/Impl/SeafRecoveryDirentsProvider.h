//
//  SeafRecoveryDirentsProvider.h
//  Seafile
//
//  Created by apps meytel on 18/12/23.
//

#import <Foundation/Foundation.h>
#import "SeafRecoveryItemsProvider.h"
#import "SeafRecoveryItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafRecoveryDirentsProvider : NSObject<SeafRecoveryItemsProvider>

-(id) initWithConnection:(SeafConnection *) connection andParentDeletion:(id<SeafRecoveryItem>) parentDeletion;

@end

NS_ASSUME_NONNULL_END
