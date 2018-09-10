//
//  enums.h
//  TouchControls iOS Framework
//
//  Created by Rustemsoft LLC on 11/22/2014
//  Copyright (c) 2014 Rustemsoft. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol enums <NSObject>

typedef NS_ENUM(NSUInteger, chartTypes) {
    pie = 0,
    bar = 1,
    barStacked = 2,
    line = 3,
    area = 4,
    areaStacked = 5,
    point = 6,
    cylinder = 7,
    cylinderStacked = 8
};

typedef NS_ENUM(NSUInteger, layoutStyles) {
    layoutStyleUnknown = -1,
    layoutStyleFlat = 0,
    layoutStyleGradient = 1,
    layoutStyleHatch = 2,
    layoutStyleImage = 3
};

typedef NS_ENUM(NSUInteger, gradientStyles) {
    gradientStyleSimple = 0,
    gradientStyleRadial = 1,
    gradientStyleCross = 2,
    gradientStyleSquare = 3,
    gradientStyleRainbow = 4
};

typedef NS_ENUM(NSUInteger, gradientDirections) {
    gradientDirectionDiagonalLeft = 0,
    gradientDirectionDiagonalRight = 1,
    gradientDirectionHorizontal = 2,
    gradientDirectionVertical = 3
};

typedef NS_ENUM(NSUInteger, verticalLocations) {
    verticalLocationUnknown = -1,
    verticalLocationTop = 0,
    verticalLocationMid = 1,
    verticalLocationBottom = 2
};

typedef NS_ENUM(NSUInteger, horizontalLocations) {
    horizontalLocationUnknown = -1,
    horizontalLocationLeft = 0,
    horizontalLocationMid = 1,
    horizontalLocationRight = 2
};

typedef NS_ENUM(NSUInteger, legendBulletTypes) {
    legendBulletTypeNoBullet = 0,
    legendBulletTypeDot = 1,
    legendBulletTypeRect = 2,
    legendBulletTypeTriangle = 3,
    legendBulletTypeImage = 4
};

typedef NS_ENUM(NSUInteger, pointTypes) {
    pointTypeNoPoint = 0,
    pointTypeDot = 1,
    pointTypeRect = 2,
    pointTypeTriangle = 3,
    pointTypeImage = 4
};

typedef NS_ENUM(NSUInteger, orientations) {
    vertical = 0,
    horizontal = 1
};

typedef NS_ENUM(NSUInteger, startOClock) {
    oClockNoon = 270,
    oClock3pm = 0,
    oClock6pm = 90,
    oClock9pm = 180,
};

extern NSString const *seca;
extern NSString const *secb;
extern NSString const *secc;
extern NSString const *secd;
extern NSString const *sece;
extern NSString const *secf;
extern NSString const *secg;
extern NSString const *sech;
extern NSString const *seci;
extern NSString const *secj;
extern NSString const *seck;
extern NSString const *secl;
extern NSString const *sec6;
extern NSString const *secm;
extern NSString const *secn;
extern NSString const *seco;
extern NSString const *secp;
extern NSString const *secq;
extern NSString const *secr;
extern NSString const *secs;
extern NSString const *sect;
extern NSString const *secu;
extern NSString const *secv;
extern NSString const *secw;
extern NSString const *secx; //-01/01/2015  @"DICDECFDEI";-05/01/2015
extern NSString const *secy;
extern NSString const *secz;

@end
