//
//  featurePrioritization.m
//  mckinsey
//
//  Created by Mac on 22/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "featurePrioritization.h"
#import "featurePrioritizationCell.h"
#import "dashboard.h"
#import "loginView.h"
#import "loadingPage.h"
#import "constant.h"
#import "previewPage.h"
#import "addCustomCell.h"
#import "notifications.h"
#define ACCEPTABLE_CHARECTERS @"0123456789"

@interface featurePrioritization ()
{
    NIDropDown *dropDown;
    loadingPage *loadingPageObj;

    IBOutlet UITableView *featurePrioritizationTable;
    IBOutlet UITextField *maxNoOfCardsTxt;
    IBOutlet UIView *containerView;
    IBOutlet UITextField *surveyNameTxt;
    IBOutlet UIButton *rangeBtn;
    IBOutlet UIView *lableView;
    IBOutlet UIButton *selectCurrencyBtn;
    IBOutlet UIImageView *badgeCountImg;
    IBOutlet UILabel *badgeCountLbl;
    NSInteger indexNo;
    NSMutableArray *rowCountArray;
    NSInteger levelCount;
    NSMutableArray *indexNoArray;
    NSMutableArray *levelArray;
    NSMutableArray *currencyNameArr;
    NSInteger pictureBtnIndex;
    UITextField *currentTxtField;
    UIPickerView *pickerView;
    UIToolbar *toolBar;
    NSMutableArray *currencyTypeArr;
    NSMutableArray *featureArray;
    NSMutableArray *costArray;
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
- (IBAction)selectCurrencyBtnClicked:(id)sender;

@end

@implementation featurePrioritization
@synthesize previewPageObj;
- (void)viewDidLoad
{
    [super viewDidLoad];

    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    [self showHideKeyboard];
    [self setUI];
    [self fetchSavedData];
}

-(void)fetchSavedData
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"LOCAL_DATA_SAVED_FP"] isEqualToString:@"YES"])
    {
        rowCountArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"FEATURE_LEVEL_ARR_FP"]  mutableCopy];
        imageDataArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"IMAGE_ARR_FP"] mutableCopy];
        featureArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"FEATURE_DATA_ARR_FP"] mutableCopy];
        levelArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"LEVEL_DATA_ARR_FP"] mutableCopy];
        costArray=[[[NSUserDefaults standardUserDefaults] valueForKey:@"COST_DATA_ARR_FP"] mutableCopy];
        surveyNameTxt.text=[[NSUserDefaults standardUserDefaults] valueForKey:@"SURVEY_NAME_FP"];
        [rangeBtn setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"NO_OF_OPTIONS_FP"] forState:UIControlStateNormal];
        [rangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        maxNoOfCardsTxt.text=[[NSUserDefaults standardUserDefaults] valueForKey:@"NO_OF_CARD_FP"];
        //[selectCurrencyBtn setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENCY_TYPE_FP"] forState:UIControlStateNormal];
        [self calculateTableIndex];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    lableView.hidden = YES;
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



-(void)setUI
{
    indexNo = 1;
    rowCountArray = [[NSMutableArray alloc]initWithObjects:@"F",@"A", nil];
    featureArray = [[NSMutableArray alloc]initWithObjects:@" ",@" ", nil];
    levelArray = [[NSMutableArray alloc]initWithObjects:@" ",@" ", nil];
    indexNoArray = [[NSMutableArray alloc]initWithObjects:@"1",@" ", nil];
    currencyNameArr = [[NSMutableArray alloc]initWithObjects:@"USD",@"INR",nil];
    currencyTypeArr = [[NSMutableArray alloc]initWithObjects:@" ",@" ",nil];
    costArray = [[NSMutableArray alloc]initWithObjects:@" ",@" ",nil];
    imageDataArray = [[NSMutableArray alloc]initWithObjects:@" ",@" ",nil];

    surveyNameTxt.text = _surveyName;
    [selectCurrencyBtn setTitle:_surveyCurrency forState:UIControlStateNormal];
    [selectCurrencyBtn setEnabled:false];
    [surveyNameTxt setEnabled:false];
    lableView.hidden = NO;
    levelCount = 1;
    [featurePrioritizationTable reloadData];
    
}


- (IBAction)nextBtnClicked:(id)sender
{
    btnClicked=@"NEXT";
    [currentTxtField resignFirstResponder];
    if ([surveyNameTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter survey name"];
    }
    else if ([rangeBtn.currentTitle isEqualToString:@"Features Per Card"])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please select range"];
    }
    else if ([selectCurrencyBtn.currentTitle isEqualToString:@"Select Currency"])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please select currency"];
    }
    else if ([maxNoOfCardsTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter number of cards"];
    }
    else if ([self featureAndLevelArrValidation:featureArray] != [self featureArrayValidation:rowCountArray])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all features"];
    }
    else if ([self featureAndLevelArrValidation:levelArray] != levelArray.count-1)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all levels"];
    }
    else if ([self featureAndLevelArrValidation:costArray] != costArray.count-1)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all cost"];
    }
