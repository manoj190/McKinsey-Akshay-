//
//  ChartItem.h
//  TouchControls iOS Framework
//
//  Created by Rustemsoft LLC on 11/25/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "enums.h"

@class legend;

@interface legend: UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (nonatomic, retain) UIView *legendBullet;
@property (nonatomic, assign) legendBulletTypes legendBulletType;
@property (nonatomic, assign) CGFloat legendBulletWidth;
@property (nonatomic, assign) CGFloat legendBulletStrokeLineWidth;
@property (nonatomic, retain) UIColor *legendBulletFillColor;
@property (nonatomic, retain) UIColor *legendBulletStrokeLineColor;
@property (nonatomic, retain) NSString *legendBulletImageName;
@property (nonatomic, retain) UILabel *legendLabel;
@property (nonatomic, assign) CGFloat legendMargin;

@end
