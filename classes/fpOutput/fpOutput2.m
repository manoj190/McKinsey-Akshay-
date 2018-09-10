//
//  fpOutput2.m
//  mckinsey
//
//  Created by Mac on 11/05/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "fpOutput2.h"
#import "dashboard.h"
#import "constant.h"
#import "Reachability.h"
#import "loadingPage.h"
#import "notifications.h"
#import "APIManager.h"
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

@interface fpOutput2 () <LocationProtocol,sliderProtocolDelegate,UIPopoverPresentationControllerDelegate>
{
    loadingPage *loadingPageObj;
    NSInteger arrCount;
    NSMutableArray * featureArr;
    NSMutableArray * finalSurveyArr;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    
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
    
    NSInteger mostPreMax;
    NSInteger leastPreMax;
    BOOL isSelectAll;
    
    IBOutlet UIButton *viewGraphBtn;
    IBOutlet UIImageView *badgeCountImg;
    IBOutlet UILabel *badgeCountLbl;
    __weak IBOutlet UIButton *exportBtn;
    
    
    
    UIView *blurView;
    
}
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderMenuTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *waterFallgraphBGView;
@property (weak, nonatomic) IBOutlet UILabel *totalRespondantLabel;
@property (weak, nonatomic) IBOutlet UITableView *demographicsTableView;
@property (weak, nonatomic) IBOutlet UISwitch *selectAllAttributeSwitch;
@property (weak, nonatomic) IBOutlet UICollectionView *attributeCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *pnGraphTableView;
@property (weak, nonatomic) IBOutlet UILabel *levelNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomGraphBottomConstrints;
@property (weak, nonatomic) IBOutlet UIView *positiveNegGraph;
@property (weak, nonatomic) IBOutlet UILabel *filteredCountLabel;


- (IBAction)featurePrioritizationPositiveNegGraphBtnPressed:(id)sender;

- (IBAction)viewCumulativeGraphBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)filterBtnPressed:(id)sender;
- (IBAction)exportBtnPressed:(id)sender;

@end

@implementation fpOutput2
@synthesize surveyDetailArr,surveyId,fpUsingMdOutputObj;

- (void)viewDidLoad
{
    [super viewDidLoad];
    isSelectAll = true;
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    if ([globalSurveyType isEqualToString:@"MaxDiff Survey"])
    {
        viewGraphBtn.hidden = YES;
        _positiveNegGraph.hidden = YES;
        exportBtn.hidden = YES;
        
        //_bottomGraphBottomConstrints.constant = 0;
    }
    else
    {
        viewGraphBtn.hidden = NO;
        _positiveNegGraph.hidden = NO;
        exportBtn.hidden = NO;
        
        //_bottomGraphBottomConstrints.constant = 500;
    }
    
    blurView = [[UIView alloc] initWithFrame:self.view.frame];
    blurView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addGestures];
    
    [self showLoader:YES];
    [self fetchAttributes];
    
    [_levelNameLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    
    //    arrCount= surveyDetailArr.count;
    //    finalSurveyArr=[[NSMutableArray alloc]init];
    //[self sortMainArr];
    //[self loadGraph:surveyDetailArr];
}


-(void)sortMainArr
{
    NSString * featureName =[[surveyDetailArr objectAtIndex:0]valueForKey:@"FEATURE"];
    NSMutableArray * unsortedArr=[[NSMutableArray alloc]init];
    for (int i =0; i<surveyDetailArr.count; i++)
    {
        if ([[[surveyDetailArr objectAtIndex:i]valueForKey:@"FEATURE"] isEqualToString: featureName])
        {
            [finalSurveyArr addObject: [surveyDetailArr objectAtIndex:i]];
        }
        else
        {
            [unsortedArr addObject:[surveyDetailArr objectAtIndex:i]];
        }
        
    }
    surveyDetailArr=[[NSMutableArray alloc]initWithArray:unsortedArr];
    if (finalSurveyArr.count!= arrCount)
    {
        [self sortMainArr];
    }
    else
    {
        NSLog(@"Arr: %@",finalSurveyArr);
        [self loadGraph:finalSurveyArr];
        
    }
}

