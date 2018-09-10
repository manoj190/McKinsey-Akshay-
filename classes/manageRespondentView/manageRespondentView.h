//
//  manageRespondentView.h
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface manageRespondentView : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIGestureRecognizerDelegate>
@property (strong,nonatomic) NSString *surveyId;
@end
