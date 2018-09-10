//
//  TextFieldTableViewCell.h
//  mckinsey
//
//  Created by Akshay Ambekar on 11/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *attributeLabel;

@property (weak, nonatomic) IBOutlet UISwitch *attributeSwitch;
@end
