//
//  SeafSyncDateCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import "SeafSyncDateCell.h"

@interface SeafSyncDateCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic) SeafSyncDateCellCallback callback;
@end


@implementation SeafSyncDateCell

#define DEFAULT_DATE [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:[NSDate date] options:0] // 1 month later

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
}


- (void) onDateChange:(SeafSyncDateCellCallback) callback{
    self.callback = callback;
}

- (void) setTitle:(NSString *) title{
    self.titleLabel.text = title;
}

- (void) setDate:(NSDate *) date{
    if(date){
        [self.datePicker setDate:date];
    }
    else{
        //Default date if not date
        [self.datePicker setDate:DEFAULT_DATE];
    }
}

- (void)datePickerValueChanged:(UIDatePicker *)sender {
    if(self.callback){
        self.callback(sender.date);
    }
}

@end
