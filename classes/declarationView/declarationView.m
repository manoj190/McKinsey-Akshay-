//
//  declarationView.m
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "declarationView.h"
#import "loginView.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "constant.h"
#import "loadingPage.h"

@interface declarationView ()
{
    loadingPage *loadingPageObj;

    IBOutlet UITextView *declarationTxt;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;

}
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)agreeBtnClicked:(id)sender;
@end

@implementation declarationView
@synthesize dashboardObj,userManagementObj;
- (void)viewDidLoad
{
    [super viewDidLoad];
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)logoutBtnClicked:(id)sender
{
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:i];
        if([obj isKindOfClass:[loginView class]])
        {
            [[self navigationController] popToViewController:obj animated:YES];
            return;
        }
    }
}

- (IBAction)notificationBtnClicked:(id)sender
{
    
}

- (IBAction)agreeBtnClicked:(id)sender
{
    [self showLoader:YES];
    [self callAgreeWebservice];
}

-(void)callAgreeWebservice
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"agreeTerms.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&TYPE=%@&ID=%@",@"ADMIN",[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"]];
                       
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
                           if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"USER_TYPE"] isEqualToString:@"SUPER ADMIN"])
                           {
                               userManagementObj = [[userManagement alloc]initWithNibName:@"userManagement" bundle:nil];
                               [self.navigationController pushViewController:userManagementObj animated:YES];
                           }
                           else
                           {
                               dashboardObj = [[dashboard alloc]initWithNibName:@"dashboard" bundle:nil];
                               [self.navigationController pushViewController:dashboardObj animated:YES];
                           }
                       }
                       else
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error saving data"];
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


@end
