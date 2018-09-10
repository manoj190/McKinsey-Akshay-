//
//  userManagement.m
//  mckinsey
//
//  Created by Mac on 23/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "userManagement.h"
#import "userManagementCell.h"
#import "dashboard.h"
#import "loginView.h"
#import "constant.h"
#import "loadingPage.h"
#import "Reachability.h"
#import "notifications.h"

@interface userManagement ()
{
    NIDropDown *dropDown;
    loadingPage *loadingPageObj;
    
    IBOutlet UITableView *userMgmtTable;
    __weak IBOutlet UITextField *userNameTxt;
    IBOutlet UITextField *emailIdTxt;
    IBOutlet UITextField *passwordTxt;
    IBOutlet UITextField *companyNameTxt;
    IBOutlet UIView *editUserView;
    IBOutlet UILabel *editUserNameLbl;
    IBOutlet UILabel *editEmailIdLbl;
    IBOutlet UITextField *editPasswordTxt;
    IBOutlet UILabel *companyNameLbl;
    IBOutlet UILabel *daysOfInstallationLbl;
    IBOutlet UILabel *daysToExpireLbl;
    IBOutlet UIView *infoView;
    IBOutlet UILabel *badgeCountLbl;
    IBOutlet UIImageView *badgeCountImg;
    IBOutlet UIButton *notificationBellBtn;
    
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    NSMutableDictionary *userInfoDict;
    NSMutableArray *userInfoArray;
    NSString *emailId;
    NSMutableArray *userInfoArr;
    NSInteger tableIndex;
}
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)submitBtnClicked:(id)sender;
- (IBAction)saveEditedPasswordBtnClicked:(id)sender;
- (IBAction)cancelEditViewBtnClicked:(id)sender;
- (IBAction)sendReminderBtnClicked:(id)sender;
- (IBAction)closeBtnClicked:(id)sender;

@end

@implementation userManagement

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
}

-(void)setUI
{
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    UIColor *color = [UIColor lightGrayColor];
    emailIdTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email ID" attributes:@{NSForegroundColorAttributeName: color}];
    passwordTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    userNameTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    companyNameTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Company Name" attributes:@{NSForegroundColorAttributeName: color}];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    notificationBellBtn.hidden = YES;
    [self showLoader:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self callWebserviceToFetchUserList];
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeNumber) name:@"setbadge" object:nil];
}

-(void)setBadgeNumber
{
    NSLog(@"In bagde counter");
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
            badgeCountImg.hidden = YES;
            badgeCountLbl.hidden = YES;
        }
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutBtnClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"data = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"]);

    NSArray *viewControllers = [[self navigationController] viewControllers];
    
    
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[loginView class]])
        {
            UINavigationController * navigationController = self.navigationController;
            [navigationController popToRootViewControllerAnimated:NO];
            return;
        }
        else if ([obj isKindOfClass:[userManagement class]])
        {
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            //[navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
        }
    }

    /*
     for( int i=0;i<[viewControllers count];i++)
     {
     id obj=[viewControllers objectAtIndex:0];
     if([obj isKindOfClass:[loginView class]])
     {
     [[self navigationController] popToViewController:obj animated:YES];
     return;
     }
     else if ([obj isKindOfClass:[userManagement class]])
     {
     [[self navigationController] popToViewController:obj animated:YES];
     loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
     UINavigationController * navigationController = self.navigationController;
     [navigationController popToRootViewControllerAnimated:NO];
     [navigationController pushViewController:loginViewObj animated:NO];
     return;
     }
     }

     */
    
}

- (IBAction)notificationBtnClicked:(id)sender
{
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeNumber];
    notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
    [self.navigationController pushViewController:notificationViewObj animated:YES];
}

-(void)callWebserviceToFetchUserList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"fetchUserList.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       //  userUpdate =[NSString stringWithFormat:@"&SURVEY_ID=%@",surveyId];
                       
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
                               
                               [self fetchUserListresponseResult:infoArray];
                           }
                       }] resume];
                   });
}

