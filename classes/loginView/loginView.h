//
//  loginView.h
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "declarationView.h"
#import "forgotPassword.h"
#import "dashboard.h"
#import "NIDropDown.h"
#import "userManagement.h"
@interface loginView : UIViewController<UITextFieldDelegate,NIDropDownDelegate>
@property (strong, nonatomic) declarationView *declarationViewObj;
@property (strong, nonatomic) forgotPassword *forgotPasswordObj;
@property (strong, nonatomic) dashboard *dashboardObj;
@property (strong, nonatomic) userManagement *userManagementObj;

@end
