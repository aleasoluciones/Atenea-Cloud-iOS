//
//  SeafSyncCheckBoxCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import "SeafSyncCheckBoxCell.h"

@interface SeafSyncCheckBoxCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *theSwitch;

@property (nonatomic) SeafSyncCheckBoxCellCallback callback;
@end


@implementation SeafSyncCheckBoxCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //Reset before render
    self.titleLabel.text = @"";
    [self.theSwitch setOn:FALSE];
    [self.theSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (void) setTitle:(NSString *) title{
    self.titleLabel.text = title;
}

-(void) setValue:(BOOL) value{
    [self.theSwitch setOn:value];
}

- (void) onSwitchChange:(SeafSyncCheckBoxCellCallback) callback{
    self.callback = callback;
}

- (void)switchValueChanged:(UISwitch *)sender {
    if(self.callback != nil){
        self.callback(sender.isOn);
    }
}

@end
