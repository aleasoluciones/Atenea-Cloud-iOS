//
//  SeafSyncSettingCell.h
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import <UIKit/UIKit.h>
#import "SeafSyncSettings.h"
#import "SeafSyncBaseUITableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SeafSyncSettingCell : SeafSyncBaseUITableViewCell


-(void) fillData:(SeafSyncSettings *) setting;

@end

NS_ASSUME_NONNULL_END
