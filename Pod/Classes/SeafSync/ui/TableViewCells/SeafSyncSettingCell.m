//
//  SeafSyncSettingCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 5/10/23.
//

#import "SeafSyncSettingCell.h"
#import "SeafSyncUserInterfaceUtils.h"
#import "SeafRepos.h"


@interface SeafSyncSettingCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *targetLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *sourceLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *statusLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lastRunLabel;

@property (unsafe_unretained, nonatomic) SeafSyncSettings *setting;
@end


@implementation SeafSyncSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void) fillData:(SeafSyncSettings *) setting{
    self.setting = setting;
    
    self.titleLabel.text = [SeafSyncUserInterfaceUtils sourceTypeToReadableString:self.setting];
    self.targetLabel.text = [NSString stringWithFormat:@"%@%@",[self getRepositoryName],self.setting.targetId];
    self.sourceLabel.text = [SeafSyncUserInterfaceUtils getReadableSourceFromSetting:self.setting];
    self.statusLabel.text = [SeafSyncUserInterfaceUtils seafSyncStateToString:self.setting.state];
    self.lastRunLabel.text = [SeafSyncUserInterfaceUtils formatDate:self.setting.lastRunTime toStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self applyCellStyle];
}

-(void) applyCellStyle{
    if(self.setting.state == SeafSyncStateError){
        self.statusLabel.textColor = UIColor.redColor;
    }
    else{
        self.statusLabel.textColor = UIColor.systemBlueColor;
    }
}

-(NSString *) getRepositoryName{
    SeafRepo *repo = [self.setting.connection getRepo:self.setting.repoId];
    return [repo name];
}

@end
