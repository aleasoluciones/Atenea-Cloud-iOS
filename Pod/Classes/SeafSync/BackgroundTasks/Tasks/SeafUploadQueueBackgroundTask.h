//
//  SeafUploadQueueBackgroundTask.h
//  Seafile
//
//  Created by apps meytel on 24/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafBackgroundTaskProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafUploadQueueBackgroundTask :  NSObject<SeafBackgroundTaskProtocol,NSURLSessionDelegate>

@end

NS_ASSUME_NONNULL_END
