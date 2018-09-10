//
//  forgotPassword.m
//  mckinsey
//
//  Created by Mac on 26/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "forgotPassword.h"
#import "constant.h"
#import "loadingPage.h"
#import "Reachability.h"

@interface forgotPassword ()
{
    loadingPage *loadingPageObj;
    IBOutlet UITextField *userNameTxt;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
}
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)submitBtnClicked:(id)sender;

@end

@implementation forgotPassword

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
}

-(void)setUI
{
//    UIColor *color = [UIColor whiteColor];
//    userNameTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Enter Email ID" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] }];
    userNameTxt.attributedPlaceholder = str;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitBtnClicked:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else if ([userNameTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter email id"];
    }
    else if (![self validateEmail:userNameTxt.text])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter valid email id"];
    }
    else
    {
        [self showLoader:YES];
        [self callForgotPasswordWebservice];
    }
}

-(BOOL) validateEmail:(NSString*) emailString
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    if (regExMatches == 0)
    {
        return NO;
    }
    else
        return YES;
}

-(void)callForgotPasswordWebservice
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"forgot_password.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&EMAIL_ID=%@",userNameTxt.text];
                       
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
                               [self errorResponse:@"Error sending mail"];
                           }
                           else
                           {
                                   NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                                   resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                   resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                                   [self responseResult:resStr];
                           }
                       }] resume];
                   });
}

-(void)responseResult:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           userNameTxt.text = @"";
                           [self showAlertView:@"Alive 2.0" message:@"Check your mail for password"];
                       }
                       else if ([result isEqualToString:@"NOACCOUNTFOUND"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"You are not registered with McKinsey"];
                       }
                       else
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error sending password"];
                       }
                   });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"Alive 2.0" message:msg];
    [self showLoader:NO];

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
                                handler:^(UIAlertAction * action)
    {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



@end
