//
//  manageRespondentView.m
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "manageRespondentView.h"
#import "mgmtRespondentCell.h"
#import "reminderCustomCell.h"
#import "dashboard.h"
#import "constant.h"
#import "loadingPage.h"
#import "Reachability.h"
#import "dashboard.h"
#import "loginView.h"
#import "notifications.h"
#import "APIManager.h"

@interface manageRespondentView ()
{
    loadingPage *loadingPageObj;
    IBOutlet UITextField *usernameTxt;
    IBOutlet UITextField *emailIdTxt;
    IBOutlet UITextField *passwordTxt;
    IBOutlet UITextField *uploadLinkTxt;
    IBOutlet UITableView *mgmtRespondentTable;
    IBOutlet UIView *editRespondentView;
    IBOutlet UITextField *editPasswordTxt;
    IBOutlet UILabel *editUserNameLbl;
    IBOutlet UILabel *editEmailIdLbl;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UIView *addExistingUserView;
    IBOutlet UILabel *editSrNoLbl;
    IBOutlet UIView *addNewRespView;
    IBOutlet UIView *uploadLinkView;
    IBOutlet UITableView *reminderTable;
    IBOutlet UIView *reminderView;
    IBOutlet UILabel *badgeCountLbl;
    IBOutlet UIImageView *badgeCountImg;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    NSMutableArray *existingUserArr;
    NSMutableArray *respondentDetailsArr;
    NSMutableArray *respondentListArr;
    NSMutableArray *userNameArr;
    NSMutableArray *emailIdArr;
    NSMutableArray *reminderCountArr;

    int editRespondentIndex;

}
- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)submitBtnClicked:(id)sender;
- (IBAction)saveBtnClicked:(id)sender;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)sendReminderBtnClicked:(id)sender;
- (IBAction)addBtnClicked:(id)sender;
- (IBAction)addUserCancelBtnClicked:(id)sender;
- (IBAction)addNewRespondentBtnClicked:(id)sender;
- (IBAction)addExistingRespondetBtnClicked:(id)sender;
- (IBAction)uploadLinkBtnClicked:(id)sender;
- (IBAction)sendBtnClicked:(id)sender;
- (IBAction)cancelReminderBtnClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailIDTextField;








@end

@implementation manageRespondentView
@synthesize surveyId;
- (void)viewDidLoad
{
    [super viewDidLoad];

    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    UIColor *color = [UIColor lightGrayColor];
    usernameTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"User Name" attributes:@{NSForegroundColorAttributeName: color}];
    emailIdTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email ID" attributes:@{NSForegroundColorAttributeName: color}];
    passwordTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    uploadLinkTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Upload Link" attributes:@{NSForegroundColorAttributeName: color}];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
     [self setUI];
     [self showLoader:YES];
     [self callWebserviceToFetchRespondentList];
    }
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    //fetch Badge count
    [self setBadgeNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeNumber) name:@"setbadge" object:nil];
}

-(void)setBadgeNumber
{
    @try
    {
        //Fetch badge count from plist
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        badgeCountLbl.text = [[dict objectForKey:@"BADGE_COUNT"] stringValue];
        if ([[dict objectForKey:@"BADGE_COUNT"]intValue] == 0)
        {
            badgeCountImg.hidden = YES;
            badgeCountLbl.hidden = YES;
        }
        else
        {
            badgeCountImg.hidden = NO;
            badgeCountLbl.hidden = NO;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception occured");
    }
    @finally
    {
    }
}

-(void)setUI
{
    respondentListArr  = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)homeBtnClicked:(id)sender
{
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[dashboard class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutBtnClicked:(id)sender
{
 /*   NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[loginView class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
        else if ([obj isKindOfClass:[dashboard class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            [navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
        }
    }*/
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"data = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"]);

    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:0];
        if ([obj isKindOfClass:[loginView class]])
        {
            UINavigationController * navigationController = self.navigationController;
            [navigationController popToRootViewControllerAnimated:NO];
            return;
        }
        else if ([obj isKindOfClass:[dashboard class]])
        {
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            //[navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
        }
    }

}

