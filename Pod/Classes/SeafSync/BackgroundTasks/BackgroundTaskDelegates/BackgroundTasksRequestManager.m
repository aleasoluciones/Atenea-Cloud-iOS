//
//  BackgroundTasksRequestManager.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 9/11/23.
//

#import "BackgroundTasksRequestManager.h"

@interface BackgroundTasksRequestManager()

@property (atomic, retain) NSMutableDictionary *requestsTable;

@end


@implementation BackgroundTasksRequestManager


+ (instancetype)sharedInstance {
    static BackgroundTasksRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.requestsTable = [NSMutableDictionary dictionary];
    });
    return sharedInstance;
}

-(id) getTaskKey:(NSURLSessionTask *) task{
    return [NSString stringWithFormat:@"%lu",(unsigned long)task.hash];
}

- (void) registerTask:(NSURLSessionTask *) task withDelegate:(id<NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>) delegate{
    [self.requestsTable setObject:delegate forKey:[self getTaskKey:task]];
}

-(id<NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>) getTaskDelegate:(NSURLSessionTask *) task{
    id<NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate> delegate =  [self.requestsTable objectForKey:[self getTaskKey:task]];
    return delegate;
}



//MARK: DELEGATE METHODS
-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream * _Nullable))completionHandler{
    
}


-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [[self getTaskDelegate:task] URLSession:session task:task didCompleteWithError:error];
}


-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
   // [[self getTaskDelegate:task] URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}

-(void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
   
}

-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willBeginDelayedRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLSessionDelayedRequestDisposition, NSURLRequest * _Nullable))completionHandler{
  //  [[self getTaskDelegate:task] URLSession:session task:task willBeginDelayedRequest:request completionHandler:completionHandler];
    
}


-(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
  //  [[self getTaskDelegate:task] URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
}


-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    [[self getTaskDelegate:downloadTask] URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
 //   [[self getTaskDelegate:downloadTask] URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
  //  [[self getTaskDelegate:downloadTask] URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
}
@end
