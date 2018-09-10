//
//  DataGridTextFieldCell.h
//  Cars DataGrid Sample
//
//  Created by Rustemsoft on 8/29/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataGridTextFieldCell : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) NSString *str;

@end
