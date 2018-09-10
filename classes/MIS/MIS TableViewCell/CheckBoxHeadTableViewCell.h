//
//  CheckBoxHeadTableViewCell.h
//  mckinsey
//
//  Created by Akshay Ambekar on 10/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckBoxHeadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *attributeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxBtnImg;
@property (weak, nonatomic) IBOutlet UISwitch *attributeSwitch;

@end
