//
//  UIChart.h
//  Charts Sample
//
//  Created by Rustemsoft LLC on 11/3/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "enums.h"
#import "legendArea.h"
#import "ChartSeries.h"

@class UIChart;

@protocol ChartDelegate <NSObject>
@optional
// Content tapped delegated events
- (void)chartTapped:(UIChart *)chart;
@end

@interface UIChart : UIView
<ChartDelegate>

@property (nonatomic, readwrite) NSInteger ID;
@property (strong, nonatomic) UIColor *foregroundColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
@property (assign, nonatomic) chartTypes chartType;
@property (nonatomic, assign) orientations orientation;
@property (assign, nonatomic) layoutStyles layoutStyle;
@property (nonatomic, assign) gradientStyles gradientStyle;
@property (nonatomic, assign) gradientDirections gradientDirection;
@property (strong, nonatomic) UIColor *gradientColorTop;
@property (strong, nonatomic) UIColor *gradientColorTopExtra;
@property (strong, nonatomic) UIColor *gradientColorBottom;
@property (strong, nonatomic) UIColor *gradientColorBottomExtra;
@property (nonatomic, assign) CGFloat gradientRadius;
@property (nonatomic, copy) NSArray *gradientLocations;
@property (nonatomic, assign) CGFloat hatchLineStepHeight;
@property (nonatomic, assign) CGFloat hatchLineWidth;
@property (nonatomic, retain) NSString *backgroundImageName;
@property (nonatomic, retain) UILabel *chartTitle;
@property (nonatomic, retain) UIView *plotArea;
@property (strong, nonatomic) NSMutableArray *markedRegions;
@property (nonatomic, retain) UILabel *yAxisTitleLabel;
@property (nonatomic, assign) CGFloat yAxisTitleLabelRotationAngle;
@property (nonatomic, assign) verticalLocations yAxisTitleVerticalLocation;
@property (strong, nonatomic) UIColor *yAxisLabelsTextColor;
@property (strong, nonatomic) UIFont *yAxisLabelsFont;
@property (assign, nonatomic) BOOL yAxisLabelsHidden;
@property (assign, nonatomic) BOOL yAxisLinesHidden;
@property (assign, nonatomic) int yAxisScaleUnitsCount;
@property (nonatomic, retain) UILabel *xAxisTitleLabel;
@property (nonatomic, assign) CGFloat xAxisTitleLabelRotationAngle;
@property (nonatomic, assign) horizontalLocations xAxisTitleHorizontalLocation;
@property (nonatomic, assign) CGFloat xAxisTitleXshift;
@property (nonatomic, assign) CGFloat xAxisTitleYshift;
@property (strong, nonatomic) UIColor *xAxisLabelsTextColor;
@property (strong, nonatomic) UIFont *xAxisLabelsFont;
@property (assign, nonatomic) BOOL xAxisLabelsHidden;
@property (assign, nonatomic) BOOL xAxisLinesHidden;
@property (assign, nonatomic) BOOL xAxisLabelsShowDefaultOrderNumbers;
@property (nonatomic, retain) legendArea *legendZone;
@property (nonatomic, assign) horizontalLocations legendZoneHorizontalLocation;
@property (nonatomic, assign) verticalLocations legendZoneVerticalLocation;
@property (nonatomic, assign) orientations legendsInterpositions;
@property (strong, nonatomic) NSMutableArray *legends;
@property (strong, nonatomic) NSMutableArray *series;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat itemBreadth;
@property (assign) id <ChartDelegate> delegate;

- (void)DataBind;

@end
