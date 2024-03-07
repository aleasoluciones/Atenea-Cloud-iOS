//
//  SeafBackgroundUploaderOperation.h
//  Seafile
//
//  Created by apps meytel on 8/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafBackgroundUploaderOperation : NSOperation

-(id) initWithSetting:(SeafSyncSettings *) settings andSession:(NSURLSession *) session;
@end

NS_ASSUME_NONNULL_END
