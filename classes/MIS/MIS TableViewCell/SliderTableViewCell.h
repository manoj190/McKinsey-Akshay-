//
//  SliderTableViewCell.h
//  mckinsey
//
//  Created by Akshay Ambekar on 10/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"

@protocol sliderProtocolDelegate
- (void)updateSliderValues:(NSInteger)section andLowerValue:(NSString *)lValue andUpper:(NSString *)uValue;
@end

@interface SliderTableViewCell : UITableViewCell
@property (nonatomic, weak) id <sliderProtocolDelegate> delegate;

- (void)configureSliderMin:(NSInteger )minValue andMax:(NSInteger )max;
- (void) updateSliderLabels:(NSInteger)section;

@property (weak, nonatomic) IBOutlet UILabel *attributeNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *sliderLabel;
@property (weak, nonatomic) IBOutlet UISwitch *attributeSwitch;
@property (weak, nonatomic) IBOutlet NMRangeSlider *nmRangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;

@end
