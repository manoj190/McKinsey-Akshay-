//
//  DataGridCell.h
//  Sample DataGrid
//
//  Created by Rustemsoft on 9/25/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataGridPickerCell : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (nonatomic, retain) UIPickerView *picker;
@property (nonatomic, retain) NSString *str;

@end
