/**
 * @file SeafSyncFolderObserver.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncFolderObserver class.
 *
 * This file contains the implementation of the SeafSyncFolderObserver class, which is responsible for observing changes in a folder and invoking a callback when changes occur.
 */

#import <Foundation/Foundation.h>
#import "SeafSyncFolderObserver.h"


@interface SeafSyncFolderObserver()
@property (nonatomic,retain) NSURL *urlFolderToObserve;
@end

@implementation SeafSyncFolderObserver {
    dispatch_source_t folderMonitor;
}

/**
 Initializes an instance of the class with a specified folder URL to observe.

 @param urlFolderToObserve The URL of the folder to be observed.
 @return An initialized instance of the class.
 */
-(id) initWith:(NSURL *) urlFolderToObserve{
    self =[super init];
    if(self){
        self.urlFolderToObserve = urlFolderToObserve;
    }
    return self;
}




/**
 * @brief Starts observing a folder at the specified path and sets a callback function to be called when changes occur.
 *
 * @param callback The callback function to invoke when changes occur.
 */
- (void)start:(nullable SeafSyncObserverProtocolCallback)callback {
    int fileDescriptor = open([self.urlFolderToObserve fileSystemRepresentation], O_EVTONLY);
    
    if (fileDescriptor < 0) {
        NSLog(@"Failed to open the folder for observation.");
        return;
    }
    
    folderMonitor = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor, DISPATCH_VNODE_WRITE, DISPATCH_TARGET_QUEUE_DEFAULT);
    
    dispatch_source_set_event_handler(folderMonitor, ^{
        unsigned long data = dispatch_source_get_data(self->folderMonitor);
        
        if (data & DISPATCH_VNODE_WRITE) {
            if (callback) {
                callback(self.urlFolderToObserve);
            }
        }
    });
    
    dispatch_source_set_cancel_handler(folderMonitor, ^{
        close(fileDescriptor);
    });
    
    dispatch_resume(folderMonitor);
}

/**
 * @brief Stops observing the folder.
 */
- (void)stop {
    if (folderMonitor) {
        dispatch_source_cancel(folderMonitor);
    }
}

/**
 * @brief Releases resources and stops observing the folder when the object is deallocated.
 */
- (void)dealloc {
    [self stop];
}

@end

