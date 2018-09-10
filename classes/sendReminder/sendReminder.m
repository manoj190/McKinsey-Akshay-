//
//  sendReminder.m
//  mckinsey
//
//  Created by Mac on 23/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "sendReminder.h"
#import "dashboard.h"
#import "loginView.h"
@interface sendReminder ()
{
    NIDropDown *dropDown;

}
- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)submitBtnClicked:(id)sender;
- (IBAction)selectUserBtnClicked:(id)sender;

@end

@implementation sendReminder

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"data = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"]);

    NSArray *viewControllers = [[self navigationController] viewControllers];
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

}

- (IBAction)notificationBtnClicked:(id)sender
{
}

- (IBAction)submitBtnClicked:(id)sender
{
}

- (IBAction)selectUserBtnClicked:(id)sender
{
    NSArray * arr = [[NSArray alloc] initWithObjects:@"USER1",@"USER2",@"USER3",@"ADMIN", nil];
    NSArray * arrImage = [[NSArray alloc] init];
    if(dropDown == nil)
    {
        CGFloat f = 120;
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
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}

@end
