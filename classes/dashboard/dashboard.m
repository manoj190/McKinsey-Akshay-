//
//  dashboard.m
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "dashboard.h"
#import "dashboardCell.h"
#import "constant.h"
#import "loadingPage.h"
#import "Reachability.h"
#import "loginView.h"
#import "notifications.h"
#import "userManagement.h"
#import "DemographicsViewController.h"
#import "MISViewController.h"

@interface dashboard ()
{
    loadingPage *loadingPageObj;
    IBOutlet UITableView *dashboardTable;
    IBOutlet UIButton *sendReminderBtn;
    IBOutlet UIButton *userMgmtBtn;
    IBOutlet UIImageView *badgeCountImg;
    IBOutlet UILabel *badgeCountLbl;
    IBOutlet UIView *headerView;
    IBOutlet UIButton *createSurveyBtn;
    
    NSMutableArray *surveryDetailsArr;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    NSString *surveyId,*surveyName;
    NSString *surveyType, * surveyCompletionStr;
}

@property (weak, nonatomic) IBOutlet UIButton *surveyNameSortBtn;
@property (weak, nonatomic) IBOutlet UIButton *dateSortBtn;


- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)startSurveyBtnClicked:(id)sender;
- (IBAction)respondentManagementBtnClicked:(id)sender;
- (IBAction)userManagementBtnClicked:(id)sender;
- (IBAction)sendReminderBtnClicked:(id)sender;
- (IBAction)analyzeExistingBtnClicked:(id)sender;
- (IBAction)surveyNameSortBtnPressed:(id)sender;
- (IBAction)dateSortBtnPressed:(id)sender;

@end

@implementation dashboard
@synthesize analysisTypeViewObj,manageRespondentViewObj,userManagementObj,sendReminderObj,maxDiffOutputObj,fpOutputObj,fpUsingMdOutputObj;

- (void)viewDidLoad
{
    [super viewDidLoad];
    headerView.hidden = YES;
    surveryDetailsArr = [[NSMutableArray alloc]initWithArray:[[userDetailsArr objectAtIndex:0]valueForKey:@"SURVEY_DETAILS"]];
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    
    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [dashboardTable addSubview:refreshControl];
    
    NSArray *viewControllers = [[self navigationController] viewControllers];
    NSLog(@"View = %@",viewControllers);

    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"CREATED_DATE" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedArray = [surveryDetailsArr sortedArrayUsingDescriptors:sortDescriptors];
    surveryDetailsArr = [[NSMutableArray alloc] initWithArray:sortedArray];
    [dashboardTable reloadData];
    
}

- (void)refresh:(UIRefreshControl *)refreshControl
{
    // Do your job, when done:
    //[self showLoader:YES];
    [self callWebserviceToFetchSuveyList];
    [refreshControl endRefreshing];
}

-(void)viewWillAppear:(BOOL)animated
{
    surveyId = NULL;
    sendReminderBtn.hidden = YES;
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [createSurveyBtn setEnabled:true];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self setUI];
    [self showLoader:YES];
    [self callWebserviceToFetchSuveyList];
    //fetch Badge count
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
        if ([[dict objectForKey:@"BADGE_COUNT"]intValue] != 0)
        {
            badgeCountImg.hidden = NO;
            badgeCountLbl.hidden = NO;
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

-(void)setUI
{
    userMgmtBtn.hidden = YES;

    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"USER_TYPE"] isEqualToString:@"ADMIN"])
    {
        userMgmtBtn.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)logoutBtnClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"data = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"]);

/*
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
  */
    
    
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
        else if ([obj isKindOfClass:[userManagement class]])
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

- (IBAction)startSurveyBtnClicked:(id)sender
{
//    analysisTypeViewObj = [[analysisTypeView alloc]initWithNibName:@"analysisTypeView" bundle:nil];
//    [self.navigationController pushViewController:analysisTypeViewObj animated:YES];
//
    DemographicsViewController *destObj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"DemographicsViewController"];

    [self.navigationController pushViewController:destObj animated:YES];
}

- (IBAction)respondentManagementBtnClicked:(id)sender
{
    if ([surveyId length] == 0 || [surveyId isKindOfClass:[NSNull class]] ||
            [surveyId isEqualToString:@""] || surveyId == nil || [surveyType isEqualToString:@""])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please select attained survey to manage respondent"];
    }
    else
    {
        manageRespondentViewObj = [[manageRespondentView alloc]initWithNibName:@"manageRespondentView" bundle:nil];
        manageRespondentViewObj.surveyId = surveyId;
        [self.navigationController pushViewController:manageRespondentViewObj animated:YES];
    }
}

