//
//  maxDiffOutputCell.h
//  mckinsey
//
//  Created by Mac on 27/09/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLProgressBar.h"
@interface maxDiffOutputCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *featureNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *levelNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *scoreLbl;
@property (strong, nonatomic) IBOutlet UILabel *featureValueLbl;
@property (strong, nonatomic) IBOutlet UIImageView *featureNameLblBgImg;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressBarRoundedFat;
@property (strong, nonatomic) IBOutlet YLProgressBar *progressBarRoundedFat1;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setProgressForProgressBarOne:(CGFloat)progress animated:(BOOL)animated;
- (void)initRoundedFatProgressBar;
- (void)initRoundedFatProgressBarOne;

@end
