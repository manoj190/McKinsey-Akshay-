//
//  DataGridCell.h
//  Sample DataGrid
//
//  Created by Rustemsoft on 9/25/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataGridSwitchCell : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *onTintColor;
@property (strong, nonatomic) UIFont *font;
@property (nonatomic, retain) UISwitch *Switch;
@property (nonatomic, retain) NSString *str;

@end
