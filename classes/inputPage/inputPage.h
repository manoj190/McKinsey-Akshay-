//
//  inputPage.h
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "previewPage.h"
#import "NIDropDown.h"

@interface inputPage : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,NIDropDownDelegate>
@property (strong, nonatomic) previewPage *previewPageObj;
@property (strong, nonatomic) NSString *surveyName;
@property (strong, nonatomic) NSString *surveyID;

@end
