/**
 * @file SeafSyncSelectorCell.m
 * @brief Implementation of SeafSyncSelectorCell class.
 *
 * Created by Javier Godoy (javigodoy@meytel.net) on 14/11/23.
 */

#import "SeafSyncSelectorCell.h"
#import "SeafSyncSelectorCellDataItemProtocol.h"

/**
 * SeafSyncSelectorCell
 * @brief Custom UITableViewCell with a UIPickerView for selecting values.
 *
 * The SeafSyncSelectorCell class provides a custom UITableViewCell with a UIPickerView
 * for selecting values. It conforms to the SeafSyncSelectorCellDataItemProtocol to handle
 * data items in the UIPickerView.
 */
@interface SeafSyncSelectorCell ()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel; ///< Title label for the cell.
@property (nonatomic) IBOutlet NSArray<NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *> *_values; ///< Array of arrays of data items.
@property (unsafe_unretained, nonatomic) IBOutlet UIPickerView *picker; ///< UIPickerView for selecting values.

@property (nonatomic) SeafSyncSelectorCellCallback callback; ///< Callback block to handle value changes.

@end

@implementation SeafSyncSelectorCell

/**
 * @brief Called when the cell is loaded from the storyboard or NIB file.
 */
- (void)awakeFromNib {
    [super awakeFromNib];
}

/**
 * @brief Sets the callback block to be called on value change.
 * @param callback The callback block to be set.
 */
- (void)onValueChange:(SeafSyncSelectorCellCallback)callback {
    self.callback = callback;
}

/**
 * @brief Sets the title for the cell.
 * @param title The title to be set.
 */
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

/**
 * @brief Sets the array of values for the UIPickerView.
 * @param values The array of arrays of data items to be set.
 */
- (void)setValues:(NSArray<NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *> *)values {
    self._values = values;
    [self.picker reloadAllComponents];
}

/**
 * @brief Selects a specific item in the UIPickerView.
 * @param items The data items to be selected.
 */
- (void)selectedItems:(NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *)items {
    
    [items enumerateObjectsUsingBlock:^(id<SeafSyncSelectorCellDataItemProtocol>  _Nonnull item, NSUInteger componentIndex, BOOL * _Nonnull stop) {
        
        NSArray *componentItems = [self._values[componentIndex] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<SeafSyncSelectorCellDataItemProtocol>  _Nullable evaluatedObject, NSDictionary<NSString *,id> *bindings) {
            return [[evaluatedObject value] isEqual:[item value]];
        }]];
        
        if (componentItems.count > 0) {
            [self.picker selectRow:[self._values[componentIndex] indexOfObject:[componentItems firstObject]] inComponent:componentIndex animated:NO];
        }
    }];

}

/**
 * @brief Returns the selected components from the UIPickerView.
 * @return An array of selected data items.
 */
- (NSArray<id<SeafSyncSelectorCellDataItemProtocol>> *)getSelectedComponents {
    NSMutableArray *selectedComponents = [NSMutableArray array];
    
    for (NSInteger component = 0; component < self._values.count; component++) {
        NSInteger selectedRow = [self.picker selectedRowInComponent:component];
        [selectedComponents addObject:self._values[component][selectedRow]];
    }
    
    return selectedComponents;
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self._values.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self._values[component].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self._values[component][row] title];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.callback) {
        self.callback([self getSelectedComponents]);
    }
}

@end
