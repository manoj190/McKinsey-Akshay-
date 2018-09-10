//
//  UIDataGrid.h
//  Sample DataGrid
//
//  Created by Rustemsoft on 7/1/2014.
//  Copyright (c) 2015 Rustemsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enums.h"

@class UIDataGrid;

@protocol DataGridDelegate <NSObject>
@optional
// Content tapped delegated events
- (void)datagridCellTapped:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex value:(NSString *)value;
- (void)datagridColumnTitleTapped:(UIDataGrid *)datagrid colIndex:(int)colIndex title:(NSString *)title;
// Scrolling delegated events
- (void)datagridScrollViewDidScroll:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView;
- (void)datagridScrollViewWillBeginDragging:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView;
- (void)datagridScrollViewWillEndDragging:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
- (void)datagridScrollViewDidEndDragging:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)datagridScrollViewDidScrollToTop:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView;
- (void)datagridScrollViewWillBeginDecelerating:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView;
- (void)datagridScrollViewDidEndDecelerating:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView;
- (void)datagridScrollViewWillBeginZooming:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView withView:(UIView *)view;
- (void)datagridScrollViewDidEndZooming:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale;
- (void)datagridScrollViewDidZoom:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView;
- (void)datagridScrollViewDidEndScrollingAnimation:(UIDataGrid *)datagrid scrollView:(UIScrollView *)scrollView;
// TextField edit delegated events
- (void)datagridTextFieldColumnCellEditingChanged:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextField *)sender;
- (void)datagridTextFieldColumnCellEditingBegin:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextField *)sender;
- (void)datagridTextFieldColumnCellEditingEnd:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextField *)sender;
// DatePicker edit delegated events
- (void)datagridDatePickerColumnCellEditingChanged:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UIDatePicker *)sender;
- (void)datagridDatePickerColumnCellEditingBegin:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UIDatePicker *)sender;
- (void)datagridDatePickerColumnCellEditingEnd:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UIDatePicker *)sender;
// TextView Column's Delegated events - call the methods implemented in child classes
- (void)datagridTextViewColumnCellEditingBegin:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextView *)textView;
- (void)datagridTextViewColumnCellEditingChanged:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextView *)textView;
- (void)datagridTextViewColumnCellEditingSelectionChanged:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextView *)textView;
- (void)datagridTextViewColumnCellEditingEnd:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextView *)textView;
- (BOOL)datagridTextViewColumnCellEditingAboutBegin:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextView *)textView;
- (BOOL)datagridTextViewColumnCellEditingAboutEnd:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UITextView *)textView;
// PickerView Column delegated events - call the methods implemented in child classes
- (void)datagridPickerColumnCellRowSelected:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex rowInPicker:(NSInteger)row component:(NSInteger)component sender:(UIPickerView *)pickerView;
- (UIView *)datagridPickerColumnCellViewForRow:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex rowInPicker:(NSInteger)row component:(NSInteger)component reusingView:(UIView *)view sender:(UIPickerView *)pickerView;
// Slider edit delegated event
- (void)datagridSliderColumnCellValueChanged:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UISlider *)sender;
// Switch edit delegated event
- (void)datagridSwitchColumnCellValueChanged:(UIDataGrid *)datagrid rowIndex:(int)rowIndex colIndex:(int)colIndex sender:(UISwitch *)sender;
@end

@interface UIDataGrid : UIView
<UIScrollViewDelegate, UITextViewDelegate, UIPickerViewDelegate, DataGridDelegate>

typedef NS_ENUM(NSUInteger, AutoSizeTypes) {
    None = 0,
    TitleContentSize = 1,
    CellContentSize = 2
};

typedef NS_ENUM(NSUInteger, PickerFrameColors) {
    blackPickerFrameColor = 0,
    whitePickerFrameColor = 1,
    bluePickerFrameColor = 2,
    redPickerFrameColor = 3,
    greenPickerFrameColor = 4,
    brownPickerFrameColor = 5,
    yellowPickerFrameColor = 6
};

typedef NS_ENUM(NSUInteger, LayoutPositions) {
    LayoutPositionCenter = 0,
    LayoutPositionTopLeft = 1,
    LayoutPositionTopCenter = 2,
    LayoutPositionTopRight = 3,
    LayoutPositionLeftCenter = 4,
    LayoutPositionBottomLeft = 5,
    LayoutPositionBottomCenter = 6,
    LayoutPositionBottomRight = 7,
    LayoutPositionRightCenter = 8
};

typedef NS_ENUM(NSUInteger, numberWithTypes) {
    numberWithBool = 0,
    numberWithChar = 1,
    numberWithDouble = 2,
    numberWithFloat = 3,
    numberWithInt = 4,
    numberWithInteger = 5,
    numberWithLong = 6,
    numberWithLongLong = 7,
    numberWithShort = 8,
    numberWithUnsignedChar = 9,
    numberWithUnsignedInt = 10,
    numberWithUnsignedInteger = 11,
    numberWithUnsignedLong = 12,
    numberWithUnsignedLongLong = 13,
    numberWithUnsignedShort = 14
};

@property (strong, nonatomic) NSMutableArray *DataSource;
@property (strong, nonatomic) NSMutableArray *Columns;
@property (assign, nonatomic) CGFloat ColumnsWidth;
@property (assign, nonatomic) CGFloat RowHeight;
@property (strong, nonatomic) UIColor *foregroundColor;
@property (strong, nonatomic) UIColor *alternatingBackgroundColor;
@property (strong, nonatomic) UIFont *datagridFont;
@property (assign, nonatomic) CGFloat HeaderHeight;
@property (assign, nonatomic) BOOL HeaderScrollHide;
@property (strong, nonatomic) UIColor *HeaderBackgroundColor;
@property (strong, nonatomic) UIColor *HeaderForegroundColor;
@property (strong, nonatomic) UIFont *HeaderFont;
@property (strong, nonatomic) UIColor *HeaderBorderColor;
@property (assign, nonatomic) CGFloat HeaderBorderWidth;
@property (strong, nonatomic) UIColor *cellBorderColor;
@property (assign, nonatomic) CGFloat cellBorderWidth;
@property (strong, nonatomic) UIColor *rowBorderColor;
@property (assign, nonatomic) CGFloat rowBorderHeight;
@property (strong, nonatomic) UIColor *columnBorderColor;
@property (assign, nonatomic) CGFloat columnBorderWidth;
@property (assign, nonatomic) BOOL updateDataSource;
@property (assign, nonatomic) float griding;
@property (assign) id <DataGridDelegate> delegate;

- (void)DataBind;

@end
