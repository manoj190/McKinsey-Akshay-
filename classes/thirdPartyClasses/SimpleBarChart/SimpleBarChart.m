//
//  SimpleBarChart.m
//  YouLogReading
//
//  Created by Mohammed Islam on 9/18/13.
//  Copyright (c) 2013 KSI Technology, LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "SimpleBarChart.h"

@interface SimpleBarChart ()

@end

@implementation SimpleBarChart

@synthesize
delegate	= _delegate,
dataSource	= _dataSource;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return self;
    
    self.animationDuration	= 1.0;
    self.hasGrids			= YES;
    self.incrementValue		= 10.0;
    self.barWidth			= 20.0;
    self.barAlpha			= 1.0;
    self.chartBorderColor	= [UIColor whiteColor];
    self.gridColor			= [UIColor grayColor];
    self.hasYLabels			= YES;
    self.yLabelFont			= [UIFont fontWithName:@"Helvetica" size:12.0];
    self.yLabelColor		= [UIColor blackColor];
    self.yLabelType			= SimpleBarChartYAxisLabelTypeInteger;
    self.xLabelFont			= [UIFont fontWithName:@"Helvetica" size:12.0];
    self.xLabelColor		= [UIColor blackColor];
    self.xLabelType			= SimpleBarChartXLabelTypeVerticle;
    self.barTextFont		= [UIFont fontWithName:@"Helvetica" size:12.0];
    self.barTextColor		= [UIColor whiteColor];
    self.barTextType		= SimpleBarChartBarTextTypeTop;
    
    _barPathLayers			= [[NSMutableArray alloc] init];
    _barHeights				= [[NSMutableArray alloc] init];
    _barUpperLimit			= [[NSMutableArray alloc] init];
    _barLowerLimit			= [[NSMutableArray alloc] init];
    _barLabels				= [[NSMutableArray alloc] init];
    _barTexts				= [[NSMutableArray alloc] init];
    _barValues				= [[NSMutableArray alloc] init];
    pointerColorArr         = [[NSMutableArray alloc] init];
    // Grid
    _gridLayer				= [CALayer layer];
    [self.layer addSublayer:_gridLayer];
    
    _barLayer				= [CALayer layer];
    [self.layer addSublayer:_barLayer];
    
    connectingLayer			= [CALayer layer];
    [self.layer addSublayer:connectingLayer];
    
    _borderLayer			= [CALayer layer];
    [self.layer addSublayer:_borderLayer];
    
    _yLabelView				= [[UIView alloc] init];
    _yLabelView.alpha		= 0.0;
    [self addSubview:_yLabelView];
    
    _xLabelView				= [[UIView alloc] init];
    _xLabelView.alpha		= 0.0;
    [self addSubview:_xLabelView];
    
    _barTextView			= [[UIView alloc] init];
    _barTextView.alpha		= 0.0;
    [self addSubview:_barTextView];
    
    return self;
}

