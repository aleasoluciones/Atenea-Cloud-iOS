//
//  SeafSyncLocationObserver.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 24/11/23.
//

#import "SeafSyncLocationObserver.h"
#import "SeafBackgroundTasksManager.h"

@interface SeafSyncLocationObserver ()

@property (nonatomic) CLLocationManager *locationManager;

@end


@implementation SeafSyncLocationObserver


/**
 *  @brief Singleton instance of SeafSyncLocationObserver.
 *  @return An instance of SeafSyncLocationObserver.
 */
+ (instancetype)sharedInstance {
    static SeafSyncLocationObserver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SeafSyncLocationObserver alloc] init];
        [sharedInstance initialize];
    });
    
    return sharedInstance;
}


-(void)initialize{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Request authorization to use location services
    [self requestAlwaysPermissionIfNeeded];
    
}

/**
 * @brief Returns the identifier for the observer.
 *
 * @return The identifier for the observer.
 */
- (id)observerIdentifier {
    return @"location_observer";
}

/**
 * @brief Starts the  observer.
 *
 * @param callback The callback block to be executed when synchronization events occur.
 */
- (void)start:(nullable SeafSyncObserverProtocolCallback)callback {
    if([self hasLocationPermission]){
        [self requestAlwaysPermissionIfNeeded];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

/**
 * @brief Stops the  observer.
 */
- (void)stop {
    if([self hasLocationPermission]){
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

/**
 Delegate method called when the location manager receives updated locations.

 @param manager The location manager object that generated the update.
 @param locations An array of CLLocation objects containing the location information.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [[[SeafBackgroundTasksManager sharedInstance] getTasks] enumerateObjectsUsingBlock:^(id<SeafBackgroundTaskProtocol>  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task run];
    }];
}

/**
 Delegate method called when the location manager fails to retrieve the location.

 @param manager The location manager object that generated the error.
 @param error An NSError object containing information about the failure.
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[[SeafBackgroundTasksManager sharedInstance] getTasks] enumerateObjectsUsingBlock:^(id<SeafBackgroundTaskProtocol>  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task run];
    }];
}


/**
 * @brief Requests location permission if kCLAuthorizationStatusAuthorizedWhenInUse is active.
 *
 * This method checks the current authorization status and requests location permission if it's not determined.
 * If location access is denied or restricted, a message is logged. If location access is already granted, a message is also logged.
 */
- (void)requestAlwaysPermissionIfNeeded {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if ( status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

/**
 * @brief Checks if the app has location permission.
 *
 * This method checks the current authorization status and returns YES if the app has location permission (not denied or restricted), NO otherwise.
 *
 * @return YES if the app has location permission, NO otherwise.
 */
- (BOOL)hasLocationPermission {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    return (status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted);
}



@end
