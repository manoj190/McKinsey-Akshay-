//
//  LocationHeadTableViewCell.h
//  mckinsey
//
//  Created by Akshay Ambekar on 10/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationHeadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *locationAttributeNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectCountryBtn;
@property (weak, nonatomic) IBOutlet UISwitch *attributeSwitch;

@end
