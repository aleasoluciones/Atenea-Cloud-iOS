//
//  SeafSyncTreeChangeDetector.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 22/9/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncTree.h"
#import "SeafSyncTreeProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncTreeChangeDetector : NSObject

-(SeafSyncTree *) changes:(SeafSyncTree *) tree;

@end

NS_ASSUME_NONNULL_END
