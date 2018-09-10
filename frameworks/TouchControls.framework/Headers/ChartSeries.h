//
//  ChartSeries.h
//  TouchControls iOS Framework
//
//  Created by Rustemsoft LLC on 11/26/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "enums.h"
#import "ChartItem.h"

@class ChartSeries;

@interface ChartSeries : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (strong, nonatomic) NSMutableArray *Items;
@property (strong, nonatomic) CAShapeLayer *shape;
@property (nonatomic, assign) BOOL pie3D;
@property (nonatomic, readwrite) NSInteger pie3DHeight;
@property (nonatomic, assign) CGPoint pieCenter;
@property (nonatomic, assign) CGFloat pieRadius;
@property (nonatomic, assign) startOClock pieStarts;
@end
