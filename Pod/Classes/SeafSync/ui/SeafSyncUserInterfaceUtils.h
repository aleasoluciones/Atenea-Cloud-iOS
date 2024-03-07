//
//  SeafSyncUserInterfaceUtils.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncEnums.h"
#import "SeafSyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncUserInterfaceUtils : NSObject

+(NSString *) seafSyncStateToString:(SeafSyncState) state;

+(NSString *) getReadableSourceFromSetting:(SeafSyncSettings *) setting;

+(NSString *) sourceTypeToReadableString:(SeafSyncSettings *) setting;

+(NSString *) formatDate:(NSDate *) date toStringWithFormat:(NSString *) format;

@end

NS_ASSUME_NONNULL_END
