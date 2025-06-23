//
//  SeafSyncSettingsViewController.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafConnection.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief SeafSyncSettingsViewController class for managing synchronization settings.
 */
@interface SeafSyncSettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate>

/**
 * @brief Constant representing the section index for active synchronization settings.
 */
#define ACTIVE_SETTINGS_SECTION             0

/**
 * @brief Constant representing the section index for creating new synchronization settings.
 */
#define CREATE_SETTINGS_SECTION             1

/**
 * @brief Identifier for the synchronization setting cell.
 */
#define SYNC_CELL_IDENTIFIER                @"SeafSyncSettingCell"

/**
 * @brief Identifier for the default synchronization setting cell.
 */
#define DEFAULT_SYNC_CELL_IDENTIFIER        @"DefaultSyncSettingCell"

/**
 * @brief Initializes a new instance of the SeafSyncSettingsViewController.
 *
 * @param connection The SeafConnection for which the settings are displayed.
 * @return An initialized instance of SeafSyncSettingsViewController.
 */
-(id) initWithConnection:(SeafConnection *) connection;

@end

NS_ASSUME_NONNULL_END
