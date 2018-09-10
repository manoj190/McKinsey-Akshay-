//
//  surveyCell.m
//  Mickensy_user
//
//  Created by Apple on 8/27/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "surveyCell.h"

@implementation surveyCell
@synthesize levelImg, levelLbl;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    levelImg.layer.masksToBounds=YES;
    //levelImg.layer.cornerRadius=47.5;
    self.backgroundColor=[UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
}

@end
