//
//  SelectCtrl.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/1/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "SelectCtrl.h"
#import "SelectCtrlCell.h"
#import "NibLoader.h"
#import "UIView+Utils.h"
#import "DeviceHardware.h"
#import "VCtrlSelectSingleContent.h"
#import "VCtrlSelectMultiContent.h"

static UIPopoverController *ShownPopover = nil;

@interface SelectCtrl () <UIPickerViewDelegate, UIPickerViewDataSource,
                          UITableViewDelegate, UITableViewDataSource, SelectCtrlCellDelegate,
                          UIPopoverControllerDelegate>
{
    BOOL _isIpad;
    
    NSString *_placeholderText;
    UIColor *_textColor;
    UIColor *_placeholderTextColor;
    
    UIColor *_borderColor;
    
    UIPickerView *_picker;
    UITableView *_table;
    
    NSMutableOrderedSet *_items;
    
    SelectCtrlItem *_selectedItem;
    NSMutableOrderedSet *_selectedItems;
    
    UIPopoverController *_popover;
}

@property (strong, nonatomic) IBOutlet UIView *uiContainer;
@property (strong, nonatomic) IBOutlet UILabel *uiText;
@property (strong, nonatomic) IBOutlet UIView *uiSeparator;

@end

@implementation SelectCtrl

- (void)awakeFromNib
{
    _isIpad = [DeviceHardware isIpad];
    
    self.uiContainer.layer.borderColor = self.uiText.textColor.CGColor;
    self.uiContainer.layer.borderWidth = 1;
    self.uiContainer.layer.masksToBounds = YES;
    self.uiContainer.layer.cornerRadius = 4;
    
    _borderColor = self.uiText.textColor;
    _placeholderText = self.uiText.text;
    _textColor = self.uiText.textColor;
    _placeholderTextColor = self.placeholderColor ? self.placeholderColor : self.uiText.textColor;
    self.uiText.textColor = _placeholderTextColor;
    
    [self addTarget:self action:@selector(actTap) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setItems:(NSArray *)items
{
    _items = [NSMutableOrderedSet orderedSetWithArray:items];
    _selectedItems = [NSMutableOrderedSet orderedSet];
    [_picker reloadAllComponents];
}

- (void)setSelectedItems:(NSArray *)selectedItems
{
    [_selectedItems removeAllObjects];
    
    for (SelectCtrlItem *item in selectedItems) {
        if ([_items containsObject:item]) {
            [_selectedItems addObject:item];
        }
    }
    
    if (_selectedItems.count) {
        NSString *itemString = _selectedItems.count > 1 ? @"items" : @"item";
        self.uiText.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)_selectedItems.count, itemString];
        self.uiText.textColor = _textColor;
    } else {
        self.uiText.text = _placeholderText;
        self.uiText.textColor = _placeholderTextColor;
    }
    
    [_picker reloadAllComponents];
    [_table reloadData];
}

- (void)resetSelection
{
    [_selectedItems removeAllObjects];
    _selectedItem = nil;
    
    self.uiText.text = _placeholderText;
    self.uiText.textColor = _placeholderTextColor;
}

- (void)setSelectedItem:(SelectCtrlItem *)selectedItem
{
    _selectedItem = selectedItem;
    
    [self showSelectedItem:selectedItem];
    [self checkSelection];
}

- (SelectCtrlItem *)selectedItem
{
    return _selectedItem;
}

- (NSArray *)selectedItems
{
    return _selectedItems.array;
}

- (void)highlight
{
    self.uiContainer.layer.borderWidth = 2;
}

- (void)unHighlight
{
    self.uiContainer.layer.borderWidth = 1;
}

