//
//  inputPage.m
//  mckinsey
//
//  Created by Mac on 17/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "inputPage.h"
#import "maxDifInputCustomCell.h"
#import "dashboard.h"
#import "loadingPage.h"
#import "loginView.h"
#import "constant.h"
#import "addCustomCell.h"
#import "notifications.h"
#define ACCEPTABLE_CHARECTERS @"0123456789"
@interface inputPage ()
{
    loadingPage *loadingPageObj;
    NIDropDown *dropDown;
    
    IBOutlet UITableView *inputTableMaxDif;
    IBOutlet UITextField *totalNoOfLevelTxt;
    IBOutlet UITextField *surveyNameTxt, * noOfCardTxt;
    IBOutlet UIView *lableView;
    IBOutlet UIView *containerView;
    IBOutlet UIButton *selectRangeBtn;
    IBOutlet UIButton *rangeBtn;
    IBOutlet UIImageView *badgeCountImg;
    IBOutlet UILabel *badgeCountLbl;
    UITextField *currentTxtField;
    NSInteger indexNo;
    NSInteger levelCount;
    NSMutableArray *rowCountArray;
    NSMutableArray *indexNoArray;
    NSMutableArray *levelArray;
    NSMutableArray *featureArray;
    NSInteger pictureBtnIndex;
    NSMutableArray *imageDataArray;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    NSString * btnClicked;
    NSInteger currentRowIndex;
    BOOL dataEditedFlag;
    BOOL nextBtnClickedFlag;
}

- (IBAction)nextBtnClicked:(id)sender;
- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)selectRangeBtnClicked:(id)sender;
- (IBAction)saveBtnClicked:(id)sender;
- (IBAction)clearAllBtnClicked:(id)sender;
@end

@implementation inputPage
@synthesize previewPageObj;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showHideKeyboard];
    [self setUI];
    [self fetchSavedData];
    
    //fetch Badge count
    [self setBadgeNumber];
}

-(void)viewWillAppear:(BOOL)animated
{
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeNumber) name:@"setbadge" object:nil];
    NSLog(@"%@",_surveyID);
    surveyNameTxt.text = _surveyName;
    [surveyNameTxt setEnabled:false];
}

-(void)setBadgeNumber
{
    NSLog(@"In bagde counter");
    @try
    {
        badgeCountImg.hidden = NO;
        badgeCountLbl.hidden = NO;
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

-(void)fetchSavedData
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"LOCAL_DATA_SAVED"] isEqualToString:@"YES"])
    {
        rowCountArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"FEATURE_LEVEL_ARR"]  mutableCopy];
        imageDataArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"IMAGE_ARR"] mutableCopy];
        featureArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"FEATURE_DATA_ARR"] mutableCopy];
        levelArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"LEVEL_DATA_ARR"] mutableCopy];
        surveyNameTxt.text=[[NSUserDefaults standardUserDefaults] valueForKey:@"SURVEY_NAME"];
        NSLog(@"Range = %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"NO_OF_OPTIONS"]);
        [rangeBtn setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"NO_OF_OPTIONS"] forState:UIControlStateNormal];
        [rangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        noOfCardTxt.text=[[NSUserDefaults standardUserDefaults] valueForKey:@"NO_OF_CARD"];
        [self calculateTableIndex];
    }
}

-(void)setUI
{
    indexNo = 1;
    lableView.hidden = YES;
    rowCountArray = [[NSMutableArray alloc]initWithObjects:@"F",@"A", nil];
    featureArray = [[NSMutableArray alloc]initWithObjects:@" ",@" ", nil];
    levelArray = [[NSMutableArray alloc]initWithObjects:@" ",@" ", nil];
    indexNoArray = [[NSMutableArray alloc]initWithObjects:@"1",@" ", nil];
    imageDataArray = [[NSMutableArray alloc]initWithObjects:@" ",@" ", nil];
    
    lableView.hidden = NO;
    levelCount = 1;
    [inputTableMaxDif reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)nextBtnClicked:(id)sender
{
    btnClicked=@"NEXT";
    [currentTxtField resignFirstResponder];
    if ([surveyNameTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter survey name"];
    }
    else if ([noOfCardTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please select range"];
    }
    else if ([selectRangeBtn.currentTitle isEqualToString:@"Select Range"])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please select range"];
    }
    else if ([self featureAndLevelArrValidation:featureArray] != [self featureArrayValidation:rowCountArray])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all features"];
    }
    else if ([self featureAndLevelArrValidation:levelArray] != levelArray.count-1)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all levels"];
    }
    else
    {
        nextBtnClickedFlag =  YES;
        [self webserviceToAddSurvey];
    }
}

