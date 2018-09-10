//
//  maxDiffOutput.m
//  mckinsey
//
//  Created by Mac on 26/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "maxDiffOutput.h"
#import "dashboard.h"
#import "PNChart.h"
#import "Reachability.h"
#import "NSMutableArray+TTMutableArray.h"
#import "constant.h"
#import "loadingPage.h"
#import "maxDiffOutputCell.h"
#import "maxDiffGraph.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>
#import "LocationHeadTableViewCell.h"
#import "LocationSubHeadTableViewCell.h"
#import "CheckBoxHeadTableViewCell.h"
#import "CheckBoxSubHeadTableViewCell.h"
#import "SliderTableViewCell.h"
#import "TextFieldTableViewCell.h"
#import "CheckBoxSubHeadTableViewCell.h"
#import "MultipleSelectViewController.h"
#import "MISCollectionViewCell.h"
#import "SectionHeaderCollectionReusableView.h"
#import "PositiveNegativeGraphTableViewCell.h"
#import "APIManager.h"

@interface maxDiffOutput () <LocationProtocol,sliderProtocolDelegate,UIPopoverPresentationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    loadingPage *loadingPageObj;
    IBOutlet UITableView *maxDiffOutputTable;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    NSMutableArray *dataArray;
    NSMutableArray *featureNameArr;
    NSMutableArray *levelArr;
    NSMutableArray *scoreArr;
    NSMutableArray *featureValue;
    NSMutableArray *mostPrefArr;
    NSMutableArray *leastPrefArr;
    
    NSInteger mostPreMax;
    NSInteger leastPreMax;
    
    UIView *blurView;
    
    NSMutableArray *demographicsArray;
    NSMutableArray *selectedDemoGraphicsList;
    NSInteger respondantCount;
    NSMutableArray *countryIDs;
    NSMutableArray *stateIDs;
    NSMutableArray *cityIDs;
    NSMutableArray *selectedCountries;
    NSMutableArray *selectedStates;
    NSMutableArray *selectedCities;
    NSMutableDictionary *finalSelectedValues;
    NSMutableArray *countArray;
    
    BOOL isSelectAll;
    
    NSString *surveyName;
    
}
@property (weak, nonatomic) IBOutlet UILabel *surveyNameLabel;

@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderViewTrailingContraint;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)viewGraphBtnClicked:(id)sender;
- (IBAction)exportBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *attributeCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *totalRespondantLabel;
@property (weak, nonatomic) IBOutlet UISwitch *selectAllAttributeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *filteredCountLabel;

@end

@implementation maxDiffOutput
@synthesize surveyDetailArr,surveyId,surveyName;

-(void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];

    isSelectAll = true;
    //[self showLoader:YES];
    //[self callWebserviceToFetchScore];
    
    blurView = [[UIView alloc] initWithFrame:self.view.frame];
    blurView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addGestures];
    //[self loadGraph:_values];
    [self fetchAttributes];
}


#pragma mark - Webservices

- (void)fetchAttributes {
    
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/get_predefined_controls_user.php" andParam:@{@"DATA":surveyId} withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if (isSuccess) {
            NSLog(@"%@",response);
            demographicsArray = [[NSMutableArray alloc] init];
            [demographicsArray addObjectsFromArray:response];
            
            NSMutableDictionary *tempLocDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *tempTextBoxDict = [[NSMutableDictionary alloc] init];
            for (NSMutableDictionary *tempDict in demographicsArray) {
                if ([[tempDict objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
                    tempLocDict = tempDict;
                }
                if ([[tempDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"TextBox"]) {
                    tempTextBoxDict = tempDict;
                }
                if ([[tempDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"Toggle Switch"]) {
                    NSMutableArray *switchArray = [[NSMutableArray alloc] init];
                    [switchArray addObject:[@{@"OPTION_NAME":@"Yes"} mutableCopy]];
                    [switchArray addObject:[@{@"OPTION_NAME":@"No"} mutableCopy]];
                    [tempDict setObject:switchArray forKey:@"OPTIONS"];
                    //[[tempDict objectForKey:@"OPTIONS"] insertObject:[@{@"OPTION_NAME":@"No"} mutableCopy] atIndex:1];
                }
            }
            
            surveyName = [response[0] valueForKey:@"SURVEY_NAME"];

            [demographicsArray removeObject:tempLocDict];
            [demographicsArray removeObject:tempTextBoxDict];
            [demographicsArray insertObject:tempLocDict atIndex:0];
            
            selectedDemoGraphicsList = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:demographicsArray]];
            
            NSMutableDictionary *locationDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *textBoxDict = [[NSMutableDictionary alloc] init];
            
            for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
                
                respondantCount = [[attributeDict objectForKey:@"RESPONDANT_COUNT"] integerValue];
                [attributeDict setObject:@"YES" forKey:@"SWITCH_VALUE"];
                
                if ([[attributeDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"TextBox"]) {
                    textBoxDict = attributeDict;
                    continue;
                }
                
                if ([[attributeDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"Toggle Switch"]) {
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:@"Yes" forKey:@"OPTION_NAME"];
                }
                
                for (NSMutableDictionary *optionDict in [attributeDict objectForKey:@"OPTIONS"]) {
                    [optionDict setObject:@"YES" forKey:@"CHECKBOX_VALUE"];
                }
                
                if ([[attributeDict objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:@"Country" forKey:@"BUTTON_NAME"];
                    
                    countryIDs = [[NSMutableArray alloc] init];
                    [countryIDs addObjectsFromArray:[[[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","]];
                    
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:1] setObject:@"State" forKey:@"BUTTON_NAME"];
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:2] setObject:@"City" forKey:@"BUTTON_NAME"];
                    locationDict = attributeDict;
                }
                
            }
            [selectedDemoGraphicsList removeObject:locationDict];
            [selectedDemoGraphicsList removeObject:textBoxDict];
            [selectedDemoGraphicsList insertObject:locationDict atIndex:0];
            [self.filterTableView reloadData];
            [self fetchInitialGraphDetails];
        }
        else {
            
        }
    }];
}

