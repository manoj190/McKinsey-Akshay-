//
//  CurrencyTableViewCell.h
//  mckinsey
//
//  Created by Mac on 20/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *currencyImg;
@property (weak, nonatomic) IBOutlet UILabel *currencyName;

@end
