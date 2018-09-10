//
//  DataGridCell.h
//  Sample DataGrid
//
//  Created by Rustemsoft on 7/15/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataGridLabelCell : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *str;

@end