- (void)loadGraph :(NSMutableArray *)surveryArr
{
    [super loadView];
    _values = [[NSMutableArray alloc]init];
    barValues = [[NSMutableArray alloc]init];
    upperValue = [[NSMutableArray alloc]init];
    lowerValue = [[NSMutableArray alloc]init];
    
    // NSMutableArray *maxDiff = [[NSMutableArray alloc]initWithObjects:@"20",@"10",@"30",@"10",@"10",@"10",@"10", nil];
    float total = 0;
    for (int i =surveryArr.count-1; i>=0; i--)
    {
        [_values addObject:[[surveryArr objectAtIndex:i]valueForKey:@"LEVEL_NAME"]];
        [barValues addObject:[[[surveryArr objectAtIndex:i]valueForKey:@"FEATURE_VALUE"]stringByAppendingString:@"%"]];
        if (i == surveryArr.count-1)
        {
            [lowerValue addObject:@"0"];
        }
        else
        {
            [lowerValue addObject:[NSString stringWithFormat:@"%.2f",total]];
        }
        float a = [[[surveryArr objectAtIndex:i] valueForKey:@"FEATURE_VALUE"] floatValue];
        a = (a *(28.10))/10;
        total = total + a;
        [upperValue addObject:[NSString stringWithFormat:@"%.2f",total]];
    }
    [_values addObject:@"Total"];
    [barValues addObject:[@"100" stringByAppendingString:@"%"]];
    [upperValue addObject:[upperValue objectAtIndex:upperValue.count-1]];
    [lowerValue addObject:@"0"];
    
    _barColors                        = @[[UIColor colorWithRed:15.0/255.0 green:239.0/255.0 blue:255.0/255.0 alpha:1.0]];
    _currentBarColor                = 0;
    
    CGRect chartFrame                = CGRectMake(8.0,8.0,self.waterFallgraphBGView.frame.size.width-16,420.0);
    _chart                            = [[SimpleBarChart alloc] initWithFrame:chartFrame];
    //_chart.center                    = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    _chart.delegate                    = self;
    _chart.dataSource                = self;
    _chart.barShadowOffset            = CGSizeMake(2.0, 1.0);
    _chart.animationDuration        = 1.0;
    _chart.barShadowColor            = [UIColor grayColor];
    _chart.barShadowAlpha            = 0.5;
    _chart.barShadowRadius            = 1.0;
    _chart.barWidth                    = 1000/(_values.count+_values.count);
    _chart.xLabelType                = SimpleBarChartXLabelTypeHorizontal;
    _chart.incrementValue            = 10;
    _chart.barTextType                = SimpleBarChartBarTextTypeTop;
    _chart.barTextColor                = [UIColor whiteColor];
    _chart.gridColor                = [UIColor whiteColor];
    
    [self.waterFallgraphBGView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [self.waterFallgraphBGView addSubview:_chart];
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


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_chart reloadData];
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

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)viewCumulativeGraphBtnClicked:(id)sender
{
    [self showLoader:YES];
    [self callPointGraphDataWebservice];
}

- (IBAction)notificationBtnClicked:(id)sender
{
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeNumber];
    notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
    [self.navigationController pushViewController:notificationViewObj animated:YES];
}

