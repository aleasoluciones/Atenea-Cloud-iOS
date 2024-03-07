//
//  SeafSyncNetworkerService.m
//  Seafile
//
// Created by Javier Godoy (javigodoy@meytel.net) on 4/10/23.
//

#import "SeafSyncNetworkerService.h"
#import "AFNetworking.h"
#import "SeafSyncEnums.h"
#import "SeafConnection.h"

/**
 * SeafSyncNetworkerService ()
 * @brief Private interface for SeafSyncNetworkerService.
 */
@interface SeafSyncNetworkerService()

/**
 * An array to store observers conforming to the SeafSyncNetworkerServiceObserverDelegate protocol.
 */
@property (nonatomic, retain) NSMutableArray<SeafSyncNetworkerServiceObserverDelegate> *observers;

/**
 * The AFNetworkReachabilityManager to monitor network reachability.
 */
@property (nonatomic, retain) AFNetworkReachabilityManager *networkReachabilityManager;

/**
 * The SeafConnection associated with the network service.
 */
@property (nonatomic, retain) SeafConnection *connection;



@end

@implementation SeafSyncNetworkerService

static NSMutableArray<SeafSyncNetworkerService *> *sharedInstances;

/**
 * Initializes a new instance of SeafSyncNetworkerService with the specified SeafConnection.
 * @param connection The SeafConnection associated with the network service.
 * @return An initialized instance of SeafSyncNetworkerService.
 */
- (instancetype)initWithConnection:(SeafConnection *)connection {
    self = [super init];
    if (self) {
        self.observers = [[NSMutableArray<SeafSyncNetworkerServiceObserverDelegate> alloc] initWithCapacity:0];
        self.connection = connection;
        
        [self initializeReachabilityManager];
        [self startMonitoringNetworkChanges];
    }
    return self;
}

/**
 * Returns a shared instance of SeafSyncNetworkerService for the specified SeafConnection.
 * @param connection The SeafConnection for which the networker service is associated.
 * @return An instance of SeafSyncNetworkerService.
 */
+ (instancetype)sharedInstanceFor:(SeafConnection *)connection {
    if (sharedInstances == nil) {
        sharedInstances = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    SeafSyncNetworkerService *networkService = [SeafSyncNetworkerService getInstaceFor:connection];
    if(networkService != nil) {
        return networkService;
    }

    //Create for this connection
    networkService = [[SeafSyncNetworkerService alloc] initWithConnection:connection];
    [sharedInstances addObject:networkService];
    return networkService;
}

/**
 * Gets the existing instance of SeafSyncNetworkerService for the specified SeafConnection.
 * @param connection The SeafConnection for which the instance is sought.
 * @return An instance of SeafSyncNetworkerService if it exists, otherwise nil.
 */
+ (instancetype)getInstaceFor:(SeafConnection *)connection {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(SeafSyncNetworkerService  *service, NSDictionary<NSString *,id> * _Nullable bindings) {
        return service.connection == connection;
    }];
    return [[sharedInstances filteredArrayUsingPredicate:predicate] firstObject];
}

/**
 * Initializes the AFNetworkReachabilityManager with the reachability of the specified host.
 */
- (void)initializeReachabilityManager {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [self.connection.host UTF8String]);
    self.networkReachabilityManager = [[AFNetworkReachabilityManager alloc] initWithReachability:reachability];
}

/**
 * Returns the current network state.
 * @return The current network state as a SeafSyncNetworkState enum.
 */
- (SeafSyncNetworkState)networkState {
    switch ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return SeafSyncNetworkStateWifi;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return SeafSyncNetworkState3G;
            break;
        default:
            return SeafSyncNetworkStateUnknow;
            break;
    }
}

/**
 * Subscribes an observer to receive network-related notifications.
 * @param observer The observer conforming to the SeafSyncNetworkerServiceObserverDelegate protocol.
 */
- (void)subscribe:(id<SeafSyncNetworkerServiceObserverDelegate>)observer {
    [self.observers addObject:observer];
}

/**
 * Unsubscribes an observer from receiving network-related notifications.
 * @param observer The observer to be unsubscribed.
 */
- (void)unSubscribe:(id<SeafSyncNetworkerServiceObserverDelegate>)observer {
    [self.observers removeObject:observer];
}

/**
 * Checks if there is an active network connection.
 * @return YES if a connection is available, NO otherwise.
 */
- (BOOL)hasConnection {
    return [self.networkReachabilityManager isReachable];
}

/**
 * Checks if a Wi-Fi connection is available.
 * @return YES if a Wi-Fi connection is available, NO otherwise.
 */
- (BOOL)wifiConnectionAvailable {
    return [self.networkReachabilityManager isReachableViaWiFi];
}

/**
 * Starts monitoring network changes and notifies subscribers on changes.
 */
- (void)startMonitoringNetworkChanges {
    __weak typeof(self) weakSelf = self;
    
    [self.networkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [weakSelf notifyToSubscribers];
    }];
    
    [self.networkReachabilityManager startMonitoring];
}

/**
 * Notifies all subscribers about the current network status.
 */
- (void)notifyToSubscribers {
    [self.observers enumerateObjectsUsingBlock:^(id<SeafSyncNetworkerServiceObserverDelegate>  _Nonnull observer, NSUInteger idx, BOOL * _Nonnull stop) {
        [observer onSeafSyncNetworkStatusChange:[self networkState]];
    }];
}

@end