-(void)fetchInitialGraphDetails {
    
    finalSelectedValues = [[NSMutableDictionary alloc] init];
    NSMutableArray *attributeArray = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
        
        if (![[attributeDict objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
            if ([[attributeDict objectForKey:@"SWITCH_VALUE"] isEqualToString:@"YES"]) {
                NSMutableDictionary *selectedAttributeDict = [[NSMutableDictionary alloc] init];
                
//                NSString *identifier = [dict stringForKey:@"identifier"];
//
//                if([identifier length] != 0)
//                    [postDatas setObject:identifier forKey:@"device_uid"];
//                else
//                    [postDatas setObject:@"" forKey:@"device_uid"];
                
//                [selectedAttributeDict setObject:@"manoj set attribute" forKey:@"ATTRIBUTE_NAME"];
                if ([attributeDict objectForKey:@"ATTRIBUTE_NAME"] == nil) {
                    
                }else {
                [selectedAttributeDict setObject:[attributeDict objectForKey:@"ATTRIBUTE_NAME"] forKey:@"ATTRIBUTE_NAME"];
                }
                // remaining
                if ([attributeDict objectForKey:@"INPUT_TYPE"] == nil) {
                    
                }else {
                [selectedAttributeDict setObject:[attributeDict objectForKey:@"INPUT_TYPE"] forKey:@"INPUT_TYPE"];
                }
                if ([attributeDict objectForKey:@"PRE_ID"] == nil) {
                    
                }else {
                [selectedAttributeDict setObject:[attributeDict objectForKey:@"PRE_ID"] forKey:@"PRE_ID"];
                }
                NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
                for (NSDictionary *option in [attributeDict objectForKey:@"OPTIONS"]) {
                    if ([[option objectForKey:@"CHECKBOX_VALUE"] isEqualToString:@"YES"]) {
                        [selectedOptions addObject:option];
                    }
                }
                [selectedAttributeDict setObject:selectedOptions forKey:@"OPTIONS"];
                [attributeArray addObject:selectedAttributeDict];
            }
        }
    }
    
    [finalSelectedValues setObject:attributeArray forKey:@"DATA"];
    [finalSelectedValues setObject:surveyId forKey:@"SURVEY_ID"];
    
    for (NSDictionary *attribute in selectedDemoGraphicsList) {
        
        if ([[attribute objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
            
            NSLog(@"%@",[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"]);
            
            NSLog(@"%@",[[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","]);
            
            countryIDs = [[NSMutableArray alloc] init];
            [countryIDs addObjectsFromArray:[[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","]];
            
            [finalSelectedValues setObject:[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] forKey:@"COUNTRY_ID"];
            
            [finalSelectedValues setObject:[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:1] objectForKey:@"OPTION_NAME"]  forKey:@"STATE_ID"];
            
            [finalSelectedValues setObject:[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:2] objectForKey:@"OPTION_NAME"]  forKey:@"CITY_ID"];
        }
    }
    
    NSLog(@"%@",finalSelectedValues);
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/maxDiffGraphDetail.php" andParam:finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if (isSuccess) {
            NSLog(@"%@",response);
            NSLog(@"%@",globalSurveyType);
            
            if ([[response objectForKey:@"MSG"] isEqualToString:@"FAIL"]) {
                [self showAlertView:@"Alive 2.0" message:@"No respondent"];
                countArray = [[NSMutableArray alloc] init];
                [self.attributeCollectionView reloadData];
            }
            else {
                if (![[response objectForKey:@"COUNT"] isKindOfClass:[NSNull class]]) {
                    countArray = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"COUNT"]];
                    [self.attributeCollectionView reloadData];
                }
                [self graphDataWebserviceResponse:response];
            }
        }
    }];
}

-(void)graphDataWebserviceResponse:(NSDictionary  *)response
{
    _surveyNameLabel.text = [NSString stringWithFormat:@"Survey Name : %@",surveyName];
    NSMutableArray *result = [response objectForKey:@"GRAPH_DATA"];
    [self responseResult:result];
    if (![[response objectForKey:@"TOTAL_COUNT"] isKindOfClass:[NSNull class]]) {
        _filteredCountLabel.text = [NSString stringWithFormat:@"Total filtered count : %@",[response objectForKey:@"TOTAL_COUNT"]];
    }
    else {
        _filteredCountLabel.text = @"";
    }
}


#pragma mark - CollectionView Delegate/DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger count = 0;
    for (NSDictionary *attributeDict in countArray) {
        if ([[attributeDict objectForKey:@"OPTIONS"] count]) {
            count++;
        }
    }
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[countArray objectAtIndex:section] objectForKey:@"OPTIONS"] count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MISCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.optionNameLabel.text = [NSString stringWithFormat:@"%@ - %@",[[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allKeys] objectAtIndex:indexPath.row],[[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allValues] objectAtIndex:indexPath.row]];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerView" forIndexPath:indexPath];
    if (kind == UICollectionElementKindSectionHeader) {
        //[header.headLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
        NSLog(@"%@",[[countArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"]);
        header.headLabel.text = [[countArray objectAtIndex:indexPath.section] objectForKey:@"ATTRIBUTE_NAME"];
        
        return header;
    }
    else {
        
        return header;
    }
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (collectionView == _attributeCollectionView) {
        return CGSizeMake(164, 40);
    }
    else {
        return CGSizeMake(0, 0);
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == _attributeCollectionView) {
        
        NSString *testString = [self getMaxLengthString:[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allKeys]];
        CGSize calCulateSizze =[testString sizeWithAttributes:NULL];
        calCulateSizze.width = calCulateSizze.width+100;
        calCulateSizze.height = 40;
        return calCulateSizze;
    }
    else {
        
        return CGSizeMake(collectionView.frame.size.width, 45);
    }
}

- (NSString *)getMaxLengthString:(NSArray *)sectionArray {
    NSString *maxStr = @"";
    NSUInteger maxLen = 0, strLen;
    for (NSString *attributeStr in sectionArray) {
        strLen = [attributeStr length];
        if (strLen > maxLen) {
            maxLen = strLen;
            maxStr = attributeStr;
        }
    }
    return maxStr;
}

#pragma mark - Gesture Methods
- (void)addGestures {
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightGesture:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.sliderView addGestureRecognizer:swipeRight];
    [blurView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer * swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftGesture:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightGesture:)];
    [blurView addGestureRecognizer:tapOnView];
}

- (void)swipeRightGesture:(UISwipeGestureRecognizer *) sender {
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [blurView setAlpha:0];
        _sliderViewTrailingContraint.constant =  -400;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [blurView removeFromSuperview];
    }];
}