- (IBAction)userManagementBtnClicked:(id)sender
{
    userManagementObj = [[userManagement alloc]initWithNibName:@"userManagement" bundle:nil];
    [self.navigationController pushViewController:userManagementObj animated:YES];
}

- (IBAction)sendReminderBtnClicked:(id)sender
{
    sendReminderObj = [[sendReminder alloc]initWithNibName:@"sendReminder" bundle:nil];
    [self.navigationController pushViewController:sendReminderObj animated:YES];
}

- (IBAction)analyzeExistingBtnClicked:(id)sender
{
    if ([surveyId length] == 0)
    {
        [self showAlertView:@"Alive 2.0" message:@"Please select survey"];
    }
    else if ([surveyCompletionStr isEqualToString:@"0"])
    {
        [self showAlertView:@"Alive 2.0" message:@"Analysis for this survey could not be done, since this survey is not attended by anyone."];
    }
    else
    {
        globalSurveyType = surveyType;
        if ([surveyType isEqualToString:@"MaxDiff Survey"])
        {
            //FOR MAPS
//            MISViewController *obj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MISViewController"];
//            obj.surveyID = surveyId;
//            obj.surveyName = surveyName;
//            obj.surveyType = surveyType;
//            [self.navigationController pushViewController:obj animated:YES];
//            [self showLoader:YES];
//            [self  callWaterFallGraphDataWebservice];
            
            // FOR GRAPHS
            
            maxDiffOutputObj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"maxDiffOutput"];
            maxDiffOutputObj.surveyId = surveyId;
            maxDiffOutputObj.surveyName = surveyName;
            [self.navigationController pushViewController:maxDiffOutputObj animated:YES];
            
//            maxDiffOutputObj = [[maxDiffOutput alloc]initWithNibName:@"maxDiffOutput" bundle:nil];
//            maxDiffOutputObj.surveyId = surveyId;
//            maxDiffOutputObj.surveyName = surveyName;
//            [self.navigationController pushViewController:maxDiffOutputObj animated:YES];
        }
        else if ([surveyType isEqualToString:@"Feature Prioritization survey"])
        {
            //FOR MAPS
//            [self showLoader:YES];
//            MISViewController *obj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MISViewController"];
//            obj.surveyID = surveyId;
//            obj.surveyName = surveyName;
//            obj.surveyType = surveyType;
//            [self.navigationController pushViewController:obj animated:YES];
            
            // FOR GRAPHS
            maxDiffOutputObj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"maxDiffOutput"];
            maxDiffOutputObj.surveyId = surveyId;
            maxDiffOutputObj.surveyName = surveyName;
            [self.navigationController pushViewController:maxDiffOutputObj animated:YES];
            
//            maxDiffOutputObj = [[maxDiffOutput alloc]initWithNibName:@"maxDiffOutput" bundle:nil];
//            maxDiffOutputObj.surveyId = surveyId;
//            maxDiffOutputObj.surveyName = surveyName;
//            [self.navigationController pushViewController:maxDiffOutputObj animated:YES];
        }
    }
}


- (IBAction)surveyNameSortBtnPressed:(UIButton *)sender {
    
    if (sender.tag == 1) {
        sender.tag = 2;
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"SURVEY_NAME" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [surveryDetailsArr sortedArrayUsingDescriptors:sortDescriptors];
        surveryDetailsArr = [[NSMutableArray alloc] initWithArray:sortedArray];
        [dashboardTable reloadData];
    }
    else {
        sender.tag = 1;
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"SURVEY_NAME" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [surveryDetailsArr sortedArrayUsingDescriptors:sortDescriptors];
        surveryDetailsArr = [[NSMutableArray alloc] initWithArray:sortedArray];
        [dashboardTable reloadData];
    }
}

- (IBAction)dateSortBtnPressed:(UIButton *)sender {
    if (sender.tag == 1) {
        sender.tag = 2;
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"CREATED_DATE" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [surveryDetailsArr sortedArrayUsingDescriptors:sortDescriptors];
        surveryDetailsArr = [[NSMutableArray alloc] initWithArray:sortedArray];
        [dashboardTable reloadData];
    }
    else {
        sender.tag = 1;
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"CREATED_DATE" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        NSArray *sortedArray = [surveryDetailsArr sortedArrayUsingDescriptors:sortDescriptors];
        surveryDetailsArr = [[NSMutableArray alloc] initWithArray:sortedArray];
        [dashboardTable reloadData];
    }
}

-(void)callWaterFallGraphDataWebservice
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"maxDiffGraphDetail.php"]]];
                       
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
                               [self showLoader:NO];
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"data"];
                               [self waterFallGraphDataWebserviceResponseResult:infoArray];
                           }
                       }] resume];
                   });
}

