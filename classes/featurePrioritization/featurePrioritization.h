//
//  featurePrioritization.h
//  mckinsey
//
//  Created by Mac on 22/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"
#import "previewPage.h"
@interface featurePrioritization : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,NIDropDownDelegate>
@property (strong, nonatomic) previewPage *previewPageObj;
@property (strong, nonatomic) NSString *surveyName;
@property (strong, nonatomic) NSString *surveyID;
@property (strong, nonatomic) NSString *surveyCurrency;

@end