- (void)reloadData
{
    if (_dataSource)
    {
        // Collect some data
        _numberOfBars = [_dataSource numberOfBarsInBarChart:self];
        [_barHeights removeAllObjects];
        [_barUpperLimit removeAllObjects];
        [_barLowerLimit removeAllObjects];
        [_barLabels removeAllObjects];
        [_barTexts removeAllObjects];
        
        for (NSInteger i = 0; i < _numberOfBars; i++)
        {
            [_barHeights addObject:[NSNumber numberWithFloat:[_dataSource barChart:self valueForBarAtIndex:i]]];
            
            [_barUpperLimit addObject:[_dataSource barChart:self upperLimit:i]];
            
            [_barValues addObject:[_dataSource barChart:self setBarValues:i]];
            [_barLowerLimit addObject:[_dataSource barChart:self lowerLimit:i]];
            
            if ([_graphType isEqualToString:@"POINT GRAPH"])
            {
                [pointerColorArr addObject:[_dataSource barChart:self colorForPoints:i]];
            }
            else
            {
            }
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(barChart:xLabelForBarAtIndex:)])
                [_barLabels addObject:[_dataSource barChart:self xLabelForBarAtIndex:i]];
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(barChart:textForBarAtIndex:)])
                [_barTexts addObject:[_dataSource barChart:self textForBarAtIndex:i]];
        }
        
        _maxHeight			= [_barHeights valueForKeyPath:@"@max.self"];
        _minHeight			= [_barHeights valueForKeyPath:@"@min.self"];
        
        // Round up to the next increment value
        CGFloat remainder	= fmod(_maxHeight.floatValue / self.incrementValue, 1) * self.incrementValue;
        NSLog(@"incrementValue: %f, remainder: %f, maxHeight, %f", self.incrementValue, remainder, _maxHeight.floatValue);
        _topValue			= (self.incrementValue - remainder) + _maxHeight.floatValue;
        
        
        NSInteger maxValue=0;
        for (int i =0; i<_barLowerLimit.count; i++)
        {
            // b =  b + [[[graphDetailArr objectAtIndex:i] valueForKey:@"INCREMENTAL_VALUE"] integerValue];
            if (maxValue < [[_barLowerLimit objectAtIndex:i] integerValue])
            {
                maxValue = [[_barLowerLimit objectAtIndex:i] integerValue];
            }
            
        }
        maxValue = maxValue + (maxValue%10);
        avgXvalue= maxValue/_barLowerLimit.count;
        
        
        // Find max height of the x Labels based on the angle of rotation of the text
        switch (self.xLabelType)
        {
            case SimpleBarChartXLabelTypeVerticle:
            default:
                _xLabelRotation = 90.0;
                break;
                
            case SimpleBarChartXLabelTypeHorizontal:
                _xLabelRotation = 0.0;
                break;
                
            case SimpleBarChartXLabelTypeAngled:
                _xLabelRotation = 45.0;
                break;
        }
        
        for (NSString *label in _barLabels)
        {
            CGSize labelSize = [label sizeWithFont:self.xLabelFont];
            CGFloat labelHeightWithAngle = sin(DEGREES_TO_RADIANS(_xLabelRotation)) * labelSize.width;
            
            if (labelSize.height > labelHeightWithAngle)
            {
                _xLabelMaxHeight = MAX(_xLabelMaxHeight, labelSize.height);
                _xLabelMaxWidht = MAX(_xLabelMaxWidht, labelSize.width);
            }
            else
            {
                _xLabelMaxHeight = MAX(_xLabelMaxHeight, labelHeightWithAngle);
            }
        }
        
        // Begin Drawing
        if ([_graphType isEqualToString:@"POINT GRAPH"])
        {
            [self setupYAxisLabels];
            [self setupXAxisLabels];
        }
        else
        {
            [self setupXAxisLabels];
        }
        
        _gridLayer.frame		= CGRectMake(_yLabelView.frame.origin.x + _yLabelView.frame.size.width,
                                             0.0,
                                             self.bounds.size.width - (_yLabelView.frame.origin.x + _yLabelView.frame.size.width),
                                             self.bounds.size.height - (_xLabelMaxHeight > 0.0 ? (_xLabelMaxHeight + 5.0) : 0.0));
        _barLayer.frame			= _gridLayer.frame;
        _borderLayer.frame		= _gridLayer.frame;
        _barTextView.frame		= _gridLayer.frame;
        
        // Draw dem stuff
        [self setupBorders];
        [self drawBorders];
        // [self drawRect];
        
        @autoreleasepool
        {
            if ([_graphType isEqualToString:@"POINT GRAPH"])
            {
                [self setupSactterGraphPoints];
            }
            else
            {
                [self setupBars];
            }
            [self setupBarTexts];
            
            [self animateBarAtIndex:0];
        }
        
        if (self.hasGrids)
        {
            //			[self setupGrid];
            //			[self drawGrid];
        }
    }
}

#pragma mark Borders

- (void)setupBorders
{
    if (_borderPathLayer != nil)
    {
        [_borderPathLayer removeFromSuperlayer];
        _borderPathLayer = nil;
    }
    
    CGPoint bottomLeft 	= CGPointMake(CGRectGetMinX(_borderLayer.bounds), CGRectGetMinY(_borderLayer.bounds));
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(_borderLayer.bounds), CGRectGetMinY(_borderLayer.bounds));
    CGPoint topLeft		= CGPointMake(CGRectGetMinX(_borderLayer.bounds), CGRectGetMaxY(_borderLayer.bounds));
    CGPoint topRight	= CGPointMake(CGRectGetMaxX(_borderLayer.bounds), CGRectGetMaxY(_borderLayer.bounds));
    
    UIBezierPath *path	= [UIBezierPath bezierPath];
    [path moveToPoint:bottomRight];
    [path addLineToPoint:topRight];
    [path addLineToPoint:topLeft];
    [path addLineToPoint:bottomLeft];
    [path addLineToPoint:bottomRight];
    
    _borderPathLayer					= [CAShapeLayer layer];
    _borderPathLayer.frame				= _borderLayer.bounds;
    _borderPathLayer.bounds				= _borderLayer.bounds;
    _borderPathLayer.geometryFlipped	= YES;
    _borderPathLayer.path				= path.CGPath;
    _borderPathLayer.strokeColor		= self.chartBorderColor.CGColor;
    _borderPathLayer.fillColor			= nil;
    _borderPathLayer.lineWidth			= 1.0f;
    _borderPathLayer.lineJoin			= kCALineJoinBevel;
    
    [_borderLayer addSublayer:_borderPathLayer];
}