-(void)waterFallGraphDataWebserviceResponseResult:(NSMutableArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count == 0)
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Nobody attended the survey yet"];
                       }
                       else
                       {
                           maxDiffOutputObj = [[maxDiffOutput alloc]initWithNibName:@"maxDiffOutput" bundle:nil];
                           maxDiffOutputObj.surveyDetailArr = result;
                           maxDiffOutputObj.surveyId = surveyId;
                           maxDiffOutputObj.surveyName = surveyName;
                           [self.navigationController pushViewController:maxDiffOutputObj animated:YES];
                       }
                   });
}

-(void)callPointGraphDataWebservice
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"featurePrioritizationGraph.php"]]];
                       
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
                               [self errorResponse:@"Error error fetching data"];
                               [self showLoader:NO];
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"data"];
                               [self PointGraphDataWebserviceResponseResult:infoArray];
                           }
                       }] resume];
                   });
}

-(void)PointGraphDataWebserviceResponseResult:(NSMutableArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count == 0)
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Nobody attended the survey yet"];
                       }
                       else
                       {
                           fpUsingMdOutputObj = [[fpUsingMdOutput alloc]initWithNibName:@"fpUsingMdOutput" bundle:nil];
                           fpUsingMdOutputObj.surveyId = surveyId;
                           fpUsingMdOutputObj.surveyDetailArr = result;
                           [self.navigationController pushViewController:fpUsingMdOutputObj animated:YES];
                       }
                   });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"Alive 2.0" message:msg];
    [self showLoader:NO];

}

-(void)callWebserviceToFetchSuveyList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"surveyList.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&ADMIN_ID=%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"ADMIN_ID"]];
                       
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
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                               [self errorResponse:@"Error fetching data"];
                               [self showLoader:NO];
                                              });
                           }
                           else
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"data"];
                               [self fetchSuveyListResponseResult:infoArray];
                                              });
                           }
                       }] resume];
                   });
}