-(void)webServiceToSaveSurveyName
{
    [self showLoader:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
                       [dict setObject:surveyNameTxt.text forKey:@"SURVEY_NAME"];
                       [dict setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"] forKey:@"CREATED_BY_ID"];
                       [dict setObject:@"MaxDiff Survey" forKey:@"SURVEY_TYPE"];
                       NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
                       [dataDict setObject:dict forKey:@"DATA"];
                       
                       NSError * err;
                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dataDict options:0 error:&err];
                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                       
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"saveSurvey.php"]]];
                       
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
                               [self errorResponse:@"Error saving data"];
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"DATA"];
                               [self saveSurveyNameResponseResult:infoArray];
                           }
                       }] resume];
                       
                   });
}

-(void)saveSurveyNameResponseResult:(NSArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       
                       if ([[[result objectAtIndex:0]valueForKey:@"STATUS"] isEqualToString:@"EXISTS"])
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"Survey name already exists"];
                       }
                       else if ([[[result objectAtIndex:0]valueForKey:@"STATUS"] isEqualToString:@"SUCCESS"])
                       {
                           if ([btnClicked isEqualToString:@"SAVE"])
                           {
                               [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
                               [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"LOCAL_DATA_SAVED"];
                               [self showAlertView:@"ALIVE 2.0" message:@"Saved successfully"];
                           }
                           else
                           {
                               
                           }
                       }
                       else
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"Error saving data"];
                       }
                   });
}

