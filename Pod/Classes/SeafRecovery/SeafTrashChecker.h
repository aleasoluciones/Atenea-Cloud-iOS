//
//  SeafTrashChecker.h
//  Seafile
//
//  Created by apps meytel on 3/1/24.
//

#import <Foundation/Foundation.h>
#import "SeafConnection.h"
#import "SeafRecoveryItem.h"
#import "SeafRecoveryItemsProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafTrashChecker : NSObject

/**
 *  Initializes a SeafTrashChecker object with a connection.
 *  @param provider The SeafRecoveryItemsProvider implementation
 *  @return A SeafTrashChecker object.
 */
- (id) initWithProvider:(id<SeafRecoveryItemsProvider>) provider;


- (void) existsInTrash:(NSString *) path callback:(void (^ _Nullable)(BOOL exists))callback;


- (void) existsAnyInTrash:(NSArray<NSString *> *) paths callback:(void (^ _Nullable)(BOOL exists))callback;

@end

NS_ASSUME_NONNULL_END
