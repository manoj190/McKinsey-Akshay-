//
//  AppDelegate.h
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "loginView.h"
#import "featurePrioritization.h"
#import "previewPage.h"
#import "inputPage.h"
#import "fpOutput.h"
#import "fpOutput2.h"
#import "fpUsingMdOutput.h"
#import "maxDiffOutput.h"
#import "featurePrioritization.h"
//#import <UserNotifications/UserNotifications.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) loginView *loginViewObj;
@property (strong, nonatomic) featurePrioritization *featurePrioritizationObj;
@property (strong, nonatomic) previewPage *previewPageObj;
@property (strong, nonatomic) inputPage *inputPageObj;
//@property (strong, nonatomic) fpOutput *fpOutputObj;
@property (strong, nonatomic) fpOutput2 *fpOutputObj;
@property (strong, nonatomic) fpUsingMdOutput *fpUsingMdOutputObj;
@property (strong, nonatomic) maxDiffOutput *maxDiffOutputObj;

@property (strong, nonatomic) UINavigationController *navObj;
@end

