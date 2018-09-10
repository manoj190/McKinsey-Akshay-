//
//  maxDifInputCustomCell.h
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface maxDifInputCustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *indexNoLbl;
@property (strong, nonatomic) IBOutlet UITextField *featureTxt;
@property (strong, nonatomic) IBOutlet UITextField *levelTxt;
@property (strong, nonatomic) IBOutlet UIView *indexNoView;
@property (strong, nonatomic) IBOutlet UIButton *pictureBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

@end
