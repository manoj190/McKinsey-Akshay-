//
//  TextFieldSubHeadTableViewCell.h
//  mckinsey
//
//  Created by Mac on 22/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldSubHeadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *optionTextField;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@end
