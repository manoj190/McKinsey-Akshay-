//
//  loginView.m
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "loginView.h"
#import "constant.h"
#import "loadingPage.h"
#import "Reachability.h"

@interface loginView ()
{
    loadingPage *loadingPageObj;
    NIDropDown *dropDown;

    IBOutlet UITextField *userNameTxt;
    IBOutlet UITextField *passwordTxt;
    IBOutlet UIButton *rememberMeCheckBox;
    IBOutlet UIButton *forgotPasswordBtn;
    IBOutlet UIButton *selectUserTypeBtn;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;

}
- (IBAction)loginBtnClicked:(id)sender;
- (IBAction)forgotPasswordBtnClicked:(id)sender;
- (IBAction)rememberMeBtnClicked:(id)sender;
- (IBAction)selectUserTypeBtnClicked:(id)sender;
@end

@implementation loginView
@synthesize declarationViewObj,forgotPasswordObj,dashboardObj,userManagementObj;
- (void)viewDidLoad
{
    [super viewDidLoad];
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    passwordTxt.secureTextEntry=YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self setUI];
}

-(void)setUI
{
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"REMEMBER_ME"] isEqualToString:@"YES"])
    {
        [rememberMeCheckBox setImage:[UIImage imageNamed:@"tick mark box.png"] forState:UIControlStateNormal];
        userNameTxt.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"USERNAME"];
        passwordTxt.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"PASSWORD"];
        [selectUserTypeBtn setTitle:[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_TYPE"] forState:UIControlStateNormal];
    }
    else
    {
        userNameTxt.text = @"";
        passwordTxt.text = @"";
    }
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    passwordTxt.attributedPlaceholder = str;
    
    str = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    userNameTxt.attributedPlaceholder = str;
    
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)loginBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else if ([selectUserTypeBtn.currentTitle isEqualToString:@"   Select User Type"])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please select user type"];
    }
    else if ([userNameTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter username"];
    }
    else if ([passwordTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter password"];
    }
    else
    {
        if ([selectUserTypeBtn.currentTitle isEqualToString:@"   SUPER ADMIN"])
        {
            
            if ([userNameTxt.text isEqualToString:@"Alive team lead"]&& [passwordTxt.text isEqualToString:@"pdcocalive"])
            {
                [self saveUserDataLocally:@"SUPER_ADMIN"];
                [[NSUserDefaults standardUserDefaults] setValue:selectUserTypeBtn.currentTitle forKey:@"USER_TYPE"];
                [[NSUserDefaults standardUserDefaults] setValue:userNameTxt.text forKey:@"USERNAME"];
                [[NSUserDefaults standardUserDefaults] setValue:passwordTxt.text forKey:@"PASSWORD"];

                userManagementObj = [[userManagement alloc]initWithNibName:@"userManagement" bundle:nil];
                [self.navigationController pushViewController:userManagementObj animated:YES];
                
            }
            else
            {
                [self showAlertView:@"Alive 2.0" message:@"Please check the username and password."];
                
            }
        }
        else
        {
            [self showLoader:YES];
            [self callLoginWebservice];
        }

    }
}

- (IBAction)forgotPasswordBtnClicked:(id)sender
{
    forgotPasswordObj = [[forgotPassword alloc]initWithNibName:@"forgotPassword" bundle:nil];
    [self.navigationController pushViewController:forgotPasswordObj animated:YES];
}

- (IBAction)rememberMeBtnClicked:(id)sender
{
    if ([rememberMeCheckBox.currentImage isEqual:[UIImage imageNamed:@"tick mark box.png"]])
    {
        [rememberMeCheckBox setImage:[UIImage imageNamed:@"untick mark box.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"REMEMBER_ME"];
    }
    else
    {
        [rememberMeCheckBox setImage:[UIImage imageNamed:@"tick mark box.png"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"REMEMBER_ME"];
    }
}

-(void)callLoginWebservice
{
    NSString *userUpdate;
    
    userUpdate =[NSString stringWithFormat:@"&USERNAME=%@&PASSWORD=%@&UDID=%@",userNameTxt.text,passwordTxt.text,[[NSUserDefaults standardUserDefaults]valueForKey:@"DEVICE_TOKEN"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"admin_login.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       
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
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"data"];
                                [self responseResult:infoArray];
                           }
                       }] resume];
                     });
}

