//
//  notifications.m
//  mckinsey
//
//  Created by Mac on 14/12/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "notifications.h"
#import "dashboard.h"
#import "loginView.h"
#import "notificationCell.h"
#import "notificationCell.h"
#import "loadingPage.h"
#import "Reachability.h"

@interface notifications ()
{
    loadingPage *loadingPageObj;

    IBOutlet UITableView *notificationTable;
    IBOutlet UIImageView *notificationBarImg;
    IBOutlet UILabel *notificationBarLbl;
    NSMutableArray *notificationData;
    
}
- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;

@end

@implementation notifications

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchNotificationdataFromPlist];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNotificationdataFromPlist) name:@"setbadge" object:nil];
}

-(void)fetchNotificationdataFromPlist
{
    //Fetch notification from plist
    notificationData = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    notificationData = [dict objectForKey:@"NOTIFICATION_DATA"];
    if (notificationData.count == 0)
    {
        notificationBarImg.hidden = YES;
        notificationBarLbl.hidden = YES;
        [self showAlertView:@"Notice" message:@"There are no notifications"];
    }
    else
    {
        notificationBarImg.hidden = NO;
        notificationBarLbl.hidden = NO;
    }
    [self setBadgeCountZero];
    [notificationTable reloadData];
}

-(void)setBadgeCountZero
{
    NSMutableArray *nameArr = [[NSMutableArray alloc]init];
    int badgeCount = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    nameArr = [dict objectForKey:@"NOTIFICATION_DATA"];
    badgeCount = (int)[[dict objectForKey:@"BADGE_COUNT"] integerValue];
    badgeCount = 0;
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return notificationData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"cell";
    notificationCell *cell = [notificationTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"notificationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.notificationText.text = [[notificationData objectAtIndex:indexPath.row]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)deleteBtnClicked:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Alert"
                                 message:@"Are you sure you want to delete this notification?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self showLoader:YES];
                                    UIButton *button = (UIButton *)sender;
                                    CGRect buttonFrame = [button convertRect:button.bounds toView:notificationTable];
                                    NSIndexPath *indexPath = [notificationTable indexPathForRowAtPoint:buttonFrame.origin];
                                    [notificationData removeObjectAtIndex:indexPath.row];
                                    [self saveNewNotificationArrayToPlist:notificationData];
                                    [notificationTable reloadData];

                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Handle your yes please button action here
                               }];
    
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)saveNewNotificationArrayToPlist:(NSMutableArray *)notificationArr
{
    int badgeCount = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
    
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    [plistDict setObject:notificationArr forKey:@"NOTIFICATION_DATA"];
    [plistDict setValue:[NSNumber numberWithInt:badgeCount] forKey:@"BADGE_COUNT"];
    
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
    [self showLoader:NO];
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
  /*  NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[dashboard class]])
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
        else if ([obj isKindOfClass:[dashboard class]] || [obj isKindOfClass:[userManagement class]])
        {
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            //[navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
        }
    }

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
