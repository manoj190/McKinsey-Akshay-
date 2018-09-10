//
//  dashboardCell.m
//  mckinsey
//
//  Created by Mac on 23/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "dashboardCell.h"
#import "MBDemoAppearanceContainer.h"

@implementation dashboardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    MBSwitch *switchAppearanceProxy = [MBSwitch appearanceWhenContainedIn:[MBDemoAppearanceContainer class], nil];
    
    [switchAppearanceProxy setTintColor:[UIColor yellowColor]];
    [switchAppearanceProxy setOnTintColor:[UIColor orangeColor]];
    
    self.mbswitch2 = [[MBSwitch alloc] initWithFrame:CGRectMake(740.0, 5.0, 45.0, 27.0)];
    
    [self addSubview:_mbswitch2];
}

- (void)setUI:(BOOL)isCompleteSurvey {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
