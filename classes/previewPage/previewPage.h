//
//  previewPage.h
//  mckinsey
//
//  Created by Mac on 27/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cardCell.h"
#import <MessageUI/MessageUI.h>
@interface previewPage : UIViewController<UITableViewDelegate,UITableViewDataSource,ColectionCellDelegate,MFMailComposeViewControllerDelegate>
- (IBAction)pushPreviewMethod:(UIButton *)sender;
@property (strong, nonatomic) NSString *surveyName;
@property (strong, nonatomic) NSString *surveyId;
@property (strong, nonatomic) NSMutableArray *levelsArray;
@property (strong, nonatomic) NSMutableArray *levelImgsArray;
@property int range;
@end