#pragma mark - UITableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _pnGraphTableView) {
        return 1;
    }
    return [demographicsArray count];
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _pnGraphTableView) {
        return [surveyDetailArr count];
    }
    else {
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
    return 0;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (tableView == _pnGraphTableView) {
        PositiveNegativeGraphTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[PositiveNegativeGraphTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        
        cell.levelNameLabel.text = [NSString stringWithFormat:@"%@",[[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"LEVEL_NAME"]];
        
        CGFloat radians = atan2f(cell.progressBarLeft.transform.b, cell.progressBarLeft.transform.a);
        CGFloat degrees = radians * (180 / M_PI);
        CGAffineTransform transform = CGAffineTransformMakeRotation((180 + degrees) * M_PI/180);
        cell.progressBarLeft.transform = transform;
        cell.backgroundColor = [UIColor clearColor];
        
        cell.progressBarRight.trackTintColor = [UIColor clearColor];
        cell.progressBarLeft.trackTintColor = [UIColor clearColor];
        cell.progressBarLeft.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
        cell.progressBarRight.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
        
        NSInteger percentage = ([[[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"BEST_COUNT"] floatValue]/mostPreMax)*100;
        
        //UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.seperatorLabel.frame.origin.x+(cell.progressBarRight.frame.origin.x+percentage),cell.progressBarRight.center.y, 50, cell.progressBarRight.frame.size.height)];
        cell.righProgressbarLabel.text = [[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"BEST_COUNT"];
        //[cell.progressBarRight addSubview:bestCountLabel];
        
        //UILabel *worstCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.progressBarRight.center.y-25, 50, 50)];
        //[worstCountLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.leftProgresseBar setTransform:CGAffineTransformMakeRotation( ( 180 * M_PI ) / 180)];
        
        if ([[[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"WORST_COUNT"] isEqualToString:@"0"]) {
            cell.leftProgresseBar.text = [NSString stringWithFormat:@"%@",[[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"WORST_COUNT"]];
        }
        else {
            cell.leftProgresseBar.text = [NSString stringWithFormat:@"-%@",[[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"WORST_COUNT"]];
        }
        //[cell.progressBarLeft addSubview:worstCountLabel];
        
        [cell.progressBarLeft setProgress:([[[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"WORST_COUNT"] floatValue]/mostPreMax) animated:YES];
        [cell.progressBarRight setProgress:([[[surveyDetailArr objectAtIndex:indexPath.row] objectForKey:@"BEST_COUNT"] floatValue]/leastPreMax) animated:YES];
        
        //cell.progressBarRoundedFat.indicatorTextLabel.text = [mostPrefArr objectAtIndex:indexPath.row];
        //cell.progressBarRoundedFat1.indicatorTextLabel.text = [NSString stringWithFormat:@"%@ %@",@"-",[leastPrefArr objectAtIndex:indexPath.row]];
        
        [cell.progressBarLeft setProgressTintColors:@[[UIColor colorWithRed:248/255.0 green:48.0/255.0 blue:40.0/255.0 alpha:1.0]]];
        [cell.progressBarRight setProgressTintColors:@[[UIColor colorWithRed:0.0/255.0 green:208/255.0 blue:88/255.0 alpha:1.0]]];
        return cell;
    }
    else {
        
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
    
    CheckBoxSubHeadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"checkBoxHeadCell"];
    if (cell == nil) {
        cell = [[[CheckBoxSubHeadTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"checkBoxHeadCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _pnGraphTableView) {
        return _pnGraphTableView.frame.size.height/[surveyDetailArr count];
    }
    else {
        if([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Slider"]) {
            return 70;
        }
    }
    return 44;
}

#pragma mark - Selector methods

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
    
    
    [self.demographicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
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
    [self.demographicsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [self.demographicsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    SliderTableViewCell *cell = [self.demographicsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
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
            [self.demographicsTableView reloadSections:[NSIndexSet indexSetWithIndex: [selectedDemoGraphicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
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
            [self.demographicsTableView reloadSections:[NSIndexSet indexSetWithIndex: [selectedDemoGraphicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
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
            [self.demographicsTableView reloadSections:[NSIndexSet indexSetWithIndex: [selectedDemoGraphicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}


#pragma mark - UIButton Events

- (IBAction)featurePrioritizationPositiveNegGraphBtnPressed:(id)sender {
    //[UIView animateWithDuration:1 animations:^{
    
    if (_bottomGraphBottomConstrints.constant == 0) {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _bottomGraphBottomConstrints.constant = 500;
            blurView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [blurView removeFromSuperview];
        }];
    }
    else {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _bottomGraphBottomConstrints.constant = 0;
            [blurView setAlpha:0.5];
            [self.view addSubview:blurView];
            [self.view bringSubviewToFront:_positiveNegGraph];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
    //_bottomGraphBottomConstrints.constant = (_bottomGraphBottomConstrints.constant == 500) ? 0:500;
    // }];
}


- (IBAction)filterBtnPressed:(id)sender {
    _totalRespondantLabel.text = [NSString stringWithFormat:@"Total Respondent : %ld",respondantCount];
    if (_sliderMenuTrailingConstraint.constant == 400) {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [blurView setAlpha:0.5];
            [self.view addSubview:blurView];
            [self.view bringSubviewToFront:_sliderView];
            _sliderMenuTrailingConstraint.constant =  0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _sliderMenuTrailingConstraint.constant = 400;
            blurView.alpha = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [blurView removeFromSuperview];
        }];
    }
}

- (IBAction)exportBtnPressed:(id)sender {
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/EXPORT_TO_EXCEL/export.php" andParam:finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if (isSuccess) {
            
            NSString *stringURL = [response objectForKey:@"LINK"];
            NSURL  *url = [NSURL URLWithString:stringURL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            NSString *filePath;
            if (urlData)
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[[[response objectForKey:@"LINK"] componentsSeparatedByString:@"/"] lastObject]];
                [urlData writeToFile:filePath atomically:YES];
            }
            
            NSLog(@"%@",response);
            NSString *emailTitle = @"Link for filtered data";
            NSString *messageBody = @"Find attachment";
            NSArray *toRecipents = [NSArray arrayWithObject:@""];
            NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:filePath];
            NSData *data=[[NSData alloc]initWithContentsOfURL:outputURL];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc addAttachmentData:data mimeType:@"application/excel" fileName:[[[response objectForKey:@"LINK"] componentsSeparatedByString:@"/"] lastObject]];
            
            [mc addAttachmentData:UIImagePNGRepresentation([self pb_takeSnapshot:self.waterFallgraphBGView]) mimeType:@"image/png" fileName:[NSString stringWithFormat:@"water_fall_graph.png"]];
            
            if (![globalSurveyType isEqualToString:@"MaxDiff Survey"]) {
                [mc addAttachmentData:UIImagePNGRepresentation([self pb_takeSnapshot:self.positiveNegGraph]) mimeType:@"image/png" fileName:[NSString stringWithFormat:@"graph.png"]];
            }
            
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            if (![mc isEqual:[NSNull null]]) {
                [self presentViewController:mc animated:YES completion:NULL];
            }
        }
    }];
}

- (UIImage *)pb_takeSnapshot:(UIView *)screenshotView {
    UIView *subView = screenshotView;
    UIGraphicsBeginImageContextWithOptions(subView.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [subView.layer renderInContext:context];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

#pragma mark - Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    
    switch (result) {
        case MFMailComposeResultSent:
            [self showAlertView:@"ALIVE 2.0" message:@"Mail send successfully"];
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            [self showAlertView:@"ALIVE 2.0" message:@"Mail saved successfully"];
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            [self showAlertView:@"ALIVE 2.0" message:@"Mail failed:  An error occurred when trying to compose this email"];
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            [self showAlertView:@"ALIVE 2.0" message:@"An error occurred when trying to compose this email"];
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
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
        [self.demographicsTableView reloadData];
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
        [self.demographicsTableView reloadData];
    }
}


- (IBAction)submitBtnPressed:(id)sender {
    
    if (countryIDs == nil || [countryIDs count] == 0) {
        [self showAlertView:@"Alive 2.0" message:@"Please select at least one country"];
    }
    else {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _sliderMenuTrailingConstraint.constant = 400;
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
                    }
                    [self graphDataWebserviceResponseResult:response];
                }
            }
        }];
    }
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
        _sliderMenuTrailingConstraint.constant =  400;
        _bottomGraphBottomConstrints.constant = 500;
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
        _sliderMenuTrailingConstraint.constant =  0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
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

#pragma mark - WebService

-(void)fetchInitialGraphDetails {
    
    finalSelectedValues = [[NSMutableDictionary alloc] init];
    NSMutableArray *attributeArray = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
        
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
                }
                [self graphDataWebserviceResponseResult:response];
            }
        }
    }];
}


-(void)graphDataWebserviceResponseResult:(NSDictionary  *)response
{
    NSMutableArray *result = [response objectForKey:@"GRAPH_DATA"];
    
    if (result.count == 0)
    {
        [self showAlertView:@"ALIVE 2.0" message:@"Nobody attended the survey yet"];
    }
    else
    {
        NSLog(@"%@",_selectAllAttributeSwitch.isOn ? @"true":@"false");
        NSMutableArray *bestCount = [[NSMutableArray alloc] init];
        for (NSDictionary *levelDict in result) {
            
            [bestCount addObject:[NSNumber numberWithInt:[[levelDict objectForKey:@"BEST_COUNT"]intValue]]];
        }
        mostPreMax = [[bestCount valueForKeyPath:@"@max.intValue"] intValue];
        
        NSMutableArray *worstCount = [[NSMutableArray alloc] init];
        for (NSDictionary *levelDict in result) {
            [worstCount addObject:[NSNumber numberWithInt:[[levelDict objectForKey:@"WORST_COUNT"]intValue]]];
        }
        leastPreMax = [[worstCount valueForKeyPath:@"@max.intValue"] intValue];
        [_pnGraphTableView reloadData];
        
        surveyDetailArr = result;
        NSLog(@"%ld",respondantCount);
        _totalRespondantLabel.text = [NSString stringWithFormat:@"Total Respondent : %ld",respondantCount];
        arrCount = surveyDetailArr.count;
        finalSurveyArr=[[NSMutableArray alloc]init];
        [self loadGraph:surveyDetailArr];
        [_chart reloadData];
        
        [self setBadgeNumber];
        [_levelNameLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
        
        if (![[response objectForKey:@"TOTAL_COUNT"] isKindOfClass:[NSNull class]]) {
            _filteredCountLabel.text = [NSString stringWithFormat:@"Total filtered count : %@",[response objectForKey:@"TOTAL_COUNT"]];
        }
        else {
            _filteredCountLabel.text = @"";
        }
        
        if ([globalSurveyType isEqualToString:@"MaxDiff Survey"])
        {
            exportBtn.hidden = NO;
            viewGraphBtn.hidden = YES;
            _positiveNegGraph.hidden = YES;
            
            
            //_bottomGraphBottomConstrints.constant = 0;
        }
        else
        {
            exportBtn.hidden = YES;
            viewGraphBtn.hidden = NO;
            _positiveNegGraph.hidden = NO;
            
            //_bottomGraphBottomConstrints.constant = 500;
        }
        [_selectAllAttributeSwitch setOn:isSelectAll];
    }
}


- (void)fetchAttributes {
    
    
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
            [self.demographicsTableView reloadData];
            [self fetchInitialGraphDetails];
        }
        else {
            
        }
    }];
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
                               [self errorResponse:@"Error in login"];
                           }
                           else
                           {
                               infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               infoDictionary = [[infoDictionary valueForKey:@"data"]objectAtIndex:0];
                               [self PointGraphDataWebserviceResponseResult:infoDictionary];
                           }
                       }] resume];
                   });
}

-(void)PointGraphDataWebserviceResponseResult:(NSMutableDictionary  *)result
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
                           fpUsingMdOutputObj = [[fpUsingMdOutput alloc]initWithNibName:@"fpUsingMdOutput" bundle:nil];
                           fpUsingMdOutputObj.surveyId = surveyId;
                           fpUsingMdOutputObj.surveyDetailArr = [result valueForKey:@"GRAPH_DATA"];
                           fpUsingMdOutputObj.currencyType = [result valueForKey:@"CURRENCY_TYPE"];
                           [self.navigationController pushViewController:fpUsingMdOutputObj animated:YES];
                       }
                   });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"ALIVE 2.0" message:msg];
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
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
