/**
 * @file BackgroundUploadLinkDelegate.m
 * @brief Implementation of BackgroundUploadLinkDelegate class.
 * @author apps meytel
 * @date 9/11/23
 */

#import "BackgroundUploadLinkDelegate.h"
#import <Foundation/Foundation.h>

@interface BackgroundUploadLinkDelegate()
@property SeafUploadFile *uploadFile;
@property BackgroundUploadLinkDelegateReadyBlock callback;
@end

@implementation BackgroundUploadLinkDelegate

/**
 * Initializes an instance of BackgroundUploadLinkDelegate with the given upload file.
 *
 * @param uploadFile The SeafUploadFile object to associate with the delegate.
 * @return An initialized instance of BackgroundUploadLinkDelegate.
 */
- (id)initWithUploadFile:(SeafUploadFile *)uploadFile {
    self = [super init];
    if (self) {
        self.uploadFile = uploadFile;
    }
    return self;
}

-(void) onUploadLinkReady:(BackgroundUploadLinkDelegateReadyBlock) callback{
    self.callback = callback;
}

/**
 * This method is called when the task is completed with an error.
 *
 * @param session The session containing the task.
 * @param task The task that completed.
 * @param error An error object that indicates why the task failed.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(error){
        NSLog(@"BackgroundUploadLinkDelegate didCompleteWithError %@", error.localizedDescription);
        NSLog(@"BackgroundUploadLinkDelegate didCompleteWithError %@", error.localizedFailureReason);
        return;
    }
    
    NSLog(@"TASK FORL 'UPLOAD LINK URL' FOR FILE %@ COMPLETED SUCCESSFULLY!!!", [[NSURL fileURLWithPath:self.uploadFile.lpath] lastPathComponent]);
}

/**
 * This method is called when the download task is completed.
 *
 * @param session The session containing the task.
 * @param downloadTask The download task that finished.
 * @param location A file URL for the temporary file.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *uploadURL = [self getUploadURL:location];
    
    self.callback(self.uploadFile, uploadURL);
    
    [self removeTemporalFile:location];
}

/**
 * Retrieves the upload URL from the temporary file at the specified location.
 *
 * @param location The file URL for the temporary file.
 * @return The upload URL extracted from the file contents.
 */
- (NSString *)getUploadURL:(NSURL *)location {
    NSError *error = nil;
    NSData *fileData = [NSData dataWithContentsOfURL:location options:0 error:&error];

    if (!error) {
        NSString *fileContents = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        if (fileContents) {
            return  [fileContents stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
    }
    return nil;
}

/**
 * Removes the temporary file at the specified location.
 *
 * @param location The file URL for the temporary file to be removed.
 */
- (void)removeTemporalFile:(NSURL *)location {
    [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
}

@end
