//
//  commingSoon.m
//  mckinsey
//
//  Created by Mac on 22/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "commingSoon.h"
#import "dashboard.h"
#import "loginView.h"
#import "notifications.h"

@interface commingSoon ()
{
    IBOutlet UILabel *badgeCountLbl;
    IBOutlet UIImageView *badgeCountImg;
}
- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
@end

@implementation commingSoon

- (void)viewDidLoad
{
    [super viewDidLoad];
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
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
            badgeCountImg.hidden = NO;
            badgeCountLbl.hidden = NO;
        }
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    }
    */
    
    
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
    [self setBadgeNumber];
    notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
    [self.navigationController pushViewController:notificationViewObj animated:YES];

}
@end
