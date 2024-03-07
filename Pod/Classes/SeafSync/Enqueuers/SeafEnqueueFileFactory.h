//
//  SeafEnqueueFileFactory.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 3/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncItemProtocol.h"
#import "SeafUploadFile.h"

NS_ASSUME_NONNULL_BEGIN

/// Factory class for creating SeafUploadFile instances.
@interface SeafEnqueueFileFactory : NSObject

/// Creates a SeafUploadFile instance from a SeafSyncItemProtocol.
/// @param seafSyncItem The SeafSyncItemProtocol instance.
/// @return A SeafUploadFile instance.
+ (SeafUploadFile *)createFrom:(id<SeafSyncItemProtocol>)seafSyncItem;

/// Creates a SeafUploadFile instance from a file URL.
/// @param fileURL The URL of the file.
/// @return A SeafUploadFile instance.
+ (SeafUploadFile *)createFromURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