- (IBAction)notificationBtnClicked:(id)sender
{
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeCountZeroInPlist];
    notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
    [self.navigationController pushViewController:notificationViewObj animated:YES];
}

-(void)setBadgeCountZeroInPlist
{
    NSMutableArray *nameArr = [[NSMutableArray alloc]init];
    int badgeCount = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    nameArr = [dict objectForKey:@"NOTIFICATION_DATA"];
    
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    if (nameArr != nil )
    {
        [plistDict setObject:nameArr forKey:@"NOTIFICATION_DATA"];
        [plistDict setValue:[NSNumber numberWithInt:badgeCount] forKey:@"BADGE_COUNT"];
    }
    else
    {
    }
    
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if(plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Data saved sucessfully");
    }
    else
    {
        NSLog(@"Data not saved");
    }
}

- (IBAction)submitBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else if([usernameTxt.text isEqualToString:@""] || [emailIdTxt.text isEqualToString:@""] || [passwordTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please fill all details"];
    }
    else if (![self validateEmail:emailIdTxt.text])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter valid email id"];
    }
    else
    {
      [self showLoader:YES];
      [self callWebserviceToAddRespondent];
    }
}


-(void)callWebserviceToFetchRespondentList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"respondantList.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&SURVEY_ID=%@",surveyId];
                       
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               [self errorResponse:@"Error fetching data"];
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"data"];
                               
                                [self fetchRespondentListresponseResult:infoArray];
                           }
                       }] resume];
                   });
}

-(void)fetchRespondentListresponseResult:(NSArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count  == 0)
                       {
                           [self showAlertView:@"Alive 2.0" message:@"No respondent found"];
                       }
                       else
                       {
                           respondentDetailsArr = [[[NSMutableArray alloc]initWithArray:result] mutableCopy];
                           [mgmtRespondentTable reloadData];
                       }
                   });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"Alive 2.0" message:msg];
    [self showLoader:NO];

}

-(void)callWebserviceToAddRespondent
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"addRespondant.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&EMAIL_ID=%@&PASSWORD=%@&SURVEY_ID=%@&RESPONDANT_USERNAME=%@&ADMIN_ID=%@&ADMIN_USERNAME=%@",emailIdTxt.text,passwordTxt.text,surveyId,usernameTxt.text,[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"],[[NSUserDefaults standardUserDefaults]valueForKey:@"USERNAME"]];
                       
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               [self errorResponse:@"Error saving data"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self addRespondentResponseResult:resStr];
                           }
                       }] resume];
                   });
}


