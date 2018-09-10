//
//  ToggleSwitchTableViewCell.h
//  mckinsey
//
//  Created by Akshay Ambekar on 10/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleSwitchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *attributeNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *attributeSwitch;

@end