//    else if ([self imageArrayValidation:imageDataArray] != 0)
//    {
//        [self showAlertView:@"NOTE" message:@"Please select images for all the corresponding levels."];
//    }
   else
    {
         nextBtnClickedFlag =  YES;
         [self showLoader:YES];
         [self webserviceToAddSurvey];
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
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"LOCAL_DATA_SAVED_FP"] isEqualToString:@"YES"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {

//    if ([surveyNameTxt.text length]>0)
//    {
//        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
//    }
    if (![selectCurrencyBtn.currentTitle isEqualToString:@"Select"])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
    }
    else if (![rangeBtn.currentTitle isEqualToString:@"Features Per Card"])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
    }
    else if ([maxNoOfCardsTxt.text length]>0)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
    }
    else if ([self featureAndLevelArrValidation:featureArray] != 0)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
    }
    else if ([self featureAndLevelArrValidation:levelArray] != 0)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
    }
    else if ([self featureAndLevelArrValidation:costArray] != 0)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
    }
    else if ([self imageArrayValidation:imageDataArray] == 0)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Save data before going to previous page"];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    }

    
    
//    if (dataEditedFlag == YES && nextBtnClickedFlag == NO)
//    {
//        [self showAlertView:@"NOTE" message:@"Save data before going to previous page"];
//    }
//    else
//    {
//      [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (IBAction)logoutBtnClicked:(id)sender
{
   /* NSArray *viewControllers = [[self navigationController] viewControllers];
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
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter survey name"];
    }
    else if ([rangeBtn.currentTitle isEqualToString:@"Features Per Card"])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please select range"];
    }
    else if ([selectCurrencyBtn.currentTitle isEqualToString:@"Select"])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please select currency"];
    }
    else if ([maxNoOfCardsTxt.text isEqualToString:@""])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter number of cards"];
    }
    else if ([self featureAndLevelArrValidation:featureArray] != [self featureArrayValidation:rowCountArray])
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all features"];
    }
    else if ([self featureAndLevelArrValidation:levelArray] != levelArray.count-1)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all levels"];
    }
    else if ([self featureAndLevelArrValidation:costArray] != costArray.count-1)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter all cost"];
    }
//    else if ([self imageArrayValidation:imageDataArray] != 0)
//    {
//        [self showAlertView:@"NOTE" message:@"Please select images for all the corresponding levels."];
//    }
    else
    {
        dataEditedFlag = NO;
        [[NSUserDefaults standardUserDefaults] setObject:rowCountArray forKey:@"FEATURE_LEVEL_ARR_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:imageDataArray forKey:@"IMAGE_ARR_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:featureArray forKey:@"FEATURE_DATA_ARR_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:levelArray forKey:@"LEVEL_DATA_ARR_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:costArray forKey:@"COST_DATA_ARR_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:surveyNameTxt.text forKey:@"SURVEY_NAME_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:[rangeBtn currentTitle] forKey:@"NO_OF_OPTIONS_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:maxNoOfCardsTxt.text forKey:@"NO_OF_CARD_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:selectCurrencyBtn.currentTitle forKey:@"CURRENCY_TYPE_FP"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"LOCAL_DATA_SAVED_FP"];

        btnClicked=@"SAVE";
        [self showLoader:YES];
        [self webServiceToSaveSurveyName];
    }
}

- (IBAction)clearAllBtnClicked:(id)sender
{
    dataEditedFlag = NO;
    //surveyNameTxt.text = @"";
    maxNoOfCardsTxt.text = @"";
    //[selectCurrencyBtn setTitle:@"Select" forState:UIControlStateNormal];
//     selectCurrencyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    //[selectCurrencyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [rangeBtn setTitle:@"Features Per Card" forState:UIControlStateNormal];
    [rangeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"LOCAL_DATA_SAVED_FP"];
    [self setUI];
}

- (IBAction)selectCurrencyBtnClicked:(id)sender
{
    NSArray * arr = [[NSArray alloc] initWithObjects:@"USD",@"INR",@"EUR",nil];
    NSArray * arrImage = [[NSArray alloc] init];
    if(dropDown == nil)
    {
        CGFloat f = 100;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down" :[UIImage imageNamed:@"umTxt.png"]];
        dropDown.delegate = self;
    }
    else
    {
        [dropDown hideDropDown:sender];
        [self rel];
    }
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
    for (int i = 0; i<arr.count; i++)
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
        addCustomCell *cell = [featurePrioritizationTable dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"addCustomCellTwo" owner:self options:nil];
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
    featurePrioritizationCell *cell = [featurePrioritizationTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"featurePrioritizationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    featurePrioritizationTable.backgroundColor = [UIColor clearColor];
    featurePrioritizationTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    cell.featureTxt.text = [featureArray objectAtIndex:indexPath.row];
    cell.levelTxt.text = [levelArray objectAtIndex:indexPath.row];
    cell.costTxt.text = [costArray objectAtIndex:indexPath.row];
    cell.currencyTxt.inputView = pickerView;
    cell.currencyTxt.inputAccessoryView = toolBar;
    [cell.pictureBtn addTarget:self action:@selector(selectPictureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
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
        cell.indexNoLbl.text = [indexNoArray objectAtIndex:indexPath.row];
    }
       return cell;
    }
}

-(void)showSelectedImage:(featurePrioritizationCell *)cell index:(NSInteger)tableIndex
{
    if ([[imageDataArray objectAtIndex:tableIndex] isEqual:@" "])
    {
    }
    else
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(701, 4, 38, 38)];
        imgView.image = [UIImage imageWithData:[imageDataArray objectAtIndex:tableIndex]];
        [cell.contentView addSubview:imgView];
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
    [currencyTypeArr insertObject:@" " atIndex:currencyTypeArr.count-1];
    [costArray insertObject:@" " atIndex:costArray.count-1];
    [indexNoArray insertObject:[NSString stringWithFormat:@"%ld",(long)indexNo] atIndex:indexNoArray.count-1];
    [self calculateTableIndex];
    [featurePrioritizationTable reloadData];
    }
}

-(void)AddLevelBtnclicked:(id)sender
{
    if (rowCountArray.count == 1)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Please add feature before adding level"];
    }
    else if (rowCountArray.count-1 == 30)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"You can not add more than 30 levels"];
    }
    else
    {
        dataEditedFlag = YES;
        [rowCountArray insertObject:@"L" atIndex:rowCountArray.count-1];
        [levelArray insertObject:@" " atIndex:levelArray.count-1];
        [featureArray insertObject:@" " atIndex:featureArray.count-1];
        [imageDataArray insertObject:@" " atIndex:imageDataArray.count-1];
        [indexNoArray insertObject:@" " atIndex:indexNoArray.count-1];
        [currencyTypeArr insertObject:@" " atIndex:currencyTypeArr.count-1];
        [costArray insertObject:@" " atIndex:costArray.count-1];
        [self calculateTableIndex];
        [featurePrioritizationTable reloadData];
    }
}

-(void)deleteBtnClicked:(id)sender
{
    dataEditedFlag = YES;
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:featurePrioritizationTable];
    NSIndexPath *btnIndex = [featurePrioritizationTable indexPathForRowAtPoint:touchPoint];
    if ([[rowCountArray objectAtIndex:btnIndex.row] isEqualToString:@"L"])
    {
        [rowCountArray removeObjectAtIndex:btnIndex.row];
        [levelArray removeObjectAtIndex:btnIndex.row];
        [indexNoArray removeObjectAtIndex:btnIndex.row];
        [featureArray removeObjectAtIndex:btnIndex.row];
        [imageDataArray removeObjectAtIndex:btnIndex.row];
        [currencyTypeArr removeObjectAtIndex:btnIndex.row];
        [costArray removeObjectAtIndex:btnIndex.row];
        [featurePrioritizationTable reloadData];
    }
    else if ([[rowCountArray objectAtIndex:btnIndex.row] isEqualToString:@"F"])
    {
        int deleteCount = 1;
        for (int i = btnIndex.row ; i<rowCountArray.count; i++)
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
        [currencyTypeArr removeObjectsInRange:r];
        [costArray removeObjectsInRange:r];
        [self calculateTableIndex];
        [featurePrioritizationTable reloadData];
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
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:featurePrioritizationTable];
    NSIndexPath *clickedButtonIndexPath = [featurePrioritizationTable indexPathForRowAtPoint:touchPoint];
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
    [featurePrioritizationTable reloadData];
}

-(int)generateRandomNumberWithlowerBound
{
    int rndValue = 0000 + arc4random() % (9999 - 0000);
    return rndValue;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return currencyNameArr.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [currencyNameArr objectAtIndex:row];
}

-(void)webServiceToSaveSurveyName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
                       [dict setObject:surveyNameTxt.text forKey:@"SURVEY_NAME"];
                       [dict setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"ADMIN_ID"] forKey:@"CREATED_BY_ID"];
                       [dict setObject:@"Feature Prioritization survey" forKey:@"SURVEY_TYPE"];
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
                               [self errorResponse:@"Error saving survey"];
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
                       if ([[[result objectAtIndex:0]valueForKey:@"STATUS"] isEqualToString:@"SUCCESS"])
                       {
                           if ([btnClicked isEqualToString:@"SAVE"])
                           {
                               [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
                               [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"LOCAL_DATA_SAVED_FP"];
                               [self showAlertView:@"ALIVE 2.0" message:@"Data Saved successfully"];
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
                               [self errorResponse:@"Error saving survey"];
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
                           [self showAlertView:@"ALIVE 2.0" message:@"Survey name already exists"];
                       }
                       else  if ([[[result objectAtIndex:0]valueForKey:@"STATUS"] isEqualToString:@"SUCCESS"])
                       {
                           [rowCountArray addObject:@"A"];
                           [levelArray addObject:@" "];
                           [featureArray addObject:@" "];
                           [imageDataArray addObject:@" "];
                           [costArray addObject:@" "];
                           
                           previewPageObj = [[previewPage alloc]initWithNibName:@"previewPage" bundle:nil];
                           previewPageObj.surveyName = surveyNameTxt.text;
                           previewPageObj.range = [rangeBtn.currentTitle intValue];
                           previewPageObj.levelsArray = [[NSMutableArray alloc]initWithArray:levelArray];
                           previewPageObj.levelImgsArray = [[NSMutableArray alloc]initWithArray:imageDataArray];
                           NSLog(@"Survey ID = %@",[[result objectAtIndex:0]valueForKey:@"SURVEY_ID"]);
                           [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
                           [[NSUserDefaults standardUserDefaults] setValue:surveyNameTxt.text forKey:@"SURVEY_NAME"];

                           if ([btnClicked isEqualToString:@"SAVE"])
                           {
                               [[NSUserDefaults standardUserDefaults] setValue:[[result objectAtIndex:0]valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
                               [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"LOCAL_DATA_SAVED_FP"];
                           }
                           else
                           {
                               [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"LOCAL_DATA_SAVED_FP"];
                               previewPageObj.surveyId = [[result objectAtIndex:0]valueForKey:@"SURVEY_ID"];
                               [self.navigationController pushViewController:previewPageObj animated:YES];
                           }

                       }
                       else
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"Error saving data"];
                       }
                   });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"ALIVE 2.0" message:msg];
    [self showLoader:NO];

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
        [dict setObject:[costArray objectAtIndex:i] forKey:@"COST"];
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
    [dataDict setObject:surveyNameTxt.text forKey:@"SURVEY_NAME"];
    [dataDict setObject:selectCurrencyBtn.currentTitle forKey:@"CURRENCY"];
    [dataDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ADMIN_ID"] forKey:@"CREATED_BY"];
    [dataDict setObject:@"Feature Prioritization survey" forKey:@"SURVEY_TYPE"];
    [dataDict setObject:rangeBtn.currentTitle forKey:@"NO_OF_OPTIONS"];
    [dataDict setObject:maxNoOfCardsTxt.text forKey:@"NO_OF_CARDS"];
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
        containerView.frame = CGRectMake(29, 311, 887,360);
        featurePrioritizationTable.frame = CGRectMake(0, 0, 887, 360);
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
        containerView.frame = CGRectMake(29, 311, 887, 404);
        featurePrioritizationTable.frame = CGRectMake(0, 0, 887, 393);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [currentTxtField resignFirstResponder];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTxtField = textField;
    CGPoint touchPoint = [currentTxtField convertPoint:CGPointZero toView:featurePrioritizationTable];
    NSIndexPath *clickedButtonIndexPath = [featurePrioritizationTable indexPathForRowAtPoint:touchPoint];
    currentRowIndex = clickedButtonIndexPath.row;
    NSLog(@"Row index = %ld",(long)clickedButtonIndexPath.row);

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint touchPoint = [textField convertPoint:CGPointZero toView:featurePrioritizationTable];
    NSIndexPath *clickedButtonIndexPath = [featurePrioritizationTable indexPathForRowAtPoint:touchPoint];
    if (textField.tag == 201)
    {
        [featureArray replaceObjectAtIndex:currentRowIndex withObject:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

       // [featureArray replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    else if (textField.tag == 202)
    {
        [levelArray replaceObjectAtIndex:currentRowIndex withObject:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

       // [levelArray replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    else if (textField.tag == 203)
    {
        [costArray replaceObjectAtIndex:currentRowIndex withObject:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

        //[costArray replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    else if (textField.tag == 204)
    {
        [currencyTypeArr replaceObjectAtIndex:currentRowIndex withObject:[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

       // [currencyTypeArr replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }

    [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)stringb
{
    
    if (textField == maxNoOfCardsTxt || textField.tag == 203)
    {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
        
        NSString *filtered = [[stringb componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        return [stringb isEqualToString:filtered];
    }
    return YES;
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
        // movementDistance = -120;
    }
    else
    {
        // movementDistance = -140;
    }
    
    const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
