#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "Support4kPreview.h"
#import "SeafFile.h"
#import "SeafConnection+UserPlan.h"
#import <AVFoundation/AVFoundation.h>
#import "Debug.h"
#import "ExtentedString.h"

/**
 * Support4kPreview Class
 */
@interface Support4kPreview ()

@property SeafConnection *connection;
@property SeafPlanUser *planUser;
@property NSString *repoId;
@property NSString *url;
@property (strong, nonatomic) AVPlayer *player;
@property dispatch_semaphore_t semaphore;

@end

@implementation Support4kPreview

/**
 * Initialize Support4kPreview with a SeafConnection and repoId.
 * @param connection The SeafConnection instance.
 * @param repoId The repository ID.
 * @return An initialized Support4kPreview instance.
 */
- (id)initWithPlan:(SeafConnection *)connection repoId:(NSString *)repoId {
    self = [super init];
    if (self) {
        self.connection = connection;
        self.planUser = [self.connection getPlan];
        self.repoId = repoId;
        self.semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

/**
 * Check if the condition is met for the provided item.
 * @param itemToEvaluate An object conforming to SeafFileProtocol.
 * @return YES if the condition is met, NO otherwise.
 */
- (BOOL)meetsCondition:(id<SeafFileProtocol>)itemToEvaluate {
    //Plan supports 4k
    if (self.planUser.support4k) return true;
    
    //No video (check extension)
    if (![self isVideoFile:itemToEvaluate.path]) return true;
    
    __block BOOL is4K = NO;
    
    [self createRequest:self.repoId path:itemToEvaluate.path isReused:TRUE completion:^(NSURL *url) {
        is4K = [self checkIfVideoIs4k:url];
        dispatch_semaphore_signal(self.semaphore);
    }];
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return !is4K;
}

/**
 * Check if a video at the specified URL is 4K.
 * @param videoURL The URL of the video.
 * @return YES if the video is 4K, NO otherwise.
 */
- (BOOL)checkIfVideoIs4k:(NSURL *)videoURL {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (videoTrack) {
        CGSize videoSize = [videoTrack naturalSize];
        return (videoSize.width >= 3840 && videoSize.height >= 2160);
    }
    
    return NO;
}

/**
 * Create a network request to retrieve a URL.
 * @param repoId The repository ID.
 * @param path The path of the resource.
 * @param isReused A flag indicating if the resource should be reused.
 * @param completion A completion block that returns the URL.
 */
- (void)createRequest:(NSString *)repoId path:(NSURL *)path isReused:(BOOL)isReused completion:(void (^)(NSURL *url))completion {
    
    //Request
    NSString *isReusedParam = isReused ? @"1" : @"0";
    NSURLRequest *request = [self.connection buildRequest:[NSString stringWithFormat:@"%@/repos/%@/file/?p=%@&reuse=%@&op=download", API_URL, repoId, [path relativePath], isReusedParam] method:@"GET" form:nil];
    
    //Session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    //Task
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSString *downloadURLString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            completion([NSURL URLWithString:downloadURLString]);
            return;
        }
        completion(nil);
    }];
    [dataTask resume];
}


/**
 * Check if a file at the provided URL is a video extension.
 *
 * @param fileURL The NSURL pointing to the file.
 * @return YES if it's a video extension, NO otherwise.
 */
- (BOOL)isVideoFile:(NSURL *)fileURL {
    NSString *fileExtension = [fileURL pathExtension];
    NSArray *videoExtensions = @[@"mp4", @"avi", @"mkv", @"mov", @"wmv", @"flv", @"mpg", @"mpeg", @"webm", @"3gp", @"ogg"];
    NSString *lowercaseExtension = [fileExtension lowercaseString];
    return [videoExtensions containsObject:lowercaseExtension];
}


@end