-(void)fetchUserListresponseResult:(NSArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result == nil)
                       {
                           [self showAlertView:@"Alive 2.0" message:@"No respondent found"];
                       }
                       else
                       {
                           userInfoArr = [[NSMutableArray alloc]initWithArray:result];
                           [userMgmtTable reloadData];
                       }
                   });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"Alive 2.0" message:msg];
    [self showLoader:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return userInfoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *cellIdentifier = @"cell";
    userManagementCell *cell = [userMgmtTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"userManagementCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    userMgmtTable.backgroundColor = [UIColor clearColor];
    userMgmtTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.srNoLbl.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    cell.userNameLbl.text = [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"USERNAME"];
    cell.passwordLbl.text = [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"PASSWORD"];
    cell.emailIdLbl.text = [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"];
    [cell.deleteBtn addTarget:self action:@selector(deleteUserBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editBtn addTarget:self action:@selector(editUserBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.infoBtn addTarget:self action:@selector(infoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)submitBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else if([userNameTxt.text isEqualToString:@""] || [emailIdTxt.text isEqualToString:@""] || [passwordTxt.text isEqualToString:@""]||[companyNameTxt.text isEqualToString:@""])
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
        [self callWebserviceToAddNewUser];
    }
}


-(void)deleteUserBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:userMgmtTable];
        NSIndexPath *indexPath = [userMgmtTable indexPathForRowAtPoint:buttonPosition];
        tableIndex = indexPath.row;
        [self showLoader:YES];
        [self callWebserviceToDeleteUser:[[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"]];
    }
}

-(void)editUserBtnClicked:(id)sender
{
    [self.view addSubview:editUserView];
    [editPasswordTxt becomeFirstResponder];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:userMgmtTable];
    NSIndexPath *indexPath = [userMgmtTable indexPathForRowAtPoint:buttonPosition];
    tableIndex = indexPath.row;
    editUserNameLbl.text = [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"USERNAME"];
    editEmailIdLbl.text =  [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"];
    editPasswordTxt.text = [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"PASSWORD"];
}

- (IBAction)saveEditedPasswordBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
        [self showLoader:YES];
        [self callWebserviceToEditUser:editEmailIdLbl.text :editPasswordTxt.text];
    }
}

- (IBAction)cancelEditViewBtnClicked:(id)sender
{
    [editUserView removeFromSuperview];
}

-(void)infoBtnClicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:userMgmtTable];
    NSIndexPath *indexPath = [userMgmtTable indexPathForRowAtPoint:buttonPosition];
    companyNameLbl.text = [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"COMPANY_NAME"];
    emailId = [[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"];
    [self showLoader:YES];
    [self callWebserviceToFetchInfo:[[userInfoArr objectAtIndex:indexPath.row]valueForKey:@"EMAIL_ID"]];
}

- (IBAction)sendReminderBtnClicked:(id)sender
{
    [self showLoader:YES];
    [self callWebserviceToSendReminder:emailId];
}

- (IBAction)closeBtnClicked:(id)sender
{
    [infoView removeFromSuperview];
}

-(void)callWebserviceToSendReminder:(NSString *)emailIdStr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"licenseExpiryReminder.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       userUpdate =[NSString stringWithFormat:@"&EMAIL_ID=%@&DAYS_LEFT=%@&ADMIN_USERNAME=%@",emailIdStr,daysToExpireLbl.text,[[NSUserDefaults standardUserDefaults]valueForKey:@"USERNAME"]];
                       
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
                               [self errorResponse:@"Error sending reminder"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               
                               [self sendReminderResponseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)sendReminderResponseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"ConnectedtoAPNS.SUCCESS"])
                       {
                           [self showAlertView:@"SUCCESS" message:@"Reminder sent successfully"];
                       }
                       else
                       {
                           [self showAlertView:@"Error" message:@"Error sending reminder"];
                       }
                   });
}