-(void)webserviceToAddSurvey
{
    [self showLoadingView:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSError * err;
                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:[self getDetails] options:0 error:&err];
                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                       
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"SAVE_SURVEY/addSurvey1.php"]]];
                       
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
                               [self errorResponse:@"Error saving data"];
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"DATA"];
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
                       if ([[[result objectAtIndex:0]valueForKey:@"STATUS"] isEqualToString:@"EXISTS"])
                       {
                           [self showAlertView:@"Alive 2.0" message:@"Survey name already exists"];
                       }
                       else if ([[[result objectAtIndex:0]valueForKey:@"STATUS"] isEqualToString:@"SUCCESS"])
                       {
                           [rowCountArray addObject:@"A"];
                           [levelArray addObject:@" "];
                           [featureArray addObject:@" "];
                           [imageDataArray addObject:@" "];
                           
                           previewPageObj = [[previewPage alloc]initWithNibName:@"previewPage" bundle:nil];
                           previewPageObj.surveyName = surveyNameTxt.text;
                           previewPageObj.range = [selectRangeBtn.currentTitle intValue];
                           previewPageObj.levelsArray = [[NSMutableArray alloc]initWithArray:levelArray];
                           previewPageObj.levelImgsArray = [[NSMutableArray alloc]initWithArray:imageDataArray];
                           [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
                           [[NSUserDefaults standardUserDefaults] setValue:surveyNameTxt.text forKey:@"SURVEY_NAME"];

                           if ([btnClicked isEqualToString:@"SAVE"])
                           {
                               [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
                               [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"LOCAL_DATA_SAVED"];
                           }
                           else
                           {
                               [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"LOCAL_DATA_SAVED"];
                               previewPageObj.surveyId = [[result objectAtIndex:0]valueForKey:@"SURVEY_ID"];
                               [self.navigationController pushViewController:previewPageObj animated:YES];
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

-(void)showLoadingView: (BOOL)Show
{
    if (Show==YES)
    {
        loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
        [self.view addSubview:loadingPageObj.view];
    }
    else
    {
        [loadingPageObj.view removeFromSuperview];
    }
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
    [currentTxtField resignFirstResponder];
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"LOCAL_DATA_SAVED"] isEqualToString:@"YES"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
//        if ([surveyNameTxt.text length]>0)
//        {
//            [self showAlertView:@"NOTE" message:@"Save data before going to previous page"];
//        }
        if (![selectRangeBtn.currentTitle isEqualToString:@"Features Per Card"])
        {
            [self showAlertView:@"Alive 2.0" message:@"Save data before going to previous page"];
        }
        else if ([noOfCardTxt.text length]>0)
        {
            [self showAlertView:@"Alive 2.0" message:@"Save data before going to previous page"];
        }
        else if ([self featureAndLevelArrValidation:featureArray] != 0)
        {
            [self showAlertView:@"Alive 2.0" message:@"Save data before going to previous page"];
        }
        else if ([self featureAndLevelArrValidation:levelArray] != 0)
        {
            [self showAlertView:@"Alive 2.0" message:@"Save data before going to previous page"];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)logoutBtnClicked:(id)sender
{
  /*  NSArray *viewControllers = [[self navigationController] viewControllers];
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
        NSLog(@"Data saved successfully");
    }
    else
    {
        NSLog(@"Data not saved");
    }
}


- (IBAction)selectRangeBtnClicked:(id)sender
{
    NSArray * arr = [[NSArray alloc] initWithObjects:@"3",@"4",@"5", nil];
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

- (IBAction)saveBtnClicked:(id)sender
{
    [currentTxtField resignFirstResponder];
    if ([surveyNameTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter survey name"];
    }
    else if ([noOfCardTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please select range"];
    }
    else if ([selectRangeBtn.currentTitle isEqualToString:@"Select Range"])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please select range"];
    }
    else if ([self featureAndLevelArrValidation:featureArray] != [self featureArrayValidation:rowCountArray])
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter all features"];
    }
    else if ([self featureAndLevelArrValidation:levelArray] != levelArray.count-1)
    {
        [self showAlertView:@"Alive 2.0" message:@"Please enter all levels"];
    }
    else
    {
        dataEditedFlag = NO;
        [[NSUserDefaults standardUserDefaults] setObject:rowCountArray forKey:@"FEATURE_LEVEL_ARR"];
        [[NSUserDefaults standardUserDefaults] setObject:imageDataArray forKey:@"IMAGE_ARR"];
        [[NSUserDefaults standardUserDefaults] setObject:featureArray forKey:@"FEATURE_DATA_ARR"];
        [[NSUserDefaults standardUserDefaults] setObject:levelArray forKey:@"LEVEL_DATA_ARR"];
        [[NSUserDefaults standardUserDefaults] setObject:surveyNameTxt.text forKey:@"SURVEY_NAME"];
        [[NSUserDefaults standardUserDefaults] setObject:[rangeBtn currentTitle] forKey:@"NO_OF_OPTIONS"];
        [[NSUserDefaults standardUserDefaults] setObject:noOfCardTxt.text forKey:@"NO_OF_CARD"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"LOCAL_DATA_SAVED"];
        btnClicked=@"SAVE";
        [self showAlertView:@"Alive 2.0" message:@"Saved successfully"];
        //[self showLoadingView:YES];
        //[self webServiceToSaveSurveyName];
    }
}

- (IBAction)clearAllBtnClicked:(id)sender
{
    dataEditedFlag = NO;
    //surveyNameTxt.text = @"";
    noOfCardTxt.text = @"";
    [selectRangeBtn setTitle:@"Features Per Card" forState:UIControlStateNormal];
    [selectRangeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"LOCAL_DATA_SAVED"];
    [self setUI];
}

//All arrays validation
-(int)imageArrayValidation:(NSMutableArray *)imageArr
{
    int imageCount = 0;
    
        for (int i = 0; i<imageArr.count-1; i++)
        {
            if ([[imageArr objectAtIndex:i] isKindOfClass:[NSData class]])
            {
                
            }
            else
            {
                imageCount ++;
            }
        }
    return imageCount;
}

-(int)featureAndLevelArrValidation:(NSMutableArray *)arr
{
    int count = 0;
    for (int i = 0; i<arr.count-1; i++)
    {
        if ([[arr objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0 )
        {
            
        }
        else
        {
            count ++;
        }
    }
    return count;
}

-(int)featureArrayValidation:(NSMutableArray *)arr
{
    int featureCount = 0;
    for (int i = 0; i<arr.count-1; i++)
    {
        if ([[arr objectAtIndex:i] isEqualToString:@"F"])
        {
            featureCount ++;
        }
    }
    return featureCount;
}

-(void)rel
{
    dropDown = nil;
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [rangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self rel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return rowCountArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([[rowCountArray objectAtIndex:indexPath.row] isEqualToString:@"A"])
    {
        NSString *cellIdentifier = @"cell";
        addCustomCell *cell = [inputTableMaxDif dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"addCustomCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [cell.addFeatureBtn addTarget:self action:@selector(AddFeatureBtnclicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.addLevelBtn addTarget:self action:@selector(AddLevelBtnclicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    }
    else
    {
        NSString *cellIdentifier = @"cell";
        maxDifInputCustomCell *cell = [inputTableMaxDif dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"maxDifInputCustomCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.featureTxt.text = [featureArray objectAtIndex:indexPath.row];
        cell.levelTxt.text = [levelArray objectAtIndex:indexPath.row];
        [cell.pictureBtn addTarget:self action:@selector(selectPictureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        inputTableMaxDif.backgroundColor = [UIColor clearColor];
        inputTableMaxDif.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        if ([[imageDataArray objectAtIndex:indexPath.row] isEqual:@" "])
        {
            
        }
        else
        {
            [cell.pictureBtn setBackgroundImage:[UIImage imageWithData:[imageDataArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        }
        
        if ([[rowCountArray objectAtIndex:indexPath.row] isEqualToString:@"L"])
        {
            cell.indexNoView.hidden = YES;
        }
        else
        {
            indexNo++;
            cell.indexNoLbl.text = [indexNoArray objectAtIndex:indexPath.row];
        }
        return cell;
    }
}

-(void)AddFeatureBtnclicked:(id)sender
{
    if (rowCountArray.count-1 == 30)
    {
        [self showAlertView:@"Alive 2.0" message:@"You can not add more than 30 levels"];
    }
    else
    {
        dataEditedFlag = YES;
        [rowCountArray insertObject:@"F" atIndex:rowCountArray.count-1];
        [levelArray insertObject:@" " atIndex:levelArray.count-1];
        [featureArray insertObject:@" " atIndex:featureArray.count-1];
        [imageDataArray insertObject:@" " atIndex:imageDataArray.count-1];
        [indexNoArray insertObject:[NSString stringWithFormat:@"%ld",(long)indexNo] atIndex:indexNoArray.count-1];
        [self calculateTableIndex];
        [inputTableMaxDif reloadData];
    }
}

-(void)AddLevelBtnclicked:(id)sender
{
    if (rowCountArray.count == 1)
    {
        [self showAlertView:@"Alive 2.0" message:@"Please add feature before adding level"];
    }
    else if (rowCountArray.count-1 == 30)
    {
        [self showAlertView:@"Alive 2.0" message:@"You can not add more than 30 levels"];
    }
    else
    {
        dataEditedFlag = YES;
        [rowCountArray insertObject:@"L" atIndex:rowCountArray.count-1];
        [levelArray insertObject:@" " atIndex:levelArray.count-1];
        [featureArray insertObject:@" " atIndex:featureArray.count-1];
        [imageDataArray insertObject:@" " atIndex:imageDataArray.count-1];
        [indexNoArray insertObject:@" " atIndex:indexNoArray.count-1];
        [self calculateTableIndex];
        [inputTableMaxDif reloadData];
    }
}

-(void)deleteBtnClicked:(id)sender
{
    dataEditedFlag = YES;
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:inputTableMaxDif];
    NSIndexPath *btnIndex = [inputTableMaxDif indexPathForRowAtPoint:touchPoint];
    if ([[rowCountArray objectAtIndex:btnIndex.row] isEqualToString:@"L"])
    {
        [rowCountArray removeObjectAtIndex:btnIndex.row];
        [levelArray removeObjectAtIndex:btnIndex.row];
        [indexNoArray removeObjectAtIndex:btnIndex.row];
        [featureArray removeObjectAtIndex:btnIndex.row];
        [imageDataArray removeObjectAtIndex:btnIndex.row];
        [inputTableMaxDif reloadData];
    }
    else if ([[rowCountArray objectAtIndex:btnIndex.row] isEqualToString:@"F"])
    {
        int deleteCount = 1;
        
        for (int i = btnIndex.row  ; i<rowCountArray.count; i++)
        {
            if ([[rowCountArray objectAtIndex:i+1] isEqualToString:@"L"])
            {
                deleteCount ++;
            }
            else
            {
                break;
            }
        }
        
        NSRange r;
        r.location = btnIndex.row;
        r.length = deleteCount;
        [rowCountArray removeObjectsInRange:r];
        [levelArray removeObjectsInRange:r];
        [indexNoArray removeObjectsInRange:r];
        [featureArray removeObjectsInRange:r];
        [imageDataArray removeObjectsInRange:r];
        [self calculateTableIndex];
        [inputTableMaxDif reloadData];
    }
}

-(void)calculateTableIndex
{
    NSInteger count = 0;
    indexNoArray = [[NSMutableArray alloc]init];
    for (int i = 0; i<rowCountArray.count; i++)
    {
        if ([[rowCountArray objectAtIndex:i]isEqualToString:@"F"])
        {
            count ++;
            [indexNoArray addObject:[NSString stringWithFormat:@"%d",count]];
        }
        else
        {
            [indexNoArray addObject:@" "];
        }
    }
}

-(void)selectPictureBtnClicked:(id)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:inputTableMaxDif];
    NSIndexPath *clickedButtonIndexPath = [inputTableMaxDif indexPathForRowAtPoint:touchPoint];
    pictureBtnIndex = clickedButtonIndexPath.row;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Upload Photo"
                                  message:@"Please select one option"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *gallery = [UIAlertAction
                              actionWithTitle:@"GALLERY"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self openGalleryCamera:0];
                              }];
    UIAlertAction *camera = [UIAlertAction
                             actionWithTitle:@"CAMERA"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self openGalleryCamera:1];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"CANCEL"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:gallery];
    [alert addAction:camera];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSDictionary *)getDetails
{
    NSMutableDictionary * savedict=[[NSMutableDictionary alloc] init];
    [savedict setObject:[self getTableData] forKey:@"DATA"];
    return savedict;
}

-(NSMutableDictionary *)getTableData
{
    [rowCountArray removeLastObject];
    [levelArray removeLastObject];
    [featureArray removeLastObject];
    [imageDataArray removeLastObject];
    
    NSMutableArray * arr=[[NSMutableArray alloc]init];
    NSString *featureName;
    
    for (int i=0; i<rowCountArray.count; i++)
    {
        if ([[rowCountArray objectAtIndex:i] isEqualToString:@"F"])
        {
            featureName = [featureArray objectAtIndex:i];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:featureName forKey:@"FEATURE"];
        [dict setObject:[levelArray objectAtIndex:i] forKey:@"LEVEL_NAME"];
        //[dict setObject:@"0" forKey:@"COST"];
        if ([[imageDataArray objectAtIndex:i] isKindOfClass:[NSString class]])
        {
            [dict setObject:@"NA" forKey:@"LEVEL_IMAGE"];
        }
        else
        {
            [dict setObject:[self imageDataToBase64:[imageDataArray objectAtIndex:i]] forKey:@"LEVEL_IMAGE"];
        }
        [arr addObject:dict];
    }
    
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc]init];
    [dataDict setObject:arr forKey:@"LEVEL"];
    [dataDict setObject:_surveyID forKey:@"SURVEY_ID"];
    
    //NSString *surveyId = [[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_ID"];
//    if ([_surveyID isEqualToString:@""])
//    {
//        [dataDict setObject:_surveyID forKey:@"SURVEY_ID"];
//    }
//    else
//    {
//        [dataDict setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
//    }
    [dataDict setObject:surveyNameTxt.text forKey:@"SURVEY_NAME"];
    [dataDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ADMIN_ID"] forKey:@"CREATED_BY"];
    [dataDict setObject:@"NA" forKey:@"CURRENCY"];
    [dataDict setObject:@"MaxDiff Survey" forKey:@"SURVEY_TYPE"];
    [dataDict setObject:rangeBtn.currentTitle forKey:@"NO_OF_OPTIONS"];
    [dataDict setObject:noOfCardTxt.text forKey:@"NO_OF_CARDS"];
    
    return dataDict;
}

- (NSString *)imageDataToBase64:(NSData *)imagData
{
    return [imagData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

-(void)showHideKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)keyboardDidShow: (NSNotification *) notif
{
    if (self.view.frame.origin.y != -250 && currentTxtField.tag != 101)
    {
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.3f];
        self.view.frame = CGRectOffset(self.view.frame, 0, -250);
        [UIView commitAnimations];
        containerView.frame = CGRectMake(21, 312, 753, 300);
        inputTableMaxDif.frame = CGRectMake(0, 0, 753, 300);
    }
}

- (void)keyboardDidHide: (NSNotification *) notif
{
    if (self.view.frame.origin.y != 0)
    {
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.3f];
        self.view.frame = CGRectOffset(self.view.frame, 0, 250);
        [UIView commitAnimations];
        containerView.frame = CGRectMake(21, 312, 753, 388);
        inputTableMaxDif.frame = CGRectMake(0, 0, 753, 388);
    }
}

-(void)openGalleryCamera:(int )index
{
    if (index == 0)
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else if (index == 1)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.allowsEditing = YES;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self presentViewController:imagePicker animated:YES completion:nil];
            }];
        }
        else
        {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:@"Camera is not available in this device"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction
                                 actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *profileImg = [info valueForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData* pictureData = UIImageJPEGRepresentation(profileImg, 0.3);
    NSString *imgName = [NSString stringWithFormat:@"%@_%d.%@",@"mc_img",[self generateRandomNumberWithlowerBound],@"png"];
    [imageDataArray replaceObjectAtIndex:pictureBtnIndex withObject:pictureData];
    [inputTableMaxDif reloadData];
}

-(int)generateRandomNumberWithlowerBound
{
    int rndValue = 0000 + arc4random() % (9999 - 0000);
    return rndValue;
}

#pragma mark - TextField Delegation
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTxtField = textField;
    CGPoint touchPoint = [currentTxtField convertPoint:CGPointZero toView:inputTableMaxDif];
    NSIndexPath *clickedButtonIndexPath = [inputTableMaxDif indexPathForRowAtPoint:touchPoint];
    currentRowIndex = clickedButtonIndexPath.row;
    NSLog(@"Row index = %ld",(long)clickedButtonIndexPath.row);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    CGPoint touchPoint = [currentTxtField convertPoint:CGPointZero toView:inputTableMaxDif];
    NSIndexPath *clickedButtonIndexPath = [inputTableMaxDif indexPathForRowAtPoint:touchPoint];
    if (textField.tag == 201)
    {
    
        [featureArray replaceObjectAtIndex:currentRowIndex withObject:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
       // [featureArray replaceObjectAtIndex:clickedButtonIndexPath.row withObject:textField.text];
    }
    else if (textField.tag == 202)
    {
        //[levelArray replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [levelArray replaceObjectAtIndex:currentRowIndex withObject:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

        //[levelArray replaceObjectAtIndex:clickedButtonIndexPath.row withObject:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == noOfCardTxt)
    {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
        
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        return [string isEqualToString:filtered];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    int movementDistance = 0;
    
    movementDistance = -250;
    
    const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
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