-(void)responseResult:(NSArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count == 0)
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error in login"];
                       }
                       else if ([[[result objectAtIndex:0]valueForKey:@"STATUS"]isEqualToString:@"FAILED"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error in login"];
                       }
                       else if ([[[result objectAtIndex:0]valueForKey:@"STATUS"]isEqualToString:@"SUCCESS"] && [[[result objectAtIndex:0]valueForKey:@"AGREED_TERMS"]isEqualToString:@"Y"])
                       {
                           [self saveUserDataLocally:@"ADMIN"];
                           [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"ADMIN_ID"] forKey:@"ADMIN_ID"];
                           [[NSUserDefaults standardUserDefaults] setValue:userNameTxt.text forKey:@"USERNAME"];
                           [[NSUserDefaults standardUserDefaults] setValue:passwordTxt.text forKey:@"PASSWORD"];
                           [[NSUserDefaults standardUserDefaults] setValue:selectUserTypeBtn.currentTitle forKey:@"USER_TYPE"];

                           if ([selectUserTypeBtn.currentTitle isEqualToString:@"   SUPER ADMIN"])
                           {
                               if ([userNameTxt.text isEqualToString:@"Alive team lead"]&& [passwordTxt.text isEqualToString:@"pdcocalive"])
                               {
                                   [[NSUserDefaults standardUserDefaults] setValue:selectUserTypeBtn.currentTitle forKey:@"USER_TYPE"];
                                   userManagementObj = [[userManagement alloc]initWithNibName:@"userManagement" bundle:nil];
                                   [self.navigationController pushViewController:userManagementObj animated:YES];
                               }
                               else
                               {
                                   [self showAlertView:@"Alive 2.0" message:@"Please check the username and password."];
                               }
                           }
                           else
                           {
                              // [[NSUserDefaults standardUserDefaults] setValue:[selectUserTypeBtn.currentTitle stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"USER_TYPE"];
                               dashboardObj = [[dashboard alloc]initWithNibName:@"dashboard" bundle:nil];
                               [self.navigationController pushViewController:dashboardObj animated:YES];
                           }

                       }
                       else if ([[[result objectAtIndex:0]valueForKey:@"STATUS"]isEqualToString:@"SUCCESS"] && [[[result objectAtIndex:0]valueForKey:@"AGREED_TERMS"]isEqualToString:@"N"])
                       {
                           [self saveUserDataLocally:@"ADMIN"];
                           [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"ADMIN_ID"] forKey:@"ADMIN_ID"];
                           [[NSUserDefaults standardUserDefaults] setValue:userNameTxt.text forKey:@"USERNAME"];
                           [[NSUserDefaults standardUserDefaults] setValue:passwordTxt.text forKey:@"PASSWORD"];
                           [[NSUserDefaults standardUserDefaults] setValue:selectUserTypeBtn.currentTitle forKey:@"USER_TYPE"];

                           declarationViewObj = [[declarationView alloc]initWithNibName:@"declarationView" bundle:nil];
                           [self.navigationController pushViewController:declarationViewObj animated:YES];
                       }
                   });
}

-(void)saveUserDataLocally:(NSString *)userTypeStr
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:userNameTxt.text forKey:@"USERNAME"];
    [dict setValue:passwordTxt.text forKey:@"PASSWORD"];
    [dict setValue:userTypeStr forKey:@"USER_TYPE"];
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"Alive 2.0" message:msg];
    [self showLoader:NO];
}

- (IBAction)selectUserTypeBtnClicked:(id)sender
{
    NSArray * arr = [[NSArray alloc] initWithObjects:@"   SUPER ADMIN",@"   ADMIN", nil];
    NSArray * arrImage = [[NSArray alloc] init];
    if(dropDown == nil)
    {
        CGFloat f = 80;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down" :[UIImage imageNamed:@"umTxt.png"]];
        dropDown.delegate = self;
    }
    else
    {
        [dropDown hideDropDown:sender];
        [self rel];
    }
}

-(void)rel
{
    dropDown = nil;
    NSLog(@"Select user type = %@",selectUserTypeBtn.currentTitle);
    if ([selectUserTypeBtn.currentTitle isEqualToString:@"   SUPER ADMIN"])
    {
        forgotPasswordBtn.hidden = YES;
    }
    else
    {
        forgotPasswordBtn.hidden = NO;
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
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
    
        if (textField.tag == 100)
        {
            movementDistance = -220;
        }
        else
        {
            movementDistance = -220;
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
