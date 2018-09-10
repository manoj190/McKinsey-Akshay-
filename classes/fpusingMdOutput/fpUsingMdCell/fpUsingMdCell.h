//
//  fpUsingMdCell.h
//  mckinsey
//
//  Created by Mac on 10/10/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface fpUsingMdCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *fromLevel;
@property (strong, nonatomic) IBOutlet UITextField *toLevel;
@property (strong, nonatomic) IBOutlet UILabel *valueLbl;
@property (strong, nonatomic) IBOutlet UILabel *costLbl;
@property (strong, nonatomic) IBOutlet UIImageView *costImg;
@property (strong, nonatomic) IBOutlet UIImageView *valueImg;
@end
