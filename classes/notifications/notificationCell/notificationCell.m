//
//  notificationCell.m
//  mckinsey
//
//  Created by Mac on 15/12/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "notificationCell.h"

@implementation notificationCell
@synthesize deleteBtn,notificationText;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
