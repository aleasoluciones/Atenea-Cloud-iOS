//
//  SeafSyncUserInterfaceUtils.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import "SeafSyncUserInterfaceUtils.h"
#import "SeafSyncEnums.h"
#import "SeafSyncUtils.h"
#import "SeafSyncSettings.h"


@implementation SeafSyncUserInterfaceUtils


+(NSString *) seafSyncStateToString:(SeafSyncState) state{
    switch (state) {
        case SeafSyncStateInactive:
            return NSLocalizedString(@"Inactive", @"Seafile");
            break;
        case SeafSyncStateRunning:
            return NSLocalizedString(@"Running", @"Seafile");
            break;
        case SeafSyncStateCompleted:
            return NSLocalizedString(@"Completed", @"Seafile");
            break;
        case SeafSyncStatePending:
            return NSLocalizedString(@"Pending", @"Seafile");
            break;
        case SeafSyncStateError:
            return NSLocalizedString(@"Error", @"Seafile");
            break;
        case SeafSyncStateExpired:
            return NSLocalizedString(@"Expired", @"Seafile");
            
        case SeafSyncStateUploading:
            return NSLocalizedString(@"Enqueued", @"Seafile");
            
        case SeafSyncStateCancelled:
            return NSLocalizedString(@"Cancelled", @"Seafile");
            break;
        default:
            return @"";
            break;
    }
}

+(NSString *) sourceTypeToReadableString:(SeafSyncSettings *) setting{
    
    switch (setting.sourceType) {
        case Folder:
            return NSLocalizedString(@"Folder", @"Seafile");
        case Gallery:
            return NSLocalizedString(@"Gallery", @"Seafile");
        
        case Album:
            return NSLocalizedString(@"Album", @"Seafile");
        default:
            return NSLocalizedString(@"Unknown", @"Seafile");
            break;
    }
}

+(NSString *) getReadableSourceFromSetting:(SeafSyncSettings *) setting{
    
    switch (setting.sourceType) {
        case Folder:{
            NSURL *url =  [SeafSyncUtils urlFromBookmark:setting.resourceId];
            return [url lastPathComponent];
            break;
        }
        case Gallery:
            return NSLocalizedString(@"Gallery", @"Seafile");
        
        case Album:
            return [setting.resourceId stringValue];
            
        default:
            return NSLocalizedString(@"Unknown", @"Seafile");
            break;
    }
}


+(NSString *) formatDate:(NSDate *) date toStringWithFormat:(NSString *) format{
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat: format];
      return [dateFormatter stringFromDate:date];
}

@end
