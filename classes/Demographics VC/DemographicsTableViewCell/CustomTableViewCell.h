//
//  CustomTableViewCell.h
//  mckinsey
//
//  Created by Mac on 22/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *srNoLabel;
@property (weak, nonatomic) IBOutlet UITextField *attributeNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *inputTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeAttributeBtn;


@end
