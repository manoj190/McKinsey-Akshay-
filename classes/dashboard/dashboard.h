//
//  dashboard.h
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "analysisTypeView.h"
#import "manageRespondentView.h"
#import "userManagement.h"
#import "sendReminder.h"
#import "maxDiffOutput.h"
#import "fpOutput.h"
#import "fpOutput2.h"
#import "fpUsingMdOutput.h"

@interface dashboard : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) analysisTypeView *analysisTypeViewObj;
@property (strong, nonatomic) manageRespondentView *manageRespondentViewObj;
@property (strong, nonatomic) userManagement *userManagementObj;
@property (strong, nonatomic) sendReminder *sendReminderObj;
@property (strong, nonatomic) maxDiffOutput *maxDiffOutputObj;
//@property (strong, nonatomic) fpOutput *fpOutputObj;
@property (strong, nonatomic) fpOutput2 *fpOutputObj;
@property (strong, nonatomic) fpUsingMdOutput *fpUsingMdOutputObj;

@end
