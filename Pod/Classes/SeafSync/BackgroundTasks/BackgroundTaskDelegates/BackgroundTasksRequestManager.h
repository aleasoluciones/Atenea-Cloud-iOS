//
//  BackgroundTasksRequestManager.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 9/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackgroundTasksRequestManager : NSObject<NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

+ (instancetype)sharedInstance;

- (void) registerTask:(NSURLSessionTask *) task withDelegate:(id<NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>) delegate;


@end

NS_ASSUME_NONNULL_END
