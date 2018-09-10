//
//  SliderTableViewCell.m
//  mckinsey
//
//  Created by Akshay Ambekar on 10/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "SliderTableViewCell.h"


@implementation SliderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    NSLog(@"%ld",sender.tag);
    [self updateSliderLabels:sender.tag];
}

- (void)updateSliderLabels:(NSInteger)section
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    
    //CGPoint lowerCenter;
    //lowerCenter.x = (self.nmRangeSlider.lowerCenter.x + self.nmRangeSlider.frame.origin.x);
    //lowerCenter.y = (self.nmRangeSlider.center.y - 30.0f);
    //self.lowerLabel.center = lowerCenter;
    NSLog(@"lower value : %@",[NSString stringWithFormat:@"%d", (int)self.nmRangeSlider.lowerValue]);
    self.lowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.nmRangeSlider.lowerValue];
    
    //CGPoint upperCenter;
    //upperCenter.x = (self.nmRangeSlider.upperCenter.x + self.nmRangeSlider.frame.origin.x);
    //upperCenter.y = (self.nmRangeSlider.center.y - 30.0f);
    //self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%d", (int)self.nmRangeSlider.upperValue];
    
    [_delegate updateSliderValues:section andLowerValue:self.lowerLabel.text andUpper:self.upperLabel.text];
}


- (void)configureSliderMin:(NSInteger )minValue andMax:(NSInteger )max {
    self.nmRangeSlider.tintColor = [UIColor greenColor];
    self.nmRangeSlider.minimumValue = minValue;
    self.nmRangeSlider.maximumValue = max;
    
    self.nmRangeSlider.lowerValue = minValue;
    self.nmRangeSlider.upperValue = max;
    
    self.nmRangeSlider.minimumRange = minValue;
    
    self.lowerLabel.text = [NSString stringWithFormat:@"%ld",minValue];
    self.upperLabel.text = [NSString stringWithFormat:@"%ld",max];
}

@end