- (void)actTap
{
    if (_isIpad) {
        UIViewController *content = nil;
        
        if (self.isMultiSelect) {
            VCtrlSelectMultiContent *multiContent = [VCtrlSelectMultiContent new];
            
            [multiContent view];
            _table = multiContent.table;
            _table.delegate = self;
            _table.dataSource = self;
            [_table registerNib:[UINib nibWithNibName:[SelectCtrlCell nibName] bundle:nil]
                forCellReuseIdentifier:[SelectCtrlCell nibName]];
            
            content = multiContent;
        } else {
            VCtrlSelectSingleContent *singleContent = [VCtrlSelectSingleContent new];
    
            [singleContent view];
            _picker = singleContent.picker;
            _picker.showsSelectionIndicator = YES;
            _picker.delegate = self;
            _picker.dataSource = self;
            [self checkSelection];
            
            content = singleContent;
        }
        
        if (ShownPopover) {
            [ShownPopover dismissPopoverAnimated:NO];
            [ShownPopover.delegate popoverControllerDidDismissPopover:ShownPopover];
        }
        
        UIPopoverController *popover = _popover = [[UIPopoverController alloc] initWithContentViewController:content];
        
        _popover = popover;
        _popover.passthroughViews = self.passthroughViews;
        _popover.popoverContentSize = content.view.frame.size;
        _popover.delegate = self;
        ShownPopover = _popover;
        
        [popover presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [self highlight];
       
    } else {
        [self becomeFirstResponder];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (_popover == popoverController) {
        ShownPopover = nil;
    }
    
    _popover = nil;
    _picker = nil;
    [self unHighlight];
}

- (BOOL)canBecomeFirstResponder
{
    return !_isIpad;
}

- (BOOL)becomeFirstResponder
{
    if (!_isIpad) {
        [self highlight];
        [self checkSelection];
    }
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    if (!_isIpad) {
        [self unHighlight];
    }
    
    return [super resignFirstResponder];
}

- (void)checkSelection
{
    NSUInteger selIndex = 0;
    
    if (_selectedItem) {
        NSUInteger idx = [_items indexOfObject:_selectedItem];
        
        if (idx != NSNotFound) {
            selIndex = idx + 1;
        }
    }
    
    [_picker selectRow:selIndex inComponent:0 animated:NO];
}

- (void)showSelectedItem:(SelectCtrlItem *)item
{
    if (item) {
        NSMutableString *title = [NSMutableString stringWithFormat:@"%@", item.name];
        if (_showsCount) {
            [title appendFormat:@" (%ld)", (long)item.count];
        }
        self.uiText.text = title;
        self.uiText.textColor = _textColor;
    } else {
        self.uiText.text = _placeholderText;
        self.uiText.textColor = _placeholderTextColor;
    }
}

- (UIView *)inputView
{
    if (self.isMultiSelect) {
        if (!_table) {
            UIPickerView *pv = [UIPickerView new];
            
            _table = loadViewFromNib(@"SelectCtrlTable");
            _table.frame = pv.frame;
            _table.delegate = self;
            _table.dataSource = self;
            [_table registerNib:[UINib nibWithNibName:[SelectCtrlCell nibName] bundle:nil]
                    forCellReuseIdentifier:[SelectCtrlCell nibName]];
        }
        
        return _table;
    } else {
        if (!_picker) {
            _picker = [[UIPickerView alloc] init];
            _picker.showsSelectionIndicator = YES;
            _picker.delegate = self;
            _picker.backgroundColor = [UIColor whiteColor];
            
            if ([DeviceHardware isIpad]) {
                _picker.backgroundColor = [UIColor grayColor];
            }
        }
        
        [self checkSelection];
        return _picker;
    }
}

#pragma mark UIPickerDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _items.count + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0) {
        return @"All";
    }
    
    SelectCtrlItem *item = _items[row - 1];
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@", item.name];
    if (_showsCount) {
        [title appendFormat:@" (%ld)", (long)item.count];
    }
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (!self.isFirstResponder) {
        return;
    }
    if (row == 0) {
        self.uiText.text = _placeholderText;
        self.uiText.textColor = _placeholderTextColor;
        _selectedItem = nil;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        return;
    }
    
    SelectCtrlItem *item = _items[row - 1];
    
    [self showSelectedItem:item];
    _selectedItem = item;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return 36;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCtrlCell *cell = (SelectCtrlCell *)[tableView dequeueReusableCellWithIdentifier:[SelectCtrlCell nibName]];
    
    cell.item = _items[indexPath.row];
    cell.checked = [_selectedItems containsObject:cell.item];
    cell.delegate = self;
    return cell;
}

#pragma mark SelectCtrlCellDelegate

- (void)selectCtrlCellTap:(SelectCtrlCell *)cell
{
    if (cell.checked) {
        cell.checked = NO;
        [_selectedItems removeObject:cell.item];
    } else {
        cell.checked = YES;
        [_selectedItems addObject:cell.item];
    }
    
    if (_selectedItems.count) {
        NSString *itemString = _selectedItems.count > 1 ? @"items" : @"item";
        self.uiText.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)_selectedItems.count, itemString];
        self.uiText.textColor = _textColor;
    } else {
        self.uiText.text = _placeholderText;
        self.uiText.textColor = _placeholderTextColor;
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
