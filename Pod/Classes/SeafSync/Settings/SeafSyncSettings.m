/**
 * @file SeafSyncSettings.m
 * @author Javier Godoy (javigodoy@meytel.net)
 * @brief Implementation file for the SeafSyncSettings class.
 *
 * This file contains the implementation of the SeafSyncSettings class, which represents
 * synchronization settings for syncing files from a source folder to a target folder
 * in the user's cloud storage.
 */

#import "SeafSyncSettings.h"
#import "SeafDataTaskManager.h"
#import "SeafSyncUtils.h"

@implementation SeafSyncSettings

/// MARK: Properties
@synthesize active = _active;
@synthesize accountId = _accountId;
@synthesize resourceId = _resourceId;
@synthesize sourceType = _sourceType;
@synthesize mode = _mode;
@synthesize targetId = _targetId;
@synthesize repoId = _repoId;
@synthesize creationDate = _creationDate;
@synthesize availableUntilDate = _availableUntilDate;
@synthesize durationOfBackupFilesOnCloudInDays = _durationOfBackupFilesOnCloudInDays;
@synthesize identifier = _identifier;
@synthesize lastRunTime = _lastRunTime;
@synthesize state = _state;
@synthesize uploadOnlyOverWifi = _uploadOnlyOverWifi;
@synthesize uploadVideos = _uploadVideos;
@synthesize connection = _connection;
@synthesize lastRunError = _lastRunError;
@synthesize fullSourceURL = _fullSourceURL;
@synthesize lifeTime = _lifeTime;
@synthesize deleteFilesOnExpire = _deleteFilesOnExpire;

/// MARK: Methods

/**
 * Initializes a new SeafSyncSettings object with default values.
 * @return An initialized SeafSyncSettings object.
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.identifier = [[NSUUID UUID] UUIDString];
        self.state = SeafSyncStatePending;
        self.lastRunError = SeafSyncErrorNoError;
    }
    return self;
}

/// MARK: NSCoding implementation
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _accountId = [aDecoder decodeObjectForKey:@"accountId"];
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _resourceId = [aDecoder decodeObjectForKey:@"resourceId"];
        _repoId = [aDecoder decodeObjectForKey:@"repoId"];
        _targetId = [aDecoder decodeObjectForKey:@"targetId"];
        _creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        _availableUntilDate = [aDecoder decodeObjectForKey:@"availableUntilDate"];
        _durationOfBackupFilesOnCloudInDays = [aDecoder decodeIntegerForKey:@"durationOfBackupFilesOnCloudInDays"];
        _lastRunTime = [aDecoder decodeObjectForKey:@"lastRunTime"];
        _sourceType = (SeafSyncType)[aDecoder decodeIntForKey:@"sourceType"];
        _mode = (SeafSyncMode)[aDecoder decodeIntForKey:@"mode"];
        _state = (SeafSyncState)[aDecoder decodeIntForKey:@"state"];
        _uploadOnlyOverWifi = [aDecoder decodeBoolForKey:@"uploadOnlyOverWifi"];
        _uploadVideos = [aDecoder decodeBoolForKey:@"uploadVideos"];
        _lastRunError = (SeafSyncError)[aDecoder decodeIntForKey:@"lastRunError"];
        _fullSourceURL = [aDecoder decodeObjectForKey:@"fullSourceURL"];
        _lifeTime = (SeafSyncLifetimeType)[aDecoder decodeIntForKey:@"lifeTime"];
        _deleteFilesOnExpire = [aDecoder decodeBoolForKey:@"deleteFilesOnExpire"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.active forKey:@"active"];
    [encoder encodeObject:self.accountId forKey:@"accountId"];
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeObject:self.resourceId forKey:@"resourceId"];
    [encoder encodeObject:self.targetId forKey:@"targetId"];
    [encoder encodeObject:self.repoId forKey:@"repoId"];
    [encoder encodeObject:self.creationDate forKey:@"creationDate"];
    [encoder encodeObject:self.availableUntilDate forKey:@"availableUntilDate"];
    [encoder encodeInteger:self.durationOfBackupFilesOnCloudInDays forKey:@"durationOfBackupFilesOnCloudInDays"];
    [encoder encodeObject:self.lastRunTime forKey:@"lastRunTime"];
    [encoder encodeInt:(int)self.sourceType forKey:@"sourceType"];
    [encoder encodeInt:(int)self.mode forKey:@"mode"];
    [encoder encodeInt:(int)self.state forKey:@"state"];
    [encoder encodeBool:self.uploadOnlyOverWifi forKey:@"uploadOnlyOverWifi"];
    [encoder encodeBool:self.uploadVideos forKey:@"uploadVideos"];
    [encoder encodeInt:(int)self.lastRunError forKey:@"lastRunError"];
    [encoder encodeObject:self.targetId forKey:@"fullSourceURL"];
    [encoder encodeInt:(int)self.lifeTime forKey:@"lifeTime"];
    [encoder encodeBool:self.deleteFilesOnExpire forKey:@"deleteFilesOnExpire"];
}

/**
 * Returns the current synchronization state, considering if files from this setting are in the upload queue.
 * @return The current synchronization state.
 */
- (SeafSyncState)state {
    
    if(!self.active){
        return SeafSyncStateInactive;
    }
    
    if([self settingHasExpired]){
        return SeafSyncStateExpired;
    }
    
    if (self.connection != nil && [self filesFromThisSettingInQueue]) {
        return SeafSyncStateUploading;
    }
    
    if (self.connection != nil && [self filesFromThisSettingInQueue] == NO && self.lastRunTime != nil) {
        return SeafSyncStateCompleted;
    }

    return  _state;
}

/**
 * Checks if files from this synchronization setting are in the upload queue.
 * @return YES if files are in the upload queue; otherwise, NO.
 */
- (BOOL)filesFromThisSettingInQueue {
    __block BOOL inQueue = FALSE;
    
    SeafAccountTaskQueue *taskQueue = [[SeafDataTaskManager sharedObject] accountQueueForConnection:self.connection];
    
    [[taskQueue.uploadQueue allTasks] enumerateObjectsUsingBlock:^(SeafUploadFile *uploadFile, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([uploadFile.syncId isEqualToString:self.identifier]) {
            inQueue = TRUE;
            *stop = YES;
        }
    }];
    
    return inQueue;
}


/**
 * @brief Checks if the synchronization setting has expired.
 * @return A boolean indicating whether the synchronization setting has expired.
 */
- (BOOL)settingHasExpired {
    NSDate *today = [NSDate date];
    if ([SeafSyncUtils date:self.availableUntilDate isPreviousThan:today]) {
        return true;
    }
    return false;
}


@end
