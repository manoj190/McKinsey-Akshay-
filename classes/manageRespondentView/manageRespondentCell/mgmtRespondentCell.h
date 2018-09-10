//
//  mgmtRespondentCell.h
//  mckinsey
//
//  Created by Mac on 23/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mgmtRespondentCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *srNoLbl;
@property (strong, nonatomic) IBOutlet UILabel *nameLbl;
@property (strong, nonatomic) IBOutlet UILabel *passwordLbl;
@property (strong, nonatomic) IBOutlet UILabel *emailIdLbl;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *userAttendedStatus;



@end
