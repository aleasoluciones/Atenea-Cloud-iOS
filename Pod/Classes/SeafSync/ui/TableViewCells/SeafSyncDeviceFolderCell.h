//
//  SeafSyncDeviceFolderCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SeafSyncDeviceFolderCellDelegate;

@interface SeafSyncDeviceFolderCell : UITableViewCell

@property (nonatomic, weak) id<SeafSyncDeviceFolderCellDelegate> delegate;
@property (nonatomic, copy) void (^folderSelectedCallback)(NSData *bookmark);

- (void)setFolderURL:(NSURL *)url;
- (void)setTitle:(NSString *)title;
- (void)onFolderSelected:(void (^)(NSData *bookmark))callback;
- (void)setActiveState:(BOOL)active;

@end

@protocol SeafSyncDeviceFolderCellDelegate <NSObject>
- (void)seafSyncDeviceFolderCellDidRequestFolderSelectionFromController:(UIViewController *)controller
                                                                forCell:(SeafSyncDeviceFolderCell *)cell;
@end

NS_ASSUME_NONNULL_END
