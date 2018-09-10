//
//  maxDiffOutputCell.m
//  mckinsey
//
//  Created by Mac on 27/09/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "maxDiffOutputCell.h"

@implementation maxDiffOutputCell
@synthesize featureNameLbl,levelNameLbl,scoreLbl;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark YLViewController Private Methods

- (void)setProgress1:(CGFloat)progress animated:(BOOL)animated
{
    [_progressBarRoundedFat setProgress:progress animated:animated];
}

- (void)setProgressForProgressBarOne:(CGFloat)progress animated:(BOOL)animated
{
    [_progressBarRoundedFat1 setProgress:progress animated:animated];
}

- (void)initRoundedFatProgressBar
{
    NSArray *tintColors = @[[UIColor colorWithRed:15.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1.0]];
    _progressBarRoundedFat.progressTintColors       = tintColors;
    _progressBarRoundedFat.stripesOrientation       = YLProgressBarStripesOrientationLeft;
    _progressBarRoundedFat.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    _progressBarRoundedFat.indicatorTextLabel.font  = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    _progressBarRoundedFat.progressStretch          = NO;
    
   
}

- (void)initRoundedFatProgressBarOne
{
    NSArray *tintColors = @[[UIColor colorWithRed:15.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    _progressBarRoundedFat1.progressTintColors       = tintColors;
    _progressBarRoundedFat1.stripesOrientation       = YLProgressBarStripesOrientationLeft;
    _progressBarRoundedFat1.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
    _progressBarRoundedFat1.indicatorTextLabel.font  = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    _progressBarRoundedFat1.progressStretch          = NO;
}

- (void)viewDidUnload
{
    self.progressBarRoundedFat   = nil;
    self.progressBarRoundedFat1 = nil;
}

@end