-(void)fetchSuveyListResponseResult:(NSArray *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count == 0)
                       {
                           [createSurveyBtn setEnabled:true];
                           [self showAlertView:@"Alive 2.0" message:@"No survey found,click on create new survey button to create survey"];
                       }
                       else
                       {
                           headerView.hidden = NO;
                           NSArray* reversedArray = [[result reverseObjectEnumerator] allObjects];
                           surveryDetailsArr = [[NSMutableArray alloc]initWithArray:reversedArray];
                           [dashboardTable reloadData];
                       }
                   });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([surveryDetailsArr count]) {
        tableView.backgroundView = nil;
        return 1;
    }
    else {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height)];
        noDataLabel.font = [UIFont systemFontOfSize:20];
        noDataLabel.text             = @"No survey available";
        noDataLabel.textColor        = [UIColor whiteColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        tableView.backgroundView = noDataLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return surveryDetailsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *cellIdentifier = @"cell";
    dashboardCell *cell = [dashboardTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"dashboardCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    dashboardTable.backgroundColor = [UIColor clearColor];
    dashboardTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.srNoLbl.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    cell.NameLbl.text = [[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_NAME"];
    cell.typeLbl.text = [[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_TYPE"];
    cell.percentLbl.text = [[[[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ATTENDED_STATUS"] stringValue] stringByAppendingString:@"%"];
    cell.dateLabel.text = [[surveryDetailsArr objectAtIndex:indexPath.row] valueForKey:@"CREATED_DATE"];
    
    cell.editBtn.tag = indexPath.row;
    if ([[[surveryDetailsArr objectAtIndex:indexPath.row] valueForKey:@"SURVEY_TYPE"] isEqualToString:@""]) {
        [cell.editBtn setHidden:false];
        [cell.mbswitch2 setHidden:true];
    }
    else {
        [cell.editBtn setHidden:true];
        [cell.mbswitch2 setHidden:false];
    }
    
   // [cell.modeBtn addTarget:self action:@selector(modeBtnSwitched:) forControlEvents:UIControlEventValueChanged];
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:19.0/255.0 blue:30.0/255.0 alpha:0.9];
    
    if ([[[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"ACTIVE"] isEqualToString:@"Y"])
    {
        [cell.mbswitch2 setOnTintColor:[UIColor colorWithRed:0.0/255.0 green:208/255.0 blue:88/255.0 alpha:1.0]];
        [cell.mbswitch2 setOn:YES];
    }
    else
    {
        [cell.mbswitch2 setTintColor:[UIColor colorWithRed:247.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0]];
        [cell.mbswitch2 setOffTintColor:[UIColor colorWithRed:247.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0]];
        [cell.mbswitch2 setOn:NO];
    }
    
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnclicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mbswitch2 addTarget:self action:@selector(modeBtnSwitched:) forControlEvents:UIControlEventValueChanged];
    [cell.editBtn addTarget:self action:@selector(editSurveyBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    surveyId = [[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ID"];
    surveyType = [[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_TYPE"];
    surveyCompletionStr = [NSString stringWithFormat:@"%@",[[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ATTENDED_STATUS"]];
    surveyName = [[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_NAME"];
    
//    if ([[[surveryDetailsArr objectAtIndex:indexPath.row] valueForKey:@"SURVEY_TYPE"] isEqualToString:@""]) {
//        [createSurveyBtn setEnabled:false];
//    }
//    else {
//        [createSurveyBtn setEnabled:true];
//    }
}

#pragma mark - Selector methods
-(void)modeBtnSwitched:(id)sender
{
    if (![self connected])
    {
        [self showAlertView:@"Alive 2.0" message:@"No internet connection"];
    }
    else
    {
        [self showLoader:YES];
        //Get table index
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:dashboardTable];
        NSIndexPath *indexPath = [dashboardTable indexPathForRowAtPoint:buttonPosition];
        
        //Get switch value
        UISwitch *switchControl = sender;
        NSString *switchStatus = switchControl.on ? @"ON" : @"OFF";
        
        if ([switchStatus isEqualToString:@"ON"])
        {
            [self callWebserviceToChangeSurveyStatus:[[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ID"] :@"Y" :indexPath.row];
        }
        else
        {
            [self callWebserviceToChangeSurveyStatus:[[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ID"] :@"N" :indexPath.row];
        }
    }
}

-(void)deleteBtnclicked:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:dashboardTable];
    NSIndexPath *indexPath = [dashboardTable indexPathForRowAtPoint:buttonPosition];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Alive 2.0"
                                 message:@"Are you sure you want to delete this survey?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self showLoader:YES];
                                    [self callWebserviceToDeleteSurvey:[[surveryDetailsArr objectAtIndex:indexPath.row]valueForKey:@"SURVEY_ID"] indexPath:indexPath.row];
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

- (void)editSurveyBtnPressed:(UIButton *)sender {
    NSLog(@"edit pressed");
    
    analysisTypeViewObj = [[analysisTypeView alloc]initWithNibName:@"analysisTypeView" bundle:nil];
    
    surveyId = [[surveryDetailsArr objectAtIndex:sender.tag]valueForKey:@"SURVEY_ID"];
    surveyType = [[surveryDetailsArr objectAtIndex:sender.tag]valueForKey:@"SURVEY_TYPE"];
    surveyCompletionStr = [NSString stringWithFormat:@"%@",[[surveryDetailsArr objectAtIndex:sender.tag]valueForKey:@"SURVEY_ATTENDED_STATUS"]];
    surveyName = [[surveryDetailsArr objectAtIndex:sender.tag]valueForKey:@"SURVEY_NAME"];
    
    analysisTypeViewObj.surveyName = surveyName;
    analysisTypeViewObj.surveyID = surveyId;
    analysisTypeViewObj.surveyCurrency = [[surveryDetailsArr objectAtIndex:sender.tag] valueForKey:@"CURRENCY_VALUE"];
    [self.navigationController pushViewController:analysisTypeViewObj animated:YES];
}

-(void)callWebserviceToDeleteSurvey:(NSString *)surveyIdStr indexPath:(NSInteger)index
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"deleteSurvey.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&SURVEY_ID=%@",surveyIdStr];
                       
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
                               [self errorResponse:@"Error deleting survey"];
                           }
                           else
                           {
                               NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                               resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self deleteSurveyResponseResult:resStr :index];
                           }
                           
                       }] resume];
                   });
}

-(void)deleteSurveyResponseResult:(NSString  *)result :(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Survey deleted successfully"];
                           [surveryDetailsArr removeObjectAtIndex:index];
                           [dashboardTable reloadData];
                       }
                       else
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error updating status"];
                       }
                    });
}

-(void)callWebserviceToChangeSurveyStatus:(NSString *)surveyIdStr :(NSString *)status :(int)index
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"survey_status_changed.php"]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate =[NSString stringWithFormat:@"&SURVEY_ID=%@&STATUS=%@",surveyIdStr,status];
                       
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
                               [self errorResponse:@"Error changing status of survey"];
                           }
                           else
                           {
                                NSString *resStr = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                                resStr = [resStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                                resStr = [resStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                               [self responseResult:resStr :index :status];
                            }
                           
                       }] resume];
                   });
}

-(void)responseResult:(NSString  *)result :(int)index :(NSString *)status
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Status updated successfully"];
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[surveryDetailsArr objectAtIndex:index]];
                           [dict setObject:status forKey:@"ACTIVE"];
                           [surveryDetailsArr replaceObjectAtIndex:index withObject:dict];
                           [dashboardTable reloadData];
                       }
                       else
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Error updating status"];
                       }
                   });
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














