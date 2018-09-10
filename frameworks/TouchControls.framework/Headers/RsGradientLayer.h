//
//  RsGradientLayer.h
//  TouchControls iOS Framework
//
//  Created by Rustemsoft LLC on 11/07/2014
//  Copyright (c) 2014 Rustemsoft LLC
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "enums.h"

@interface RsGradientLayer : CALayer

@property (nonatomic, assign) CGFloat gradientRadius;
@property (nonatomic, copy) NSArray *colors;
@property (nonatomic, copy) NSArray *locations;
@property (nonatomic, assign) gradientStyles gradientStyle;
@property (nonatomic, assign) gradientDirections gradientDirection;

@end
