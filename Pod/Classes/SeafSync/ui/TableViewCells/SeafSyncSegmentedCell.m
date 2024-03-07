//
//  SeafSyncSegmentedCell.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import "SeafSyncSegmentedCell.h"


@interface SeafSyncSegmentedCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic) SeafSyncSegmentedCellCallback callback;


@end


@implementation SeafSyncSegmentedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (void) onSegmentSelected:(SeafSyncSegmentedCellCallback)callback{
    self.callback = callback;
}

- (void) setTitle:(NSString *) title{
    self.titleLabel.text = title;
}

- (void) setSegments:(NSArray<NSString *> *) segments{
    
    [self.segmentedControl removeAllSegments];
    
    for (NSString *segment in segments) {
        [self.segmentedControl insertSegmentWithTitle:segment atIndex:[self.segmentedControl numberOfSegments] animated:NO];
    }
}

- (void) setSelectedSegmentIndex:(NSInteger) selectedSegment{
    [self.segmentedControl setSelectedSegmentIndex:selectedSegment];
}


- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    if(self.callback){
        self.callback(sender.selectedSegmentIndex);
    }

}





@end