-(void)addRespondentResponseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"EMAILIDALREADYEXISTS"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Email id already exists"];
                       }
                       else if ([result isEqualToString:@"RESPONDANTALREADYEXISTS"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Username already exists"];
                       }
                       else if ([result isEqualToString:@"SUCCESS"])
                       {
                           
//                           NSString *url = [NSString stringWithFormat:@"http://hardcastlegis.in/testwebmail.php"];
//                           NSString *param = [NSString stringWithFormat:@"&M=Test mail&T=%@&S=Register email",emailIdTxt.text];
//                           [[APIManager new] postRequest:url andParam:param withBlock:^(id response, BOOL isSuccess) {
//
//                               NSLog(@"%@",response);
//                           }];
                           
                           [self showAlertView:@"Alive 2.0" message:@"Respondent added succesfully"];
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                           [dict setObject:usernameTxt.text forKey:@"USERNAME"];
                           [dict setObject:passwordTxt.text forKey:@"PASSWORD"];
                           [dict setObject:emailIdTxt.text forKey:@"EMAIL_ID"];
                           [dict setObject:@"0" forKey:@"COUNT"];
                           [respondentDetailsArr addObject:dict];
                           [mgmtRespondentTable reloadData];
                           usernameTxt.text = @"";
                           passwordTxt.text = @"";
                           emailIdTxt.text  = @"";
                       }
                       else if([result isEqualToString:@"FAILED"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Failed to add respondent"];
                       }
                       else
                       {
                           [self showAlertView:@"Alive 2.0" message:@"No respondent found"];
                       }
                   });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    if (tableView == mgmtRespondentTable)
    {
        return respondentDetailsArr.count;
    }
    else
    {
        return userNameArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView == mgmtRespondentTable)
    {
      NSString *cellIdentifier = @"cell";
      mgmtRespondentCell *cell = [mgmtRespondentTable dequeueReusableCellWithIdentifier:cellIdentifier];
      if (cell == nil)
     {
         NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"mgmtRespondentCell" owner:self options:nil];
         cell = [nib objectAtIndex:0];
     }
     cell.contentView.backgroundColor = [UIColor clearColor];
     cell.backgroundColor = [UIColor clearColor];
     mgmtRespondentTable.backgroundColor = [UIColor clearColor];
     mgmtRespondentTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
     cell.selectedBackgroundView = [UIView new];
     cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:19.0/255.0 blue:30.0/255.0 alpha:0.9];
        cell.srNoLbl.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
        if ([self checkForNullString:[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"USERNAME"]])
        {
            cell.nameLbl.text = @"";
        }
        else
        {
            cell.nameLbl.text = [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"USERNAME"];
        }
     
        if ([self checkForNullString:[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"PASSWORD"]])
        {
          cell.passwordLbl.text = @"";
        }
        else
        {
            cell.passwordLbl.text = [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"PASSWORD"];
        }
        
        if ([self checkForNullString:[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"]])
        {
            cell.emailIdLbl.text = @"";
        }
        else
        {
            cell.emailIdLbl.text = [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"];
        }
        
        if ([self checkForNullString:[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ATTENDED_STATUS"]])
        {
            cell.emailIdLbl.text = @"";
        }
        else
        {
            if ([[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ATTENDED_STATUS"]  isEqual: @"Y"]) {
                cell.userAttendedStatus.text = @"Yes";
            }else {
                cell.userAttendedStatus.text = @"No";
            }
            
        }
        
     [cell.editBtn addTarget:self action:@selector(editBtnclicked:) forControlEvents:UIControlEventTouchUpInside];
     [cell.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
      return cell;
    }
    else
    {
        NSString *cellIdentifier = @"cell";
        reminderCustomCell *cell = [reminderTable dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"reminderCustomCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        reminderTable.backgroundColor = [UIColor clearColor];
        reminderTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:19.0/255.0 blue:30.0/255.0 alpha:0.9];
        cell.usernameTxt.text = [userNameArr objectAtIndex:indexPath.row];
        cell.reminderCountTxt.text = [reminderCountArr objectAtIndex:indexPath.row];
        [cell.tickBtn addTarget:self action:@selector(tickBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

        if ([[emailIdArr objectAtIndex:indexPath.row] isEqualToString:@" "])
        {
            [cell.tickBtn setBackgroundImage:[UIImage imageNamed:@"untickmark.png"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.tickBtn setBackgroundImage:[UIImage imageNamed:@"tickmark.png"] forState:UIControlStateNormal];
        }
        
        return cell;
    }
}

-(BOOL)checkForNullString:(NSString *)str
{
    if ([str isEqual:[NSNull null]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [respondentListArr addObject:[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"]];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0; i<respondentListArr.count; i++)
    {
        if ([[respondentListArr objectAtIndex:i] isEqualToString:[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"]])
        {
            [respondentListArr removeObjectAtIndex:i];
        }
    }
}

- (IBAction)sendReminderBtnClicked:(id)sender
{
    addNewRespView.hidden = YES;
    if (respondentDetailsArr.count > 0)
    {
        userNameArr = [[NSMutableArray alloc]init];
        emailIdArr = [[NSMutableArray alloc]init];
        reminderCountArr = [[NSMutableArray alloc]init];
        
        for (int i = 0; i<respondentDetailsArr.count; i++)
        {
            [userNameArr addObject:[[respondentDetailsArr objectAtIndex:i]valueForKey:@"USERNAME"]];
            [emailIdArr addObject:[[respondentDetailsArr objectAtIndex:i]valueForKey:@"EMAIL_ID"]];
            if (![[[respondentDetailsArr objectAtIndex:i]valueForKey:@"COUNT"] isEqual:[NSNull null]]) {
                [reminderCountArr addObject:[[respondentDetailsArr objectAtIndex:i]valueForKey:@"COUNT"]];
            }
            else {
                [reminderCountArr addObject:@"0"];
            }
        }
        [reminderTable reloadData];
        [self.view addSubview:reminderView];
    }
    else
    {
        [self showAlertView:@"Alive 2.0" message:@"No respondent found"];
    }
}

- (IBAction)sendBtnClicked:(id)sender
{
    NSMutableArray *respondentArr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<emailIdArr.count; i++)
    {
        if ([[emailIdArr objectAtIndex:i] isEqualToString:@" "])
        {
            
        }
        else
        {
            if (![[emailIdArr objectAtIndex:i] isEqual:[NSNull null]]) {
                [respondentArr addObject:[emailIdArr objectAtIndex:i]];
            }
        }
    }
        [self showLoader:YES];
        NSMutableDictionary *repondentListDict = [[NSMutableDictionary alloc]init];
        [repondentListDict setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"USERNAME"] forKey:@"ADMIN_NAME"];
        [repondentListDict setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"] forKey:@"ADMIN_ID"];
        [repondentListDict setObject:surveyId forKey:@"SURVEY_ID"];
        [repondentListDict setObject:respondentArr forKey:@"RESPONDANT_EMAIL"];
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
        [dataDict setObject:repondentListDict forKey:@"DATA"];
        [self callWebserviceToSendReminder:dataDict];
}

- (IBAction)cancelReminderBtnClicked:(id)sender
{
    [reminderView removeFromSuperview];
}

- (void)tickBtnClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:reminderTable];
    NSIndexPath *indexPath = [reminderTable indexPathForRowAtPoint:buttonPosition];
    
    if ([[emailIdArr objectAtIndex:indexPath.row] isEqualToString:@" "])
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"tickmark.png"] forState:UIControlStateNormal];
        [emailIdArr replaceObjectAtIndex:indexPath.row withObject:[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"]];
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"untickmark.png"] forState:UIControlStateNormal];
        [emailIdArr replaceObjectAtIndex:indexPath.row withObject:@" "];
    }
}
//manoj changed for table
- (IBAction)addBtnClicked:(id)sender
{
//    [self showLoader:YES];
    bool continueLoop = 1;
//    [self showLoader:YES];
    NSString *selectedId = [[existingUserArr objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"RESPONDANT_ID"];
    NSLog(@"existing user ids:%@",[respondentDetailsArr valueForKey:@"RESPONDANT_ID"]);
    int i;
    if (continueLoop == 1) {
    for (i = 0; i < [respondentDetailsArr count]; i++) {
        id myArrayElement = [respondentDetailsArr objectAtIndex:i];
        if (selectedId == [myArrayElement valueForKey:@"RESPONDANT_ID"]) {
            NSLog(@"User already existing:%@",[myArrayElement valueForKey:@"RESPONDANT_ID"]);
            continueLoop = 0;
            [self showAlertView:@"Alive 2.0" message:@"This user is already existing."];
            goto myLabel;
        }
        }
    myLabel:;
        [self showLoader:NO];
        if (continueLoop == 1) {
            [self showLoader:YES];
            [self callWebserviceToAddExistingRespondent:selectedId :[[existingUserArr objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"EMAIL_ID"]];
        }
        
    }
    
    
//    [self callWebserviceToAddExistingRespondent:selectedId :[[existingUserArr objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"EMAIL_ID"]];
}


//{
//    [self showLoader:YES];
//    NSString *selectedId = [[existingUserArr objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"RESPONDANT_ID"];
//    if ([infoArray count] != 0) {
////        NSLog(@"sfsggdfgdg");
//
//
//    if ([[infoArray objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"RESPONDANT_ID"] == selectedId) {
//        NSLog(@"already exists this respondent for this survey");
//
//        [self showAlertView:@"Alive 2.0" message:@"Respondent already exist for this survey"];
////        [loadingPageObj.view removeFromSuperview];
//        [self showLoader:NO];
//    }else {
//
//    [self callWebserviceToAddExistingRespondent:selectedId :[[existingUserArr objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"EMAIL_ID"]];
//    }
//    }else {
//       [self callWebserviceToAddExistingRespondent:selectedId :[[existingUserArr objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"EMAIL_ID"]];
//    }
//
//
//}

- (IBAction)addUserCancelBtnClicked:(id)sender
{
    [addExistingUserView removeFromSuperview];
}

- (IBAction)addNewRespondentBtnClicked:(id)sender
{
    addNewRespView.hidden = NO;
    [uploadLinkView removeFromSuperview];
    [addNewRespView setFrame:CGRectMake(0, 190, 1024, 134)];
    [self.view addSubview:addNewRespView];
}

- (IBAction)addExistingRespondetBtnClicked:(id)sender
{
    [addNewRespView removeFromSuperview];
    [uploadLinkView removeFromSuperview];

    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
        [self showLoader:YES];
        [self callWebserviceToFetchExistingUsers];
    }

}

- (IBAction)uploadLinkBtnClicked:(id)sender
{
    [addNewRespView removeFromSuperview];
    [uploadLinkView setFrame:CGRectMake(0, 190, 1024, 134)];
    [self.view addSubview:uploadLinkView];
}

-(void)editBtnclicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
     CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:mgmtRespondentTable];
     NSIndexPath *indexPath = [mgmtRespondentTable indexPathForRowAtPoint:buttonPosition];
     [self.view addSubview:editRespondentView];
     [editPasswordTxt becomeFirstResponder];
     editRespondentIndex = indexPath.row;
     editSrNoLbl.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    
        
//        editUserNameLbl.text = [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"USERNAME"];
        _userNameTextField.text = [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"USERNAME"];
        
//     editEmailIdLbl.text =  [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"];
        _emailIDTextField.text =  [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"];
        
     editPasswordTxt.text = [[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"PASSWORD"];
    }
}

- (IBAction)saveBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
       [self showLoader:YES];
       [self callWebserviceToEditRespondent :_emailIDTextField.text :editPasswordTxt.text :[editSrNoLbl.text integerValue]];
    }
}

- (IBAction)cancelBtnClicked:(id)sender
{
    [editRespondentView removeFromSuperview];
}

-(void)deleteBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Logout"
                                         message:@"Are you sure Want to delete this user?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Yes"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            
                                            [self showLoader:YES];
                                            CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:mgmtRespondentTable];
                                            NSIndexPath *indexPath = [mgmtRespondentTable indexPathForRowAtPoint:buttonPosition];
                                            [self callWebserviceToDeleteRespondent:surveyId :[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"] :indexPath.row];
                                        }];
            
            UIAlertAction* noButton = [UIAlertAction
                                       actionWithTitle:@"No"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle no, thanks button
                        
                                       }];
            
            //Add your buttons to alert controller
            
            [alert addAction:yesButton];
            [alert addAction:noButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        
//     [self showLoader:YES];
//     CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:mgmtRespondentTable];
//     NSIndexPath *indexPath = [mgmtRespondentTable indexPathForRowAtPoint:buttonPosition];
//     [self callWebserviceToDeleteRespondent:surveyId :[[respondentDetailsArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"] :indexPath.row];
    }
}

-(void)callWebserviceToEditRespondent :(NSString *)emailID  :(NSString *)password :(int)index
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"editRespondant.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"EMAIL_ID=%@&SURVEY_ID=%@&PASSWORD=%@",emailID,surveyId,password];
                       // changed by manoj
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               [self errorResponse:@"Error saving data"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self editRespondentResponseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)editRespondentResponseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Password edited successfully & mail sent to user"];
                           NSLog(@"respondentDetailsArr = %@",respondentDetailsArr);
                           
                           NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[respondentDetailsArr objectAtIndex:editRespondentIndex]];
                           [dict setObject:editPasswordTxt.text forKey:@"PASSWORD"];
                           [respondentDetailsArr replaceObjectAtIndex:editRespondentIndex withObject:dict];
                           [editRespondentView removeFromSuperview];
                           [mgmtRespondentTable reloadData];
                       }
                       else if([result isEqualToString:@"NORESPONDANTFOUND"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Email id not found"];
                       }
                       else if([result isEqualToString:@"FAILED"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error editing password"];
                       }
                   });
}


-(void)callWebserviceToDeleteRespondent :(NSString *)surveyIdStr :(NSString *)emailId :(int)index
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"delete.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&EMAIL_ID=%@&SURVEY_ID=%@&ADMIN_ID=%@",emailId,surveyIdStr,[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"]];
                       
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               [self errorResponse:@"Error deleting respondent"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self deleteRespondentResponseResult:resStr :index];
                           }
                       }] resume];
                   });
}

