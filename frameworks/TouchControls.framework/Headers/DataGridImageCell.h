//
//  DataGridImageCell.h
//  Sample DataGrid
//
//  Created by SmrtX on 8/6/2014.
//  Copyright (c) 2014 SmrtX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataGridImageCell : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (nonatomic, retain) UIImageView *image;

@end
