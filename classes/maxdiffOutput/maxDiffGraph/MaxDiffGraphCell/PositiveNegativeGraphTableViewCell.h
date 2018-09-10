//
//  PositiveNegativeGraphTableViewCell.h
//  mckinsey
//
//  Created by Mac on 11/04/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLProgressBar.h"

@interface PositiveNegativeGraphTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *levelNameLabel;
@property (weak, nonatomic) IBOutlet YLProgressBar *progressBarLeft;
@property (weak, nonatomic) IBOutlet YLProgressBar *progressBarRight;
@property (weak, nonatomic) IBOutlet UILabel *seperatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *righProgressbarLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftProgresseBar;

@end
