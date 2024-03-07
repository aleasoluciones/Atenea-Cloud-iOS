/**
* @file Support4k.m
* @brief Implementation of the Support4k class.
* @details This class provides functionality to check if a video file meets the condition of being in 4K (Ultra HD) resolution.
* @date 26/10/23
*/
 
#import <Foundation/Foundation.h>
#import "SeafPlanUser.h"
#import "Support4k.h"
#import "SeafFile.h"
#import "SeafConnection+UserPlan.h"
#import <AVFoundation/AVFoundation.h>
 
@interface Support4k ()
 
@property SeafPlanUser *planUser; /**< The plan user */
@property (nonatomic, retain) dispatch_semaphore_t main_semaphore; /**< Main semaphore */
 
@end
 
@implementation Support4k
 
/**
* Initializes an instance of Support4k with a plan user.
* @param planUser The plan user.
* @return An initialized instance of Support4k.
*/
-(id)initWithPlan:(SeafPlanUser *)planUser {
    self = [super init];
    if(self){
        self.planUser = planUser;
        self.main_semaphore = dispatch_semaphore_create(0);
    }
    
    return self;
}
 
/**
* Checks if a file meets the condition of being in 4K resolution.
* @param itemToEvaluate The file to evaluate.
* @return `YES` if the file meets the condition, `NO` otherwise.
*/
- (BOOL)meetsCondition:(id<SeafFileProtocol>)itemToEvaluate {

    // If it supports 4K, no need to check
    if (self.planUser.support4k) return true;
    
    // If it doesn't support 4K, check that the video is not 4K (from the gallery and from the file system)
    return FALSE == [self isAssetVideo4k:itemToEvaluate] &&  FALSE == [self isFileVideo4k:itemToEvaluate];
}
 
/**
* Checks if a video file in the file system meets the condition of being in 4K resolution.
* @param itemToEvaluate The video file to evaluate.
* @return `YES` if the video file meets the condition, `NO` otherwise.
*/
-(BOOL) isFileVideo4k:(id<SeafFileProtocol>)itemToEvaluate  {
    NSURL *fileURL = [itemToEvaluate path];
    
    //No video extension
    if(FALSE == [self isVideoFile:fileURL]){
        return false;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    
    if(asset){
        CGSize naturalSize = [[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize];
        NSLog(@"NATURALSIZE %f %f", naturalSize.width, naturalSize.height);
        return (naturalSize.width >= 3840 && naturalSize.height >= 2160);
    }
    
    return false;
}
 
/**
* Checks if a video file in the gallery meets the condition of being in 4K resolution.
* @param itemToEvaluate The video file to evaluate.
* @return `YES` if the video file meets the condition, `NO` otherwise.
*/
- (BOOL)isAssetVideo4k:(id<SeafFileProtocol>)itemToEvaluate {

    __block BOOL is4K = false;
    
    //If no ID, not an asset
    if (itemToEvaluate.identifier == nil){
        return false;
    }
    
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[itemToEvaluate.identifier] options:nil];
 
    if (result) {
        
        PHAsset *phAsset = [result firstObject];
        
        if (phAsset && phAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;

            //options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            
            options.networkAccessAllowed = TRUE;
            [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    CGSize naturalSize = [urlAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize;
                    is4K = (naturalSize.width >= 3840 && naturalSize.height >= 2160);
                }
                dispatch_semaphore_signal(self.main_semaphore);
            }];
            
            dispatch_semaphore_wait(self.main_semaphore, DISPATCH_TIME_FOREVER);
            return is4K;
            
        }
    }
    
    return is4K;
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