-(void)deleteRespondentResponseResult:(NSString  *)result :(int)index
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Respondent deleted successfully"];
                           [respondentDetailsArr removeObjectAtIndex:index];
                           [mgmtRespondentTable reloadData];
                       }
                       else if([result isEqualToString:@"NO RESPONDANT FOUND"])
                       {
                            [self showAlertView:@"Alive 2.0" message:@"Respondent email id not found"];
                       }
                   });
}

-(void)callWebserviceToSendReminder:(NSMutableDictionary *)dict
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSError * err;
                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dict options:0 error:&err];
                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                       NSURL *url = [NSURL URLWithString:[constantUrl stringByAppendingString:@"sendReminder.php"]];
                       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                       
                       NSData *requestData = [myString dataUsingEncoding:NSUTF8StringEncoding];
                       [request setHTTPMethod:@"POST"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                       [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
                       [request setHTTPBody: requestData];
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               [self errorResponse:@"Error sending reminder"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self sendReminderResponseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)sendReminderResponseResult : (NSString *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [reminderView removeFromSuperview];
                           [self showAlertView:@"Alive 2.0" message:@"Reminder sent successfully"];
                           [self showLoader:YES];
                           [self callWebserviceToFetchRespondentList];
                       }
                       else
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error sending reminder"];
                       }
                   });
}

