//
//  userManagementCell.h
//  mckinsey
//
//  Created by Mac on 23/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userManagementCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *srNoLbl;
@property (strong, nonatomic) IBOutlet UILabel *userNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *emailIdLbl;
@property (strong, nonatomic) IBOutlet UILabel *passwordLbl;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) IBOutlet UIButton *infoBtn;
@end