- (void)swipeLeftGesture:(UISwipeGestureRecognizer *) sender {
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:0.5];
        [self.view addSubview:blurView];
        [self.view bringSubviewToFront:_sliderView];
        _sliderViewTrailingContraint.constant =  0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)callWebserviceToFetchScore
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"levelScore.php"]]];
                       
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
                                                                                 NSError *error)
                       {
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
                       NSArray *resultArr = [[result reverseObjectEnumerator] allObjects];
                       featureNameArr = [[NSMutableArray alloc]init];
                       levelArr = [[NSMutableArray alloc]init];
                       scoreArr = [[NSMutableArray alloc]init];
                       mostPrefArr= [[NSMutableArray alloc]init];
                       leastPrefArr = [[NSMutableArray alloc]init];
                       featureValue = [[NSMutableArray alloc]init];
                       
                       for (int i = 0; i<resultArr.count; i++)
                       {
                           [featureNameArr addObject:[[resultArr objectAtIndex:i]valueForKey:@"FEATURE"]];
                           [levelArr addObject:[[resultArr objectAtIndex:i]valueForKey:@"LEVEL_NAME"]];
                           if ([[resultArr objectAtIndex:i]valueForKey:@"SCORE"]) {
                               [scoreArr addObject:[[resultArr objectAtIndex:i]valueForKey:@"SCORE"]];
                           }
                           else {
                               [scoreArr addObject:@"NA"];
                           }
                           [mostPrefArr addObject:[[resultArr objectAtIndex:i]valueForKey:@"BEST_COUNT"]];
                           [leastPrefArr addObject:[[resultArr objectAtIndex:i]valueForKey:@"WORST_COUNT"]];
                           [featureValue addObject:[[resultArr objectAtIndex:i]valueForKey:@"FEATURE_VALUE"]];

                       }
                       mostPreMax = [[mostPrefArr valueForKeyPath:@"@max.intValue"] intValue];
                       leastPreMax = [[leastPrefArr valueForKeyPath:@"@max.intValue"] intValue];
                       [maxDiffOutputTable reloadData];


//                       for (int i = 0; i<infoArray.count; i++)
//                       {
//                           [featureNameArr addObject:[[infoArray objectAtIndex:i]valueForKey:@"FEATURE"]];
//                           for (int j = 0; j<[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"] count]; j++)
//                           {
//                               if (j == 0)
//                               {
//                                   [levelArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"LEVEL_NAME"]];
//                                   [scoreArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"SCORE"]];
//                                   [mostPrefArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"BEST_COUNT"]];
//                                   [leastPrefArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"WORST_COUNT"]];
//                                   [featureValue addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"FEATURE_VALUE"]];
//                               }
//                               else
//                               {
//                                   [featureNameArr addObject:@" "];
//                                   [levelArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"LEVEL_NAME"]];
//                                   [scoreArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"SCORE"]];
//                                   [mostPrefArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"BEST_COUNT"]];
//                                   [leastPrefArr addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"WORST_COUNT"]];
//                                   [featureValue addObject:[[[[infoArray objectAtIndex:i]valueForKey:@"LEVEL"]objectAtIndex:j]valueForKey:@"FEATURE_VALUE"]];
//
//                               }
//                           }
//                       }
                    });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"ALIVE 2.0" message:msg];
    [self showLoader:NO];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _filterTableView) {
        return [demographicsArray count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (tableView == _filterTableView) {
        {
            if ([[[demographicsArray objectAtIndex:section] objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
                return [[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] count];
            }
            else if ([[[demographicsArray objectAtIndex:section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"RadioButton"]) {
                return [[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] count];
            }
            else if ([[[demographicsArray objectAtIndex:section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"CheckBox"]) {
                return [[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] count];
            }
            else if ([[[demographicsArray objectAtIndex:section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Toggle Switch"]) {
                return [[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] count];
            }
            else if ([[[demographicsArray objectAtIndex:section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"DropdownList"] || [[[demographicsArray objectAtIndex:section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Range"]) {
                return [[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] count];
            }
            else if([[[demographicsArray objectAtIndex:section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"TextBox"]) {
                return 0;
            }
            return 1;
        }
    }
    else {
        return featureNameArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView == _filterTableView) {
        {
            
            if ([[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
                if (indexPath.row == 0) {
                    LocationHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationHeadCell"];
                    if (cell == nil) {
                        cell = [[LocationHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationHeadCell"];
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectCountryBtn.tag = indexPath.section*100+indexPath.row;
                    NSLog(@"%@",[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"ATTRIBUTE_NAME"]);
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    if ([countryIDs count]) {
                        [cell.selectCountryBtn setTitle:[NSString stringWithFormat:@"%lu country selected",(unsigned long)[countryIDs count]] forState:UIControlStateNormal];
                    }
                    else {
                        [cell.selectCountryBtn setTitle:[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"BUTTON_NAME"] forState:UIControlStateNormal];
                    }
                    
                    [cell.selectCountryBtn addTarget:self action:@selector(countryBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;
                }
                else {
                    LocationSubHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationSubHeadCell"];
                    if (cell == nil) {
                        cell = [[LocationSubHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationSubHeadCell"];
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.selectBtn.tag = indexPath.section*100+indexPath.row;
                    cell.backgroundColor = [UIColor clearColor];
                    
                    if (indexPath.row == 1) {
                        if ([stateIDs count]) {
                            [cell.selectBtn setTitle:[NSString stringWithFormat:@"%lu state selected",(unsigned long)[stateIDs count]] forState:UIControlStateNormal];
                        }
                        else {
                            [cell.selectBtn setTitle:[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"BUTTON_NAME"] forState:UIControlStateNormal];
                        }
                        [cell.selectBtn addTarget:self action:@selector(selectStateBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else {
                        if ([cityIDs count]) {
                            [cell.selectBtn setTitle:[NSString stringWithFormat:@"%lu city selected",(unsigned long)[cityIDs count]] forState:UIControlStateNormal];
                        }
                        else {
                            [cell.selectBtn setTitle:[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"BUTTON_NAME"] forState:UIControlStateNormal];
                        }
                        
                        [cell.selectBtn addTarget:self action:@selector(selectStateBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    return cell;
                }
            }
            else if ([[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"RadioButton"] || [[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"CheckBox"] || [[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"DropdownList"] || [[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Range"] || [[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Toggle Switch"]) {
                
                if (indexPath.row == 0) {
                    
                    CheckBoxHeadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"checkBoxHeadcell"];
                    if (cell == nil) {
                        cell = [[[CheckBoxHeadTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"checkBoxHeadcell"];
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.attributeNameLabel.text = [[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"ATTRIBUTE_NAME"];
                    [cell.checkBoxBtn setTitle:[[[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"OPTION_NAME"] forState:UIControlStateNormal];
                    if ([[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"CHECKBOX_VALUE"] isEqualToString:@"YES"]) {
                        [cell.checkBoxBtnImg setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
                    }
                    else {
                        [cell.checkBoxBtnImg setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
                    }
                    if ([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"SWITCH_VALUE"] isEqualToString:@"YES"]) {
                        [cell.attributeSwitch setOn:YES];
                        [cell.checkBoxBtnImg setEnabled:YES];
                        [cell.checkBoxBtn setEnabled:YES];
                    }
                    else {
                        [cell.attributeSwitch setOn:NO];
                        [cell.checkBoxBtnImg setEnabled:NO];
                        [cell.checkBoxBtn setEnabled:NO];
                    }
                    cell.attributeSwitch.tag = indexPath.section*100+indexPath.row;
                    [cell.attributeSwitch addTarget:self action:@selector(attributeSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
                    
                    cell.checkBoxBtn.tag = indexPath.section*100+indexPath.row;
                    cell.checkBoxBtnImg.tag = indexPath.section*100+indexPath.row;
                    [cell.checkBoxBtn addTarget:self action:@selector(checkBoxBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.checkBoxBtnImg addTarget:self action:@selector(checkBoxBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                else {
                    CheckBoxSubHeadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"checkBoxSubHeadCell"];
                    if (cell == nil) {
                        cell = [[[CheckBoxSubHeadTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"checkBoxSubHeadCell"];
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.checkBoxNameBtn setTitle:[[[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"OPTION_NAME"] forState:UIControlStateNormal];
                    if ([[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"CHECKBOX_VALUE"] isEqualToString:@"YES"]) {
                        [cell.checkBoxBtnImg setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
                    }
                    else {
                        [cell.checkBoxBtnImg setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
                    }
                    if ([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"SWITCH_VALUE"] isEqualToString:@"YES"]) {
                        [cell.checkBoxBtnImg setEnabled:YES];
                        [cell.checkBoxNameBtn setEnabled:YES];
                    }
                    else {
                        [cell.checkBoxBtnImg setEnabled:NO];
                        [cell.checkBoxNameBtn setEnabled:NO];
                    }
                    cell.checkBoxNameBtn.tag = indexPath.section*100+indexPath.row;
                    cell.checkBoxBtnImg.tag = indexPath.section*100+indexPath.row;
                    [cell.checkBoxNameBtn addTarget:self action:@selector(checkBoxBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.checkBoxBtnImg addTarget:self action:@selector(checkBoxBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            else if ([[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Slider"]){
                SliderTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"sliderCell"];
                if (cell == nil) {
                    cell = [[[SliderTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sliderCell"];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.attributeNameLabel.text = [[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"ATTRIBUTE_NAME"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.attributeSwitch.tag = indexPath.section*100+indexPath.row;
                [cell.attributeSwitch addTarget:self action:@selector(attributeSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
                
                //cell.sliderLabel.text = [[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"];
                float min = [[[[[[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@"-"] objectAtIndex:0] floatValue];
                float max = [[[[[[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@"-"] objectAtIndex:1] floatValue];
                
                cell.delegate = self;
                cell.nmRangeSlider.tag = indexPath.section;
                [cell updateSliderLabels:indexPath.section];
                [cell configureSliderMin:min andMax:max];
                cell.nmRangeSlider.minimumRange = min;
                cell.nmRangeSlider.maximumValue = max;
                
                [cell.rangeSlider setMinimumValue:min];
                [cell.rangeSlider setMaximumValue:max];
                
                if ([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"SWITCH_VALUE"] isEqualToString:@"YES"]) {
                    [cell.attributeSwitch setOn:YES];
                    [cell.rangeSlider setEnabled:YES];
                    [cell.nmRangeSlider setEnabled:YES];
                    //[cell.rangeSlider setMaximumValue:max];
                }
                else {
                    [cell.nmRangeSlider setEnabled:NO];
                    [cell.attributeSwitch setOn:NO];
                    [cell.rangeSlider setEnabled:NO];
                }
                
                [cell.rangeSlider setValue:[[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] floatValue] animated:YES];
                cell.rangeSlider.tag = indexPath.section*100+indexPath.row;
                [cell.rangeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                
                return cell;
            }
            else if ([[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"TextBox"]) {
                TextFieldTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
                if (cell == nil) {
                    cell = [[[TextFieldTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldCell"];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.attributeLabel.text = [[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"ATTRIBUTE_NAME"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                _surveyNameLabel.text = [NSString stringWithFormat:@"Survey Name : %@",surveyName];
                
                cell.attributeSwitch.tag = indexPath.section*100+indexPath.row;
                [cell.attributeSwitch addTarget:self action:@selector(attributeSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
                if ([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"SWITCH_VALUE"] isEqualToString:@"YES"]) {
                    [cell.attributeSwitch setOn:YES];
                }
                else {
                    [cell.attributeSwitch setOn:NO];
                }
                return cell;
            }
        }
    }
    else {
        NSString *cellIdentifier = @"cell";
        maxDiffOutputCell *cell = [maxDiffOutputTable dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"maxDiffOutputCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if ([[featureNameArr objectAtIndex:indexPath.row] isEqualToString:@" "])
        {
            cell.featureNameLbl.hidden = YES;
            cell.featureNameLblBgImg.hidden = YES;
        }
        else
        {
            cell.featureNameLbl.hidden = NO;
            cell.featureNameLblBgImg.hidden = NO;
        }
        cell.featureNameLbl.text = [featureNameArr objectAtIndex:indexPath.row];
        cell.levelNameLbl.text = [levelArr objectAtIndex:indexPath.row];
        cell.scoreLbl.text = [scoreArr objectAtIndex:indexPath.row];
        cell.featureValueLbl.text = [featureValue objectAtIndex:indexPath.row];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
    //    CGFloat radians = atan2f(cell.progressBarRoundedFat.transform.b, cell.progressBarRoundedFat.transform.a);
    //    CGFloat degrees = radians * (180 / M_PI);
    //    CGAffineTransform transform = CGAffineTransformMakeRotation((180 + degrees) * M_PI/180);
    //    cell.progressBarRoundedFat.transform = transform;
        
        cell.progressBarRoundedFat.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
        cell.progressBarRoundedFat1.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
        
        
        [cell.progressBarRoundedFat setProgress:([[mostPrefArr objectAtIndex:indexPath.row] floatValue]/mostPreMax) animated:YES];
        [cell.progressBarRoundedFat1 setProgress:([[leastPrefArr objectAtIndex:indexPath.row] floatValue]/leastPreMax) animated:YES];
        
        cell.progressBarRoundedFat.indicatorTextLabel.text = [mostPrefArr objectAtIndex:indexPath.row];
        cell.progressBarRoundedFat1.indicatorTextLabel.text = [NSString stringWithFormat:@"%@ %@",@"-",[leastPrefArr objectAtIndex:indexPath.row]];
        
    //    CGFloat radians1 = atan2f(cell.progressBarRoundedFat.indicatorTextLabel.transform.b, cell.progressBarRoundedFat.indicatorTextLabel.transform.a);
    //    CGFloat degrees1 = radians1 * (180 / M_PI);
    //    CGAffineTransform transform1 = CGAffineTransformMakeRotation((180 + degrees1) * M_PI/180);
    //    cell.progressBarRoundedFat.indicatorTextLabel.transform = transform1;
    //
    //
        [cell.progressBarRoundedFat1 setProgressTintColors:@[[UIColor colorWithRed:248/255.0 green:48.0/255.0 blue:40.0/255.0 alpha:1.0]]];
        [cell.progressBarRoundedFat setProgressTintColors:@[[UIColor colorWithRed:0.0/255.0 green:208/255.0 blue:88/255.0 alpha:1.0]]];
        maxDiffOutputTable.backgroundColor = [UIColor clearColor];
        maxDiffOutputTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        return cell;
    }
    CheckBoxSubHeadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"checkBoxHeadCell"];
    if (cell == nil) {
        cell = [[[CheckBoxSubHeadTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"checkBoxHeadCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _filterTableView) {
        if([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Slider"]) {
            return 70;
        }
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // recast your view as a UITableViewHeaderFooterView
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.layer.frame.size.width, 1)];
    header.backgroundView.backgroundColor = [UIColor clearColor];
    header.textLabel.textColor = [UIColor blackColor];
    [header.textLabel setFont:[UIFont fontWithName:@"Rubik-Regular" size:15.0]];
    // make a view with height = 1 attached to header bottom
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, header.frame.size.height, header.frame.size.width, 1)];
    [separator setBackgroundColor:[UIColor blackColor]];
    [header addSubview:separator];
    return header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _filterTableView){
        return 1;
    }
    return 0;
}


#pragma mark - Selector Methods

- (void)attributeSwitchValueChange:(UISwitch *)sender {
    
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    if ([sender isOn]) {
        if ([[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Slider"]) {
            [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:[[[[[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@"-"] objectAtIndex:1] forKey:@"OPTION_NAME"];
        }
        [[selectedDemoGraphicsList objectAtIndex:section] setObject:@"YES" forKey:@"SWITCH_VALUE"];
    }
    else {
        [[selectedDemoGraphicsList objectAtIndex:section] setObject:@"NO" forKey:@"SWITCH_VALUE"];
    }
    
    for (NSMutableDictionary *optionDict in [[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"]) {
        
        if ([sender isOn]) {
            [optionDict setObject:@"YES" forKey:@"CHECKBOX_VALUE"];
        }
        else {
            [optionDict setObject:@"NO" forKey:@"CHECKBOX_VALUE"];
        }
    }
    
    
    [self.filterTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)checkBoxBtnPressed:(UIButton *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    if ([[[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] objectForKey:@"CHECKBOX_VALUE"] isEqualToString:@"YES"]) {
        [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:@"NO" forKey:@"CHECKBOX_VALUE"];
    }
    else {
        [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:@"YES" forKey:@"CHECKBOX_VALUE"];
    }
    [self.filterTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)toggleSwitchValueChanged:(UISwitch *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    if ([[[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] objectForKey:@"CHECKBOX_VALUE"] isEqualToString:@"YES"]) {
        [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:@"NO" forKey:@"CHECKBOX_VALUE"];
        [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:@"No" forKey:@"OPTION_NAME"];
    }
    else {
        [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:@"YES" forKey:@"CHECKBOX_VALUE"];
        [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:@"Yes" forKey:@"OPTION_NAME"];
    }
    [self.filterTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    SliderTableViewCell *cell = [self.filterTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    cell.sliderLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    
    //NSString *rangeStr = [NSString stringWithFormat:@"%d - %@",(int)sender.minimumValue,cell.textLabel.text];
    [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] setObject:cell.sliderLabel.text forKey:@"OPTION_NAME"];
    
    NSLog(@"%f", sender.value);
}


-(void)countryBtnPressed:(UIButton *)sender {
    
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    selectedCountries = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *countryJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSArray *userCountryIDs = [[[[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","];
    
    for (NSString *countryID in userCountryIDs) {
        for (NSMutableDictionary *country in [[countryJson objectAtIndex:1] objectForKey:@"COUNTRY"]) {
            
            if ([[country objectForKey:@"id"] isEqualToString:countryID]) {
                
                if ([countryIDs containsObject:[country objectForKey:@"id"]]) {
                    NSMutableDictionary *tempDict = [country mutableCopy];
                    [tempDict setObject:@"YES" forKey:@"isSelected"];
                    [selectedCountries addObject:tempDict];
                }
                else {
                    [selectedCountries addObject:[country mutableCopy]];
                }
            }
        }
    }
    NSMutableDictionary *countryDict = [[NSMutableDictionary alloc] init];
    [countryDict setObject:[selectedCountries mutableCopy] forKey:@"COUNTRY"];
    selectedCountries = [[NSMutableArray alloc] init];
    [selectedCountries addObject:countryDict];
    
    NSMutableDictionary *selectAllDict = [[NSMutableDictionary alloc] init];
    //[[[[countryJson objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] mutableCopy];
    NSLog(@"%@",[[[countryJson objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0]);
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[[[[countryJson objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] mutableCopy]];
    [selectAllDict setObject:@[tempDict] forKey:@"COUNTRY"];
    [selectAllDict setObject:@"" forKey:@"SECTION_NAME"];
    [selectedCountries insertObject:[selectAllDict mutableCopy]  atIndex:0];
    
    MultipleSelectViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MultipleSelectViewController"];
    controller.delegate = self;
    controller.modalPresentationStyle = UIModalPresentationPopover;
    if ([selectedCountries count]) {
        controller.infoArray = selectedCountries;
    }
    controller.locationType = @"COUNTRY";
    // configure the Popover presentation controller
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.delegate = self;
    popController.sourceRect = sender.frame;
    popController.sourceView = sender.superview;
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)selectStateBtnPressed:(UIButton *)sender {
    
    if ([sender.titleLabel.text rangeOfString:@"state" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        MultipleSelectViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MultipleSelectViewController"];
        controller.delegate = self;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        
        if ([selectedStates count]) {
            controller.infoArray = selectedStates;
        }
        else {
            [self fetchCountries:0 andSection:0];
            [self getAllCountry:selectedCountries];
            controller.infoArray = selectedStates;
        }
        controller.locationType = @"STATE";
        // configure the Popover presentation controller
        UIPopoverPresentationController *popController = [controller popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.sourceRect = sender.frame;
        popController.sourceView = sender.superview;
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        MultipleSelectViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MultipleSelectViewController"];
        controller.delegate = self;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        if ([selectedCities count]) {
            controller.infoArray = selectedCities;
        }
        // controller.inforArray = selectedCities;
        controller.locationType = @"CITY";
        // configure the Popover presentation controller
        UIPopoverPresentationController *popController = [controller popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.sourceRect = sender.frame;
        popController.sourceView = sender.superview;
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

- (NSMutableArray *)fetchCountries:(NSInteger )row andSection:(NSInteger )section {
    selectedCountries = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *countryJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSArray *userCountryIDs = [[[[[demographicsArray objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:row] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","];
    
    for (NSString *countryID in userCountryIDs) {
        for (NSMutableDictionary *country in [[countryJson objectAtIndex:1] objectForKey:@"COUNTRY"]) {
            
            if ([[country objectForKey:@"id"] isEqualToString:countryID]) {
                
                if ([countryIDs containsObject:[country objectForKey:@"id"]]) {
                    NSMutableDictionary *tempDict = [country mutableCopy];
                    [tempDict setObject:@"YES" forKey:@"isSelected"];
                    [selectedCountries addObject:tempDict];
                }
                else {
                    [selectedCountries addObject:[country mutableCopy]];
                }
            }
        }
    }
    NSMutableDictionary *countryDict = [[NSMutableDictionary alloc] init];
    [countryDict setObject:[selectedCountries mutableCopy] forKey:@"COUNTRY"];
    selectedCountries = [[NSMutableArray alloc] init];
    [selectedCountries addObject:countryDict];
    
    NSMutableDictionary *selectAllDict = [[NSMutableDictionary alloc] init];
    //[[[[countryJson objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] mutableCopy];
    NSLog(@"%@",[[[countryJson objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0]);
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[[[[countryJson objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] mutableCopy]];
    [selectAllDict setObject:@[tempDict] forKey:@"COUNTRY"];
    [selectAllDict setObject:@"" forKey:@"SECTION_NAME"];
    [selectedCountries insertObject:[selectAllDict mutableCopy]  atIndex:0];
    return selectedCountries;
}

#pragma mark - Slider Delegate
- (void)updateSliderValues:(NSInteger)section andLowerValue:(NSString *)lValue andUpper:(NSString *)uValue {
    [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:[NSString stringWithFormat:@"%@-%@",lValue,uValue]  forKey:@"OPTION_NAME"];
}

#pragma mark - Location delegate
- (void)getAllCountry:(NSArray *)countryList {
    NSLog(@"count %lu",(unsigned long)[countryList count]);
    NSLog(@"list %@",countryList);
    
    selectedCountries = [[NSMutableArray alloc] initWithArray:countryList];
    countryIDs = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"State" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *stateJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    selectedStates = [[NSMutableArray alloc] init];
    
    NSArray *userStateIDs;
    for (NSDictionary *attribute in selectedDemoGraphicsList) {
        if ([[attribute objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
            
            userStateIDs = [[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:1] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","];
        }
    }
    
    for (NSDictionary *contry in [[countryList objectAtIndex:1] objectForKey:@"COUNTRY"]) {
        if ([[contry objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            
            NSMutableDictionary *states = [[NSMutableDictionary alloc] init];
            [states setObject:[contry objectForKey:@"name"] forKey:@"COUNTRY_NAME"];
            NSMutableArray *stateArray = [[NSMutableArray alloc] init];
            for (NSDictionary *state in stateJson) {
                
                if([[contry objectForKey:@"id"] isEqualToString:[state objectForKey:@"country_id"]]) {
                    
                    for (NSString *userStateID in userStateIDs) {
                        if ([[state objectForKey:@"id"] isEqualToString:userStateID]) {
                            [stateArray addObject:state];
                        }
                    }
                }
            }
            [states setObject:stateArray forKey:@"STATES"];
            [selectedStates addObject:states];
            [countryIDs addObject:[contry objectForKey:@"id"]];
        }
    }
    
    NSMutableDictionary * selectAll = [[NSMutableDictionary alloc] init];
    [selectAll setObject:@"Select all" forKey:@"name"];
    [selectAll setObject:@"NO" forKey:@"isSelected"];
    NSMutableArray *stateArray = [[NSMutableArray alloc] init];
    [stateArray addObject:selectAll];
    NSMutableDictionary *firstDict = [[NSMutableDictionary alloc] init];
    [firstDict setObject:stateArray forKey:@"STATES"];
    [firstDict setObject:@"" forKey:@"COUNTRY_NAME"];
    
    [selectedStates insertObject:firstDict atIndex:0];
    
    for (NSDictionary *obj in selectedDemoGraphicsList) {
        if ([[obj objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
            //[[obj objectForKey:@"OPTIONS"] replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%lu country selected",(unsigned long)[countryIDs count]]];
            [[[obj objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:[NSString stringWithFormat:@"%lu country selected",(unsigned long)[countryIDs count]] forKey:@"BUTTON_NAME"];
            stateIDs = [[NSMutableArray alloc] init];
            cityIDs = [[NSMutableArray alloc] init];
            [[[obj objectForKey:@"OPTIONS"] objectAtIndex:1] setObject:@"State" forKey:@"BUTTON_NAME"];
            [[[obj objectForKey:@"OPTIONS"] objectAtIndex:2] setObject:@"City" forKey:@"BUTTON_NAME"];
            [self.filterTableView reloadSections:[NSIndexSet indexSetWithIndex: [selectedDemoGraphicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
    
    //[self fetchStates:countriIDs];
}

- (void)getAllState:(NSArray *)stateList {
    
    NSLog(@"%@",stateList);
    selectedCities = [[NSMutableArray alloc] init];
    stateIDs = [[NSMutableArray alloc] init];
    selectedStates = [[NSMutableArray alloc] initWithArray:stateList];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"City" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *cityJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *userCityIDs;
    for (NSDictionary *attribute in selectedDemoGraphicsList) {
        if ([[attribute objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
            
            userCityIDs = [[[[attribute objectForKey:@"OPTIONS"] objectAtIndex:2] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","];
        }
    }
    
    for(NSInteger i=1; i < [stateList count]; i++) {
        for (NSDictionary *state in [[stateList objectAtIndex:i] objectForKey:@"STATES"]) {
            if ([[state objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                
                NSMutableDictionary *cities = [[NSMutableDictionary alloc] init];
                [cities setObject:[state objectForKey:@"name"] forKey:@"STATE_NAME"];
                NSMutableArray *citiesArray = [[NSMutableArray alloc] init];
                for (NSDictionary *city in cityJson) {
                    
                    if([[city objectForKey:@"state_id"] isEqualToString:[state objectForKey:@"id"]]) {
                        for (NSString *userCityID in userCityIDs) {
                            if ([[city objectForKey:@"id"] isEqualToString:userCityID]) {
                                [citiesArray addObject:city];
                            }
                        }
                        
                        //[citiesArray addObject:city];
                    }
                }
                [cities setObject:citiesArray forKey:@"CITIES"];
                [selectedCities addObject:cities];
                [stateIDs addObject:[state objectForKey:@"id"]];
            }
        }
    }
    
    NSMutableDictionary * selectAll = [[NSMutableDictionary alloc] init];
    [selectAll setObject:@"Select all" forKey:@"name"];
    [selectAll setObject:@"NO" forKey:@"isSelected"];
    NSMutableArray *stateArray = [[NSMutableArray alloc] init];
    [stateArray addObject:selectAll];
    NSMutableDictionary *firstDict = [[NSMutableDictionary alloc] init];
    [firstDict setObject:stateArray forKey:@"CITIES"];
    [firstDict setObject:@"" forKey:@"STATE_NAME"];
    
    [selectedCities insertObject:firstDict atIndex:0];
    
    for (NSDictionary *obj in selectedDemoGraphicsList) {
        if ([[obj objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
            //[[obj objectForKey:@"OPTIONS"] replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%lu country selected",(unsigned long)[countryIDs count]]];
            [[[obj objectForKey:@"OPTIONS"] objectAtIndex:1] setObject:[NSString stringWithFormat:@"%lu state selected",(unsigned long)[stateIDs count]] forKey:@"BUTTON_NAME"];
            [[[obj objectForKey:@"OPTIONS"] objectAtIndex:2] setObject:@"City" forKey:@"BUTTON_NAME"];
            cityIDs = [[NSMutableArray alloc] init];
            [self.filterTableView reloadSections:[NSIndexSet indexSetWithIndex: [selectedDemoGraphicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
    
    //[self fetchCities:stateIDs];
}

- (void)getAllCity:(NSArray *)cityList {
    NSLog(@"%@",cityList);
    selectedCities = [[NSMutableArray alloc] initWithArray:cityList];
    
    cityIDs = [[NSMutableArray alloc] init];
    for (int i = 1; i < [selectedCities count]; i++) {
        
        for (NSDictionary *city in [[selectedCities objectAtIndex:i] objectForKey:@"CITIES"]) {
            
            if ([[city objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [cityIDs addObject:[city objectForKey:@"id"]];
                NSLog(@"%@",[city objectForKey:@"name"]);
            }
        }
    }
    
    for (NSDictionary *obj in selectedDemoGraphicsList) {
        if ([[obj objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
            //[[obj objectForKey:@"OPTIONS"] replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%lu country selected",(unsigned long)[countryIDs count]]];
            [[[obj objectForKey:@"OPTIONS"] objectAtIndex:2] setObject:[NSString stringWithFormat:@"%lu city selected",(unsigned long)[cityIDs count]] forKey:@"BUTTON_NAME"];
            [self.filterTableView reloadSections:[NSIndexSet indexSetWithIndex: [selectedDemoGraphicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}


-(CGFloat)getMostLeastPreferredCount:(CGFloat)count
{
    count = (0.1 * count) / 10;
    return count;
}

- (void)loadGraph :(NSMutableArray *)surveryArr
{
    [super loadView];
    _values = [[NSMutableArray alloc]init];
    barValues = [[NSMutableArray alloc]init];
    upperValue = [[NSMutableArray alloc]init];
    lowerValue = [[NSMutableArray alloc]init];
    
    int total = 0;
    for (int i =0; i<surveyDetailArr.count; i++)
    {
        [_values addObject:[[surveryArr objectAtIndex:i]valueForKey:@"LEVEL_NAME"]];
        [barValues addObject:[[surveryArr objectAtIndex:i]valueForKey:@"FEATURE_VALUE"]];
        if (i == 0)
        {
            [lowerValue addObject:@"0"];
        }
        else
        {
            [lowerValue addObject:[NSString stringWithFormat:@"%d",total]];
        }
        int a = [[[surveryArr objectAtIndex:i] valueForKey:@"FEATURE_VALUE"] integerValue];
        a = (a *(28.10))/10;
        total = total + a;
        [upperValue addObject:[NSString stringWithFormat:@"%d",total]];
    }
    [_values addObject:@"LEVEL"];
    [barValues addObject:@"100"];
    [upperValue addObject:[upperValue objectAtIndex:upperValue.count-1]];
    [lowerValue addObject:@"0"];
       
    _barColors						= @[[UIColor colorWithRed:15.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1.0]];
    _currentBarColor				= 0;
    
    CGRect chartFrame				= CGRectMake(12.0,400.0,1000.0,380.0);
    _chart							= [[SimpleBarChart alloc] initWithFrame:chartFrame];
    //_chart.center					= CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    _chart.delegate					= self;
    _chart.dataSource				= self;
    _chart.barShadowOffset			= CGSizeMake(2.0, 1.0);
    _chart.animationDuration		= 1.0;
    _chart.barShadowColor			= [UIColor grayColor];
    _chart.barShadowAlpha			= 0.5;
    _chart.barShadowRadius			= 1.0;
    _chart.barWidth					= 1000/(_values.count+_values.count);
    _chart.xLabelType				= SimpleBarChartXLabelTypeVerticle;
    _chart.incrementValue			= 10;
    _chart.barTextType				= SimpleBarChartBarTextTypeTop;
    _chart.barTextColor				= [UIColor whiteColor];
    _chart.gridColor				= [UIColor whiteColor];
    
    [self.view addSubview:_chart];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_chart reloadData];
}

#pragma mark - UIButton Events

- (IBAction)filterBtnPressed:(id)sender {
    _totalRespondantLabel.text = [NSString stringWithFormat:@"Total Respondent : %ld",respondantCount];
    if (_sliderViewTrailingContraint.constant == -400) {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [blurView setAlpha:0.5];
            [self.view addSubview:blurView];
            [self.view bringSubviewToFront:_sliderView];
            _sliderViewTrailingContraint.constant =  0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _sliderViewTrailingContraint.constant = -400;
            blurView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [blurView removeFromSuperview];
        }];
    }
}

- (IBAction)selectAllAttributeSwitchValueChanged:(id)sender {
    
    if ([_selectAllAttributeSwitch isOn]) {
        isSelectAll = true;
        //[_selectAllAttributeSwitch setOn:false];
        for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
            
            [attributeDict setObject:@"YES" forKey:@"SWITCH_VALUE"];
            
            for (NSMutableDictionary *optionDict in [attributeDict objectForKey:@"OPTIONS"]) {
                [optionDict setObject:@"YES" forKey:@"CHECKBOX_VALUE"];
            }
        }
        [self.filterTableView reloadData];
    }
    else {
        isSelectAll = false;
        //[_selectAllAttributeSwitch setOn:true];
        for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
            
            [attributeDict setObject:@"NO" forKey:@"SWITCH_VALUE"];
            for (NSMutableDictionary *optionDict in [attributeDict objectForKey:@"OPTIONS"]) {
                [optionDict setObject:@"NO" forKey:@"CHECKBOX_VALUE"];
            }
        }
        [self.filterTableView reloadData];
    }
}

- (IBAction)submitBtnPressed:(id)sender {
    
    if (countryIDs == nil || [countryIDs count] == 0) {
        [self showAlertView:@"Alive 2.0" message:@"Please select at least one country"];
    }
    else {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _sliderViewTrailingContraint.constant = -400;
            blurView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [blurView removeFromSuperview];
        }];
        //        [UIView animateWithDuration:1 animations:^{
        //            _sliderMenuTrailingConstraint.constant = 400;
        //            blurView.alpha = 0;
        //            [self.view layoutIfNeeded];
        //        } completion:^(BOOL finished) {
        //            [blurView removeFromSuperview];
        //        }];
        
        NSMutableDictionary *finalSelectedValues = [[NSMutableDictionary alloc] init];
        NSMutableArray *attributeArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
            
            if([[attributeDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"TextBox"]) {
                continue;
            }
            
            if (![[attributeDict objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
                if ([[attributeDict objectForKey:@"SWITCH_VALUE"] isEqualToString:@"YES"]) {
                    
                    NSMutableDictionary *selectedAttributeDict = [[NSMutableDictionary alloc] init];
                    [selectedAttributeDict setObject:[attributeDict objectForKey:@"ATTRIBUTE_NAME"] forKey:@"ATTRIBUTE_NAME"];
                    [selectedAttributeDict setObject:[attributeDict objectForKey:@"INPUT_TYPE"] forKey:@"INPUT_TYPE"];
                    [selectedAttributeDict setObject:[attributeDict objectForKey:@"PRE_ID"] forKey:@"PRE_ID"];
                    
                    NSMutableArray *selectedOptions = [[NSMutableArray alloc] init];
                    for (NSDictionary *option in [attributeDict objectForKey:@"OPTIONS"]) {
                        if ([[option objectForKey:@"CHECKBOX_VALUE"] isEqualToString:@"YES"]) {
                            [selectedOptions addObject:option];
                        }
                    }
                    [selectedAttributeDict setObject:selectedOptions forKey:@"OPTIONS"];
                    [attributeArray addObject:selectedAttributeDict];
                }
            }
        }
        
        [finalSelectedValues setObject:attributeArray forKey:@"DATA"];
        [finalSelectedValues setObject:surveyId forKey:@"SURVEY_ID"];
        
        [finalSelectedValues setObject:[[countryIDs valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"COUNTRY_ID"];
        
        if (stateIDs == nil) {
            [finalSelectedValues setObject:@"" forKey:@"STATE_ID"];
        }
        else {
            [finalSelectedValues setObject:[[stateIDs valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"STATE_ID"];
        }
        
        if (cityIDs == nil) {
            [finalSelectedValues setObject:@"" forKey:@"CITY_ID"];
        }
        else {
            [finalSelectedValues setObject:[[cityIDs valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"CITY_ID"];
        }
        
        NSLog(@"dict %@",finalSelectedValues);
        [self showLoader:YES];
        [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/maxDiffGraphDetail.php" andParam:finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
            
            [self showLoader:NO];
            if (isSuccess) {
                NSLog(@"%@",response);
                
                if ([[response objectForKey:@"MSG"] isEqualToString:@"FAIL"]) {
                    [self showAlertView:@"Alive 2.0" message:@"No respondent"];
                    countArray = [[NSMutableArray alloc] init];
                    [self.attributeCollectionView reloadData];
                }
                else {
                    if (![[response objectForKey:@"COUNT"] isKindOfClass:[NSNull class]]) {
                        countArray = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"COUNT"]];
                        [self.attributeCollectionView reloadData];
                    }
                    [self graphDataWebserviceResponse:response];
                }
            }
        }];
    }
}

#pragma mark SimpleBarChartDataSource

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart
{
    NSLog(@"values = %lu",(unsigned long)_values.count);
    return _values.count;
}

- (NSString *)barChart:(SimpleBarChart *)barChart upperLimit:(NSUInteger)index
{
    return [upperValue objectAtIndex:index];
}

- (NSString *)barChart:(SimpleBarChart *)barChart lowerLimit:(NSUInteger)index
{
    return [lowerValue objectAtIndex:index ];
}

- (NSString *)barChart:(SimpleBarChart *)barChart setBarValues:(NSUInteger)index;
{
    return [barValues objectAtIndex:index]  ;
}

- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
    return [[_values objectAtIndex:index] floatValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
    return [_values objectAtIndex:index] ;
}

- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index
{
    return [_values objectAtIndex:index] ;
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    return [_barColors objectAtIndex:_currentBarColor];
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

-(void)callGraphDataWebservice
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
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoArray = [infoDictionary valueForKey:@"data"];
                               [self graphDataWebserviceResponseResult:infoArray];
                           }
                       }] resume];
                   });
}

-(void)graphDataWebserviceResponseResult:(NSMutableArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count == 0)
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"Nobody attended the survey yet"];
                       }
                       else
                       {
                           maxDiffGraph *obj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"maxDiffGraph"];
                           obj.surveyDetailArr = result;
                           obj.surveyId = surveyId;
                           [self.navigationController pushViewController:obj animated:YES];
                           
//                           maxDiffGraph *maxDiffGraphObj = [[maxDiffGraph alloc]initWithNibName:@"maxDiffGraph" bundle:nil];
//                           maxDiffGraphObj.surveyDetailArr = result;
//                           maxDiffGraphObj.surveyId = surveyId;
//                           [self.navigationController pushViewController:maxDiffGraphObj animated:YES];
                       }
                   });
}

- (IBAction)viewGraphBtnClicked:(id)sender
{
//    [self showLoader:YES];
//    [self callGraphDataWebservice];
//    maxDiffOutputObj = [[maxDiffOutput alloc]initWithNibName:@"maxDiffOutput" bundle:nil];
//    [self.navigationController pushViewController:maxDiffOutputObj animated:YES];
    maxDiffGraph *obj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"maxDiffGraph"];
    obj.surveyId = surveyId;
    [self.navigationController pushViewController:obj animated:YES];
}

-(NSMutableDictionary *)getDetailsForExcelSheet
{
    NSMutableArray *dataArray2 = [[NSMutableArray alloc]init];
    for (int i =0; i<infoArray.count; i++)
    {
        NSMutableDictionary *dataDict2 = [[NSMutableDictionary alloc]init];
        [dataDict2 setObject:[[infoArray objectAtIndex:i] valueForKey:@"FEATURE"] forKey:@"FEATURE_NAME"];
        [dataDict2 setObject:[[infoArray objectAtIndex:i] valueForKey:@"FEATURE_VALUE"] forKey:@"FEATURE_VALUE"];
        [dataDict2 setObject:[[infoArray objectAtIndex:i] valueForKey:@"BEST_COUNT"] forKey:@"MOST_PREFFERED"];
        [dataDict2 setObject:[[infoArray objectAtIndex:i] valueForKey:@"WORST_COUNT"] forKey:@"LEAST_PEFERRED"];
        [dataDict2 setObject:[[infoArray objectAtIndex:i] valueForKey:@"LEVEL_NAME"] forKey:@"LEVEL"];
        [dataDict2 setObject:[[infoArray objectAtIndex:i] valueForKey:@"SCORE"] forKey:@"SCORE"];
        [dataArray2 addObject:dataDict2];
    }
    NSMutableDictionary *dataDict3 = [[NSMutableDictionary alloc]init];
    [dataDict3 setObject:dataArray2 forKey:@"ARR"];
    [dataDict3 setObject:surveyName forKey:@"SURVEY_NAME"];

    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
    [finalDict setObject:dataDict3 forKey:@"DATA"];
    
    return finalDict;
}

- (IBAction)exportBtnClicked:(id)sender
{
    [self showLoader:YES];
    [self callWebServiceToExportExcelSheet];
}

-(void)callWebServiceToExportExcelSheet
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSError * err;
                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:[self getDetailsForExcelSheet] options:0 error:&err];
                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                       
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"MAX_DIFF_EXCEL/MAX_DIFF_EXCEL.php"]]];
                       
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
                           if (data == NULL)
                           {
                               
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  [self showLoader:NO];
                                              });
                           }
                           else
                           {
                               NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            
                               
                               //NSString *resSrt = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                               [self exportWebserviceResponce:[jsonData objectForKey:@"DATA"]];
                           }
                       }] resume];
                       
                   });
}


-(void)exportWebserviceResponce:(NSDictionary  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       //[self sendMail:result];
                       NSURL  *url = [NSURL URLWithString:[[result objectForKey:@"LINK"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
                       NSData *urlData = [NSData dataWithContentsOfURL:url];
                       NSString *filePath;
                       if (urlData)
                       {
                           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                           NSString *documentsDirectory = [paths objectAtIndex:0];
                           
                           filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[[[result objectForKey:@"LINK"] componentsSeparatedByString:@"/"] lastObject]];
                           [urlData writeToFile:filePath atomically:YES];
                       }
                       
                       NSLog(@"%@",result);
                       NSString *emailTitle = @"Link for filtered data";
                       NSString *messageBody = @"Find attachment";
                       NSArray *toRecipents = [NSArray arrayWithObject:@""];
                       NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:filePath];
                       NSData *data=[[NSData alloc]initWithContentsOfURL:outputURL];
                       
                       MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                       mc.mailComposeDelegate = self;
                       [mc addAttachmentData:data mimeType:@"text/csv" fileName:[[[result objectForKey:@"LINK"] componentsSeparatedByString:@"/"] lastObject]];
                       
                       [mc setSubject:emailTitle];
                       [mc setMessageBody:messageBody isHTML:NO];
                       [mc setToRecipients:toRecipents];
                       if (![mc isEqual:[NSNull null]]) {
                           [self presentViewController:mc animated:YES completion:NULL];
                       }

                   });
}

-(void)sendMail:(NSString *)link
{
    // Email Subject
    NSString *emailTitle = @"Alive 2.0 Excel Sheet";
    // Email Content
    NSString *messageBody = link;
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@""];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}




@end
