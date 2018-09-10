//
//  DataGridTextViewCell.h
//  Cars DataGrid Sample
//
//  Created by Rustemsoft on 9/22/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataGridTextViewCell : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) NSString *str;

@end
