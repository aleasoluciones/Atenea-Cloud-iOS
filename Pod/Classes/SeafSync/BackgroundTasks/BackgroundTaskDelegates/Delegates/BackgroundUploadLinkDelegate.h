//
//  BackgroundUploadLinkDelegate.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 9/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafUploadFile.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BackgroundUploadLinkDelegateReadyBlock)(SeafUploadFile *uploadFile, NSString *uploadLink);

@interface BackgroundUploadLinkDelegate : NSObject<NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

-(id) initWithUploadFile:(SeafUploadFile *) uploadFile;


-(void) onUploadLinkReady:(BackgroundUploadLinkDelegateReadyBlock) callback;

@end

NS_ASSUME_NONNULL_END
