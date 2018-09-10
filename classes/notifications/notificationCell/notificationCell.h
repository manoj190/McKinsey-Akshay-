//
//  notificationCell.h
//  mckinsey
//
//  Created by Mac on 15/12/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface notificationCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *notificationText;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

@end