-(void)callWebserviceToFetchExistingUsers
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"showExistingRespondant.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&ADMIN_ID=%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"]];
                       
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               [self errorResponse:@"Error fetching data"];
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               existingUserArr = [infoDictionary valueForKey:@"data"];
                               [self fetchExistingUserResponseResult:existingUserArr];
                           }
                       }] resume];
                   });
}

-(void)fetchExistingUserResponseResult:(NSArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count == 0)
                       {
                           [self showAlertView:@"Alive 2.0" message:@"No existing respondent found"];
                       }
                       else
                       {    printf("%s", result);
                           [self.view addSubview:addExistingUserView];
                           [pickerView reloadAllComponents];
                       }
                    });
}

-(void)callWebserviceToAddExistingRespondent:(NSString *)respondentId :(NSString *)emailId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"addExistingRespondant.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&RESPONDANT_ID=%@&SURVEY_ID=%@&EMAIL_ID=%@&ADMIN_USERNAME=%@",respondentId,surveyId,emailId,[[NSUserDefaults standardUserDefaults]valueForKey:@"USERNAME"]];
                       
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               [self errorResponse:@"Error adding respondent"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self addExistingRespondentResponseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)addExistingRespondentResponseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];

                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [addExistingUserView removeFromSuperview];
                           [self showAlertView:@"Alive 2.0" message:@"Respondent added successfully"];
                           [self showLoader:YES];
                           [self callWebserviceToFetchRespondentList];
                       }
                       else
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error adding respondent"];
                       }
                       [pickerView reloadAllComponents];
                   });
}

#pragma marks - pickerview datasources

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return existingUserArr.count;
}
//manoj changed - username required
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[existingUserArr objectAtIndex:row]valueForKey:@"USERNAME"];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    int movementDistance = 0;
    
    if (textField.tag == 101)
    {
         movementDistance = -120;
    }
    
    const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

-(BOOL) validateEmail:(NSString*) emailString
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    if (regExMatches == 0) {
        return NO;
    }
    else
        return YES;
}

-(void)showLoader : (BOOL)status
{
    if (status==YES)
    {
        [self.view addSubview:loadingPageObj.view];
    }
    else
    {
        [loadingPageObj.view removeFromSuperview];
    }
}

-(void)showAlertView:(NSString *)title message:(NSString *)msg
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}



@end
