//
//  dashboardCell.h
//  mckinsey
//
//  Created by Mac on 23/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSwitch.h"

@interface dashboardCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *srNoLbl;
@property (strong, nonatomic) IBOutlet UILabel *NameLbl;
@property (strong, nonatomic) IBOutlet UILabel *typeLbl;
@property (strong, nonatomic) IBOutlet UILabel *percentLbl;
@property (strong, nonatomic) IBOutlet UISwitch *modeBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic, retain) MBSwitch *mbswitch2;
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIImageView *switchBgView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

- (void)setUI:(BOOL)isCompleteSurvey;

@end
