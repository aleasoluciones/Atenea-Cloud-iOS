//
//  SeafSyncLocationObserver.h
//  Seafile
//
//  Created by apps meytel on 24/11/23.
//

#import <Foundation/Foundation.h>
#import "SeafSyncObserverProtocol.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncLocationObserver : NSObject<SeafSyncObserverProtocol,CLLocationManagerDelegate>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
