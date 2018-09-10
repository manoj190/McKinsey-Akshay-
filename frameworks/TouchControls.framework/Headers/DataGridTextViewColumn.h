//
//  DataGridTextViewColumn.h
//  Sample DataGrid
//
//  Created by Rustemsoft on 9/22/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDataGrid.h"

@interface DataGridTextViewColumn : UIView

@property (nonatomic, readwrite) NSInteger dataFieldIndex;
@property (nonatomic, readwrite) AutoSizeTypes AutoSizeType;
@property (strong, nonatomic) NSMutableArray *Cells;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *HeaderBackgroundColor;
@property (strong, nonatomic) UIColor *HeaderForegroundColor;
@property (strong, nonatomic) UIFont *HeaderFont;
@property (strong, nonatomic) UIColor *HeaderBorderColor;
@property (assign, nonatomic) CGFloat HeaderBorderWidth;
@property (nonatomic, retain) UILabel *header;
@property (nonatomic, retain) UITextView *cellTemplate;
@property (nonatomic, retain) NSString *Title;
@property (assign, nonatomic) CGFloat Width;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) BOOL recognizeCellTapped;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic) UIKeyboardType keyboardType;
@property (assign, nonatomic) UIReturnKeyType returnKeyType;
@property (assign, nonatomic) NSTextAlignment TextAlignment;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) LayoutPositions cellLayoutPosition;
@property (assign, nonatomic) CGFloat cellLayoutPositionX;
@property (assign, nonatomic) CGFloat cellLayoutPositionY;

@end