- (void)drawBorders
{
    if (self.animationDuration == 0.0)
        return;
    
    [_borderPathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation	= [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration			= self.animationDuration;
    pathAnimation.fromValue			= [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue			= [NSNumber numberWithFloat:1.0f];
    [_borderPathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

#pragma mark Bars

- (void)setupBars
{
    // Clear all bars for each drawing
    for (CAShapeLayer *layer in _barPathLayers)
    {
        if (layer != nil)
        {
            [layer removeFromSuperlayer];
        }
    }
    [_barPathLayers removeAllObjects];
    
    CGFloat barHeightRatio	= _barLayer.bounds.size.height / _topValue;
    CGFloat	xPos			= _barLayer.bounds.size.width / (_numberOfBars + 1);
    CGFloat lineXpos= _barLayer.bounds.size.width / (_numberOfBars + 1);
    // NSLog(@"Data in array: %@",_barLowerLimit);
    for (NSInteger i = 0; i < _numberOfBars; i++)
    {
        NSLog(@"Lower limit of number: %f",((NSNumber *)[_barLowerLimit objectAtIndex:i]).floatValue);
        
        CGPoint bottom					= CGPointMake(xPos, ((NSNumber *)[_barLowerLimit objectAtIndex:i]).floatValue);
        CGPoint top						= CGPointMake(xPos, ((NSNumber *)[_barUpperLimit objectAtIndex:i]).floatValue);
        
        UIBezierPath *path				= [UIBezierPath bezierPath];
        [path moveToPoint:bottom];
        [path addLineToPoint:top];
        
        UIColor *barColor				= [UIColor darkGrayColor];
        if (_dataSource && [_dataSource respondsToSelector:@selector(barChart:colorForBarAtIndex:)])
            barColor = [_dataSource barChart:self colorForBarAtIndex:i];
        
        CAShapeLayer *barPathLayer	= [CAShapeLayer layer];
        barPathLayer.frame			= _barLayer.bounds;
        barPathLayer.bounds			= _barLayer.bounds;
        barPathLayer.geometryFlipped	= YES;
        barPathLayer.path				= path.CGPath;
        barPathLayer.strokeColor		= [barColor colorWithAlphaComponent:self.self.barAlpha].CGColor;
        barPathLayer.fillColor		= nil;
        barPathLayer.lineWidth		= self.barWidth;
        barPathLayer.lineJoin			= kCALineJoinBevel;
        barPathLayer.hidden			= YES;
        barPathLayer.shadowOffset		= self.barShadowOffset;
        barPathLayer.shadowColor		= self.barShadowColor.CGColor;
        barPathLayer.shadowOpacity	= self.barShadowAlpha;
        barPathLayer.shadowRadius		= self.barShadowRadius;
        
        [_barLayer addSublayer:barPathLayer];
        [_barPathLayers addObject:barPathLayer];
        
        
        UIBezierPath *path1 = [UIBezierPath bezierPath];
        [path1 moveToPoint:CGPointMake(lineXpos + (self.barWidth/2) , ((NSNumber *)[_barUpperLimit objectAtIndex:i]).floatValue)];
        [path1 addLineToPoint:CGPointMake(lineXpos + (_barLayer.bounds.size.width / (_numberOfBars + 1))-(self.barWidth/2), ((NSNumber *)[_barUpperLimit objectAtIndex:i]).floatValue)];
        
        connectingPathLayer					= [CAShapeLayer layer];
        connectingPathLayer.frame			= _gridLayer.bounds;
        connectingPathLayer.bounds			= _gridLayer.bounds;
        connectingPathLayer.geometryFlipped	= YES;
        connectingPathLayer.path			= path1.CGPath;//15 239 255
        connectingPathLayer.strokeColor		= [[UIColor colorWithRed:15.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1.0]CGColor];
        //connectingPathLayer.strokeColor		= [[UIColor redColor]CGColor];
        connectingPathLayer.fillColor		= nil;
        connectingPathLayer.lineWidth		= 0.2f;
        connectingPathLayer.lineJoin		= kCALineJoinBevel;
        if (i<_numberOfBars - 1)
        {
            [_barLayer addSublayer:connectingPathLayer];
        }
        
        xPos							+= _barLayer.bounds.size.width / (_numberOfBars + 1);
        lineXpos						+= _barLayer.bounds.size.width / (_numberOfBars + 1);
        
        
    }
}

- (void)setupSactterGraphPoints
{
    // Clear all bars for each drawing
    for (CAShapeLayer *layer in _barPathLayers)
    {
        if (layer != nil)
        {
            [layer removeFromSuperlayer];
        }
    }
    [_barPathLayers removeAllObjects];
    
    CGFloat	xPos			= _barLayer.bounds.size.width / (_numberOfBars + 1);
    CGFloat Ypos= _barLayer.bounds.size.height / 10;
    _barLayer.masksToBounds=YES;
    _barLayer.cornerRadius=2.0;
    
    
    //    _barUpperLimit =[[NSMutableArray alloc] initWithObjects:@"20",@"35",@"40",@"50", nil];
    //    _barLowerLimit =[[NSMutableArray alloc] initWithObjects:@"30",@"50",@"65",@"85", nil];
    for (NSInteger i = 0; i < _numberOfBars; i++)
    {
        
        UIColor *barColor				= [UIColor darkGrayColor];
        if (_dataSource && [_dataSource respondsToSelector:@selector(barChart:colorForBarAtIndex:)])
            barColor = [_dataSource barChart:self colorForBarAtIndex:i];
        
        CAShapeLayer *barPathLayer = [CAShapeLayer layer];
        
        [barPathLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake( ( xPos * [[_barLowerLimit objectAtIndex:i] floatValue])/avgXvalue, ( Ypos* [[_barUpperLimit objectAtIndex:i] floatValue])/10, 3, 3)] CGPath]];
        
        
        
        NSLog(@"Lower limit :%f",( xPos * [[_barLowerLimit objectAtIndex:i] floatValue])/22);
        barPathLayer.frame				= _barLayer.bounds;
        barPathLayer.bounds				= _barLayer.bounds;
        barPathLayer.geometryFlipped	= YES;
        //barPathLayer.path				= path.CGPath;
        barPathLayer.strokeColor		= [[pointerColorArr objectAtIndex:i] CGColor];
        barPathLayer.fillColor			= [[UIColor blueColor] CGColor];
        barPathLayer.lineWidth			= self.barWidth;
        barPathLayer.lineWidth			= 3;
        barPathLayer.lineJoin			= kCALineJoinBevel;
        barPathLayer.hidden				= YES;
        barPathLayer.shadowOffset		= self.barShadowOffset;
        barPathLayer.shadowColor		= self.barShadowColor.CGColor;
        barPathLayer.shadowOpacity		= self.barShadowAlpha;
        barPathLayer.shadowRadius		= self.barShadowRadius;
        barPathLayer.masksToBounds=YES;
        //        [barPathLayer setFillColor:[[UIColor blueColor] CGColor]];
        //      //  [barPathLayer setStrokeColor:[[UIColor blueColor] CGColor]];
        
        //  xPos							+= _barLayer.bounds.size.width / (_numberOfBars + 1);
        
        [_barLayer addSublayer:barPathLayer];
        [_barPathLayers addObject:barPathLayer];
    }
}

- (void)animateBarAtIndex:(NSInteger)index
{
    if (index >= _barPathLayers.count)
    {
        // Last bar, begin drawing grids
        [self displayAxisLabels];
        return;
    }
    
    __block NSInteger i				= index + 1;
    __weak SimpleBarChart *weakSelf = self;
    [CATransaction begin];
    [CATransaction setAnimationDuration:(self.animationDuration / (CGFloat)_barPathLayers.count)];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        [weakSelf animateBarAtIndex:i];
    }];
    
    CAShapeLayer *barPathLayer		= [_barPathLayers objectAtIndex:index];
    barPathLayer.hidden				= NO;
    [self drawBar:barPathLayer];
    
    [CATransaction commit];
}

- (void)drawBar:(CAShapeLayer *)barPathLayer
{
    if (self.animationDuration == 0.0)
        return;
    
    [barPathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation	= [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.fromValue			= [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue			= [NSNumber numberWithFloat:1.0f];
    [barPathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}


- (void)drawRect
{
    //connectingLayer connectingPathLayer
    
    for (NSInteger i = 0; i < _numberOfBars; i++)
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(20.0, 0)];
        [path addLineToPoint:CGPointMake(80, 0)];
        
        connectingPathLayer					= [CAShapeLayer layer];
        connectingPathLayer.frame			= _gridLayer.bounds;
        connectingPathLayer.bounds			= _gridLayer.bounds;
        connectingPathLayer.geometryFlipped	= YES;
        connectingPathLayer.path				= path.CGPath;
        connectingPathLayer.strokeColor		= [[UIColor redColor]CGColor];
        connectingPathLayer.fillColor		= nil;
        connectingPathLayer.lineWidth		= 4.0f;
        connectingPathLayer.lineJoin			= kCALineJoinBevel;
        
        [_barLayer addSublayer:connectingPathLayer];
    }
    
}
#pragma mark Grid

- (void)setupGrid
{
    if (_gridPathLayer != nil)
    {
        [_gridPathLayer removeFromSuperlayer];
        _gridPathLayer = nil;
    }
    
    CGFloat gridUnit		= _gridLayer.bounds.size.height / _topValue;
    CGFloat gridSeperation	= gridUnit * self.incrementValue;
    
    CGFloat yPos			= gridSeperation;
    UIBezierPath *path		= [UIBezierPath bezierPath];
    while (yPos < _gridLayer.bounds.size.height || [self floatsAlmostEqualBetweenValue1:yPos value2:_gridLayer.bounds.size.height andPrecision:0.001])
    {
        NSLog(@"Y value: %f",yPos);
        CGPoint left	= CGPointMake(0.0, yPos);
        CGPoint right	= CGPointMake(_gridLayer.bounds.size.width, yPos);
        yPos			+= gridSeperation;
        
        [path moveToPoint:left];
        [path addLineToPoint:right];
    }
    
    _gridPathLayer					= [CAShapeLayer layer];
    _gridPathLayer.frame			= _gridLayer.bounds;
    _gridPathLayer.bounds			= _gridLayer.bounds;
    _gridPathLayer.geometryFlipped	= YES;
    _gridPathLayer.path				= path.CGPath;
    _gridPathLayer.strokeColor		= self.gridColor.CGColor;
    _gridPathLayer.fillColor		= nil;
    _gridPathLayer.lineWidth		= 1.0f;
    _gridPathLayer.lineJoin			= kCALineJoinBevel;
    
    [_gridLayer addSublayer:_gridPathLayer];
}

// From http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm
- (BOOL)floatsAlmostEqualBetweenValue1:(CGFloat)value1 value2:(CGFloat)value2 andPrecision:(CGFloat)precision
{
    if (value1 == value2)
        return YES;
    CGFloat relativeError = fabs((value1 - value2) / value2);
    if (relativeError <= precision)
        return YES;
    return NO;
}

- (void)drawGrid
{
    if (self.animationDuration == 0.0)
        return;
    
    [_gridPathLayer removeAllAnimations];
    
    CABasicAnimation *pathAnimation	= [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration			= self.animationDuration;
    pathAnimation.fromValue			= [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue			= [NSNumber numberWithFloat:1.0f];
    pathAnimation.timingFunction	= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_gridPathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

#pragma mark Axis Labels

- (void)setupYAxisLabels
{
    if (!self.hasYLabels)
        return;
    
    if (_yLabelView.alpha > 0.0)
    {
        _yLabelView.alpha = 0.0;
        [[_yLabelView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    CGFloat yLabelFrameHeight	= self.bounds.size.height - (_xLabelMaxHeight > 0.0 ? (_xLabelMaxHeight + 5.0) : 0.0);
    CGFloat gridUnit			= yLabelFrameHeight / 100;
    CGFloat gridSeperation		= gridUnit * self.incrementValue;
    
    CGFloat yPos				= 0.0;
    CGFloat maxVal				= 100;
    CGFloat maxWidth			= 0.0;
    int i=0;
    while (i<=10)
    {
        NSString *stringFormat	= (_yLabelType == SimpleBarChartYAxisLabelTypeFloat) ? @"%.1f" : @"%.0f";
        NSString *yLabelString	= [NSString stringWithFormat:stringFormat, maxVal];
        CGSize yLabelSize		= [yLabelString sizeWithFont:self.yLabelFont];
        CGRect yLabelFrame		= CGRectMake(0.0, 0.0, yLabelSize.width, yLabelSize.height);
        UILabel *yLabel			= [[UILabel alloc] initWithFrame:yLabelFrame];
        yLabel.font				= self.yLabelFont;
        yLabel.backgroundColor	= [UIColor clearColor];
        //yLabel.textColor		= self.yLabelColor;
        yLabel.textColor		= [UIColor whiteColor];
        yLabel.textAlignment	= NSTextAlignmentRight;
        yLabel.center			= CGPointMake(yLabel.center.x, yPos);
        yLabel.text				= yLabelString;
        
        [_yLabelView addSubview:yLabel];
        
        maxWidth				= MAX(maxWidth, yLabelSize.width);
        maxVal					-= self.incrementValue;
        yPos					+= gridSeperation;
        i++;
    }
    
    _yLabelView.frame		= CGRectMake(0.0,0.0,self.hasYLabels ? maxWidth + 5.0 : 0.0, yLabelFrameHeight);
}

- (void)setupXAxisLabels
{
    if ([_graphType isEqualToString:@"POINT GRAPH"])
    {
        if (_barLabels.count == 0)
            return;
        
        if (_xLabelView.alpha > 0.0)
        {
            _xLabelView.alpha = 0.0;
            [[_xLabelView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        CGFloat xLabelFrameWidth	= self.bounds.size.width - (_yLabelView.frame.origin.x + _yLabelView.frame.size.width);
        CGFloat	xPos				= xLabelFrameWidth / (_numberOfBars + 1);
        
        for (NSInteger i = 0; i < _numberOfBars; i++)
        {
            NSString *xLabelText	= [_barLabels objectAtIndex:i] ;
            CGSize xLabelSize		= [xLabelText sizeWithFont:self.xLabelFont];
            CGRect xLabelFrame		= CGRectMake(0.0,0.0,xLabelSize.width,xLabelSize.height);
            UILabel *xLabel			= [[UILabel alloc] initWithFrame:xLabelFrame];
            xLabel.font				= self.xLabelFont;
            xLabel.backgroundColor	= [UIColor clearColor];
            xLabel.textColor		= [UIColor whiteColor];
            xLabel.textAlignment	= NSTextAlignmentCenter;
            xLabel.text				= xLabelText;
            //xLabel.transform		= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-_xLabelRotation));
            
            // Position the label appropriately
            switch (self.xLabelType)
            {
                case SimpleBarChartXLabelTypeVerticle:
                default:
                    xLabel.center = CGPointMake(xPos, 15);
                    break;
                    
                case SimpleBarChartXLabelTypeHorizontal:
                    xLabel.center = CGPointMake(xPos, _xLabelMaxHeight / 2.0);
                    break;
                    
                case SimpleBarChartXLabelTypeAngled:
                {
                    CGFloat labelHeightWithAngle	= sin(DEGREES_TO_RADIANS(_xLabelRotation)) * xLabelSize.width;
                    xLabel.center					= CGPointMake(xPos - (labelHeightWithAngle / 2.0), labelHeightWithAngle / 2.0);
                    break;
                }
            }
            
            [_xLabelView addSubview:xLabel];
            
            xPos					+= xLabelFrameWidth / (_numberOfBars + 1);
        }
        
        _xLabelView.frame			= CGRectMake(_yLabelView.frame.origin.x + _yLabelView.frame.size.width,
                                                 self.bounds.size.height - _xLabelMaxHeight,
                                                 xLabelFrameWidth,
                                                 _xLabelMaxHeight);

    }
    else
    {
        if (_barLabels.count == 0)
            return;
        
        if (_xLabelView.alpha > 0.0)
        {
            _xLabelView.alpha = 0.0;
            [[_xLabelView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        CGFloat xLabelFrameWidth	= self.bounds.size.width - (_yLabelView.frame.origin.x + _yLabelView.frame.size.width);
        CGFloat	xPos				= xLabelFrameWidth / (_numberOfBars + 1);
        
        for (NSInteger i = 0; i < _numberOfBars; i++)
        {
            NSString *xLabelText	= [_barLabels objectAtIndex:i];
            CGSize xLabelSize		= [xLabelText sizeWithFont:self.xLabelFont];
            CGRect xLabelFrame		= CGRectMake(0.0,0.0,120,xLabelSize.height);
            UILabel *xLabel			= [[UILabel alloc] initWithFrame:xLabelFrame];
            xLabel.font				= self.xLabelFont;
            xLabel.backgroundColor	= [UIColor clearColor];
            xLabel.textColor		= [UIColor whiteColor];
            xLabel.textAlignment	= NSTextAlignmentRight;
            xLabel.text				= xLabelText;
            //xLabel.transform		= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-_xLabelRotation));
            
            // Position the label appropriately
            switch (self.xLabelType)
            {
                case SimpleBarChartXLabelTypeVerticle:
                default:
                    xLabel.center = CGPointMake(xPos, 15);
                    break;
                    
                case SimpleBarChartXLabelTypeHorizontal:
                    NSLog(@"Xlable Max height = %f",_xLabelMaxHeight);
                    NSLog(@"Xlable Max height = %f",_xLabelMaxWidht);
                    
                    xLabel.center = CGPointMake(xPos, 75);
                    xLabel.transform= CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
                    break;
                    
                case SimpleBarChartXLabelTypeAngled:
                {
                    CGFloat labelHeightWithAngle	= sin(DEGREES_TO_RADIANS(_xLabelRotation)) * xLabelSize.width;
                    xLabel.center					= CGPointMake(xPos - (labelHeightWithAngle / 2.0), labelHeightWithAngle / 2.0);
                    break;
                }
            }
            
            [_xLabelView addSubview:xLabel];
            
            xPos					+= xLabelFrameWidth / (_numberOfBars + 1);
        }
        
        _xLabelView.frame			= CGRectMake(_yLabelView.frame.origin.x + _yLabelView.frame.size.width,
                                                 self.bounds.size.height - _xLabelMaxHeight,
                                                 xLabelFrameWidth,
                                                 _xLabelMaxHeight);

    }
    
}


- (void)setupBarTexts
{
    //  _barTextView.backgroundColor=[UIColor grayColor];
    if ([_graphType isEqualToString:@"POINT GRAPH"])
    {
        if (_barTexts.count == 0)
            return;
        
        if (_barTextView.alpha > 0.0)
        {
            _barTextView.alpha = 0.0;
            [[_barTextView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        CGFloat	xPos				= _barLayer.bounds.size.width / (_numberOfBars + 1);
        CGFloat	Ypos				= _barLayer.bounds.size.height / 10;
        
        for (NSInteger i = 0; i < _numberOfBars; i++)
        {
            NSString *barLabelText	= [_barTexts objectAtIndex:i] ;
            CGSize barTextSize		= [barLabelText sizeWithFont:self.barTextFont];
            //            xPos=xPos * [[_barLowerLimit objectAtIndex:i] floatValue])/avgXvalue;
            //            Ypos
            CGRect barTextFrame		= CGRectMake(( xPos * [[_barLowerLimit objectAtIndex:i] floatValue])/avgXvalue, (( Ypos* [[_barUpperLimit objectAtIndex:i] floatValue])/10)+5, barTextSize.width,barTextSize.height);
            UILabel *barText		= [[UILabel alloc] initWithFrame:barTextFrame];
            barText.font			= self.barTextFont;
            barText.backgroundColor	= [UIColor clearColor];
            barText.textColor		= [pointerColorArr objectAtIndex:i];
            barText.textAlignment	= NSTextAlignmentCenter;
            barText.text			= barLabelText;
            
            CGFloat barHeight		= (_barLayer.bounds.size.height / _topValue) * ((NSNumber *)[_barHeights objectAtIndex:i]).floatValue;
            NSLog(@"Y axis: %@",[pointerColorArr objectAtIndex:i]);
            
            
            switch (self.barTextType)
            {
                case SimpleBarChartBarTextTypeTop:
                default:
                {
                    CGFloat extra=(((xPos * [[_barLowerLimit objectAtIndex:i] floatValue])/avgXvalue)-(barTextSize.width/2));
                    if (extra<0.0)
                    {
                        
                        barText.center = CGPointMake(( xPos * [[_barLowerLimit objectAtIndex:i] floatValue])/avgXvalue+(extra*(-1)  +10),_barTextView.frame.size.height-20-(( Ypos*[[_barUpperLimit objectAtIndex:i] floatValue])/10)+5);
                        
                    }
                    else
                        barText.center = CGPointMake(( xPos*[[_barLowerLimit objectAtIndex:i] floatValue])/avgXvalue,_barTextView.frame.size.height-20-(( Ypos *[[_barUpperLimit objectAtIndex:i] floatValue])/10)+5);
                    
                    break;
                    
                }
                    
                case SimpleBarChartBarTextTypeRoof:
                    barText.center = CGPointMake(xPos, _barLayer.bounds.size.height - (barHeight + (barTextSize.height / 2.0)));
                    break;
                    
                case SimpleBarChartBarTextTypeMiddle:
                {
                    CGFloat minBarHeight	= (_barLayer.bounds.size.height / _topValue) * _minHeight.floatValue;
                    barText.center			= CGPointMake(xPos, _barLayer.bounds.size.height - (minBarHeight / 2.0));
                    break;
                }
            }
            
            [_barTextView addSubview:barText];
            
            // xPos += _barLayer.bounds.size.width / (_numberOfBars + 1);
        }
        
    }
    else
    {
        if (_barTexts.count == 0)
            return;
        
        if (_barTextView.alpha > 0.0)
        {
            _barTextView.alpha = 0.0;
            [[_barTextView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        CGFloat	xPos				= _barLayer.bounds.size.width / (_numberOfBars + 1);
        
        for (NSInteger i = 0; i < _numberOfBars; i++)
        {
            NSString *barLabelText	= [_barValues objectAtIndex:i];
            CGSize barTextSize		= [barLabelText sizeWithFont:self.barTextFont];
            CGRect barTextFrame		= CGRectMake(xPos, 200,barTextSize.width, barTextSize.height);
            UILabel *barText		= [[UILabel alloc] initWithFrame:barTextFrame];
            barText.font			= self.barTextFont;
            barText.backgroundColor	= [UIColor clearColor];
            barText.textColor		= [UIColor whiteColor];
            barText.textAlignment	= NSTextAlignmentCenter;
            barText.text			= barLabelText;
            
            CGFloat barHeight		= (_barLayer.bounds.size.height / _topValue) * ((NSNumber *)[_barHeights objectAtIndex:i]).floatValue;
            NSLog(@"Y axis: %f",((NSNumber *)[_barUpperLimit objectAtIndex:i]).floatValue);
            
            
            switch (self.barTextType)
            {
                case SimpleBarChartBarTextTypeTop:
                default:
                    barText.center = CGPointMake(xPos,_barTextView.frame.size.height-10-[[_barUpperLimit objectAtIndex:i] floatValue]);
                    break;
                    
                case SimpleBarChartBarTextTypeRoof:
                    barText.center = CGPointMake(xPos, _barLayer.bounds.size.height - (barHeight + (barTextSize.height / 2.0)));
                    break;
                    
                case SimpleBarChartBarTextTypeMiddle:
                {
                    CGFloat minBarHeight	= (_barLayer.bounds.size.height / _topValue) * _minHeight.floatValue;
                    barText.center			= CGPointMake(xPos, _barLayer.bounds.size.height - (minBarHeight / 2.0));
                    break;
                }
            }
            
            [_barTextView addSubview:barText];
            
            xPos += _barLayer.bounds.size.width / (_numberOfBars + 1);
        }
        
    }
}

- (void)displayAxisLabels
{
    if (self.hasYLabels || _barTexts.count > 0 || _barLabels.count > 0)
    {
        if (self.animationDuration > 0.0)
        {
            __weak SimpleBarChart *weakSelf = self;
            [UIView animateWithDuration:self.animationDuration / 2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _yLabelView.alpha	= 1.0;
                _xLabelView.alpha	= 1.0;
                _barTextView.alpha	= 1.0;
            } completion:^(BOOL finished) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(animationDidEndForBarChart:)])
                    [weakSelf.delegate animationDidEndForBarChart:weakSelf];
            }];
        }
        else
        {
            _yLabelView.alpha	= 1.0;
            _xLabelView.alpha	= 1.0;
            _barTextView.alpha	= 1.0;
            
            if (_delegate && [_delegate respondsToSelector:@selector(animationDidEndForBarChart:)])
                [_delegate animationDidEndForBarChart:self];
        }
    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(animationDidEndForBarChart:)])
            [_delegate animationDidEndForBarChart:self];
    }
}


@end
