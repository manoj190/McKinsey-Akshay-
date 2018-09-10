//
//  markedRegion.h
//  TouchControls iOS Framework
//
//  Created by Rustemsoft LLC on 11/18/2014.
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "enums.h"

@class markedRegion;

@interface markedRegion : UIView

@property (nonatomic, readwrite) NSInteger ID;
@property (strong, nonatomic) UIColor *foregroundColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
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
@property (nonatomic, retain) UILabel *Title;
@property (nonatomic, assign) CGFloat yTop;
@property (nonatomic, assign) CGFloat yBottom;
@property (nonatomic, assign) CGFloat xStart;
@property (nonatomic, assign) CGFloat xEnd;
@property (nonatomic, assign) verticalLocations titleVerticalLocation;
@property (nonatomic, assign) horizontalLocations titleHorizontalLocation;

@end