-(void)callWebserviceToFetchInfo:(NSString *)EmailId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"adminInfoDetail.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       userUpdate =[NSString stringWithFormat:@"&EMAIL_ID=%@",EmailId];
                       
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
                               [self errorResponse:@"Error in login"];
                           }
                           else
                           {
                               userInfoDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               NSLog(@"User info dict = %@",userInfoDict);
                               userInfoArray = [userInfoDict valueForKey:@"data"];
                               
                               [self fetchInfoResponseResult:userInfoArray];
                           }
                       }] resume];
                   });
}

-(void)fetchInfoResponseResult:(NSMutableArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (result.count == 0)
                       {
                           [self showAlertView:@"Error" message:@"Error fetching admin info"];
                       }
                       else
                       {
                           daysToExpireLbl.text = [[[result objectAtIndex:0]valueForKey:@"DAYS_LEFT"] stringValue];
                           daysOfInstallationLbl.text = [[result objectAtIndex:0]valueForKey:@"INSTALLATION_DATE"];
                           [self.view addSubview:infoView];
                       }
                       [self showLoader:NO];
                       
                   });
}

-(void)callWebserviceToAddNewUser
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"addUser2.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       userUpdate =[NSString stringWithFormat:@"&USERNAME=%@&EMAIL_ID=%@&PASSWORD=%@&COMPANY_NAME=%@&ADMIN_USERNAME=%@",userNameTxt.text,emailIdTxt.text,passwordTxt.text,companyNameTxt.text, [[NSUserDefaults standardUserDefaults]valueForKey:@"USERNAME"]];
                       
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
                               [self errorResponse:@"Error in login"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               
                               [self addUserResponseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)addUserResponseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           NSMutableDictionary *newUserData = [[NSMutableDictionary alloc]init];
                           [newUserData setObject:userNameTxt.text forKey:@"USERNAME"];
                           [newUserData setObject:emailIdTxt.text forKey:@"EMAIL_ID"];
                           [newUserData setObject:passwordTxt.text forKey:@"PASSWORD"];
                           [newUserData setObject:companyNameTxt.text forKey:@"COMPANY_NAME"];
                           [userInfoArr addObject:newUserData];
                           [userMgmtTable reloadData];
                           [self setTextFields];
                           [self showAlertView:@"ALIVE 2.0" message:@"User added successfully"];
                       }
                       else if ([result isEqualToString:@"USERALREADYEXISTS"])
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"USER ALREADY EXISTS"];
                       }
                       else
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"Error adding user"];
                       }
                   });
}

-(void)setTextFields
{
    userNameTxt.text = @"";
    emailIdTxt.text = @"";
    passwordTxt.text = @"";
    companyNameTxt.text = @"";
}

-(void)callWebserviceToDeleteUser:(NSString *)EmailId
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"deleteUser.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       userUpdate =[NSString stringWithFormat:@"&EMAIL_ID=%@",EmailId];
                       
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
                               [self errorResponse:@"Error in login"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self deleteUserResponseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)deleteUserResponseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [userInfoArr removeObjectAtIndex:tableIndex];
                           [userMgmtTable reloadData];
                           [self showAlertView:@"SUCCESS" message:@"User deleted successfully"];
                       }
                       else
                       {
                           [self showAlertView:@"ERROR" message:@"Error deleting user"];
                       }
                   });
}

-(void)callWebserviceToEditUser:(NSString *)emailId :(NSString *)password
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"editUser.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       userUpdate =[NSString stringWithFormat:@"&EMAIL_ID=%@&PASSWORD=%@",emailId,password];
                       
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
                               [self errorResponse:@"Error in login"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self editUserResponseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)editUserResponseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[userInfoArr objectAtIndex:tableIndex]];
                           [dict setObject:editPasswordTxt.text forKey:@"PASSWORD"];
                           [userInfoArr replaceObjectAtIndex:tableIndex withObject:dict];
                           [editUserView removeFromSuperview];
                           [userMgmtTable reloadData];
                           [self showAlertView:@"SUCCESS" message:@"Password edited successfully"];
                       }
                       else
                       {
                           [self showAlertView:@"ERROR" message:@"Error editing password"];
                       }
                   });
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
        movementDistance = -150;
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
