//
//  HeadTableViewCell.h
//  mckinsey
//
//  Created by Mac on 21/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RangeHeadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *srNoLabel;
@property (weak, nonatomic) IBOutlet UITextField *attributeNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *inputTypeBtn;
@property (weak, nonatomic) IBOutlet UITextField *rangeFrom;
@property (weak, nonatomic) IBOutlet UITextField *rangeTo;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeAttributeBtn;

- (IBAction)closeAttributeBtn:(id)sender;


@end
