//
//  SeafRecoveryRepositoryProvider.h
//  Seafile
//
//  Created by apps meytel on 18/12/23.
//

#import <Foundation/Foundation.h>
#import "SeafRecoveryItemsProvider.h"


NS_ASSUME_NONNULL_BEGIN

@interface SeafRecoveryRepositoryProvider : NSObject<SeafRecoveryItemsProvider>

-(id) initWithConnection:(SeafConnection *) connection;

@end

NS_ASSUME_NONNULL_END
