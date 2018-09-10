//
//  DataGridCell.h
//  Sample DataGrid
//
//  Created by Rustemsoft on 7/15/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataGridDatePickerCell : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (nonatomic, retain) UIDatePicker *picker;
@property (nonatomic, retain) NSString *str;

@end
