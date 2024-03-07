//
//  SeafFileFilterBuilder.h
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafConnection.h"
#import "SeafFile.h"
#import "SeafFileProtocol.h"
#import "SeafFileFilterStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafFileFilterBuilder : NSObject

+ (id<SeafFileFilterStrategy>)getFilterForPreview:(SeafConnection * ) connection repoId:(NSString *)repoId;
+ (id<SeafFileFilterStrategy>)getFilterForUpload:(SeafConnection * ) connection;


@end
NS_ASSUME_NONNULL_END

