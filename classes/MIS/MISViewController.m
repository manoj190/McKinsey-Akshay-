//
//  MISViewController.m
//  mckinsey
//
//  Created by Akshay Ambekar on 10/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "MISViewController.h"
#import "APIManager.h"
#import "LocationHeadTableViewCell.h"
#import "LocationSubHeadTableViewCell.h"
#import "CheckBoxHeadTableViewCell.h"
#import "CheckBoxSubHeadTableViewCell.h"
#import "ToggleSwitchTableViewCell.h"
#import "SliderTableViewCell.h"
#import "TextFieldTableViewCell.h"
#import "MultipleSelectViewController.h"
#import <Google-Maps-iOS-Utils/GMUMarkerClustering.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MISCollectionViewCell.h"
#import "XYPieChart.h"
#import "NIDropDown.h"
#import "SimpleBarChart.h"
#import "ChartLegendsCollectionViewCell.h"
#import "DrGraphs.h"
#import "SectionHeaderCollectionReusableView.h"
#import "loadingPage.h"
#import <MessageUI/MessageUI.h>
#import "AttributeIconCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NMRangeSlider.h"
#import "ExportViewController.h"

// Point of Interest Item which implements the GMUClusterItem protocol.
@interface POIItem : NSObject<GMUClusterItem>

@property(nonatomic, readonly) CLLocationCoordinate2D position;
@property(nonatomic, readonly) NSString *name;


- (instancetype)initWithPosition:(CLLocationCoordinate2D)position name:(NSString *)name;

@end

@implementation POIItem


- (instancetype)initWithPosition:(CLLocationCoordinate2D)position name:(NSString *)name {
    if ((self = [super init])) {
        _position = position;
        _name = [name copy];
    }
    return self;
}

@end

static const double kCameraLatitude = 21.094751;
static const double kCameraLongitude = 79.277344;

@interface MISViewController () <UITableViewDelegate, UITableViewDataSource, LocationProtocol, UIPopoverPresentationControllerDelegate,GMUClusterManagerDelegate,GMSMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource,XYPieChartDelegate, XYPieChartDataSource, NIDropDownDelegate,CircularChartDataSource, CircularChartDelegate,BarChartDataSource, BarChartDelegate, MFMailComposeViewControllerDelegate, UICollectionViewDelegateFlowLayout,sliderProtocolDelegate,exportTypeDelegate>
{
    NSMutableArray *demographicsArray;
    NSMutableArray *selectedDemoGraphicsList;
    NSMutableDictionary *finalSelectedValues;
    NSMutableArray *countArray;
    
    NSMutableArray *selectedCountries;
    NSMutableArray *selectedCities;
    NSMutableArray *selectedStates;
    
    NSMutableArray *countryIDs;
    NSMutableArray *stateIDs;
    NSMutableArray *cityIDs;
    
    GMUClusterManager *_clusterManager;
    
    NSMutableArray *slices;
    NSArray *sliceColors;
    
    NSMutableArray *pieChartArray;
    NSMutableArray *dropDownList;
    NIDropDown *attributeDropDown;
    
    NSInteger _currentBarColor;
    NSArray *_values;
    
    BarChart *barChartView;
    CircularChart *cirecularChart;
    
    loadingPage *loadingPageObj;
    
    NSInteger respondantCount;
    
    NSArray *maleImgArray;
    NSArray *femaleImgArray;
    NSArray *transgenderArray;
    NSArray *doNotImgArray;
    
    NSArray *ageGroupArray;
    NSArray *incomeGrpArray;
    NSString *selectedPreID;
    
    UIView *blurView;
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderMenuTrailingConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *misCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *chartLegendsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *attributeIconCollectionView;

@property (weak, nonatomic) IBOutlet UITableView *demographicsTableView;
@property (weak, nonatomic) IBOutlet UIImageView *chartViewBGVImg;
@property (strong, nonatomic) IBOutlet XYPieChart *pieChartView;
@property (weak, nonatomic) IBOutlet UIButton *dropDownBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cirCularChartBaseView;
@property (weak, nonatomic) IBOutlet UIView *barChartBaseView;
@property (weak, nonatomic) IBOutlet UIView *attributeIconsView;
@property (weak, nonatomic) IBOutlet UILabel *totalRespondantLabel;
@property (weak, nonatomic) IBOutlet UILabel *filteredCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *cirIconBtn;
@property (weak, nonatomic) IBOutlet UIButton *barIconBtn;
@property (weak, nonatomic) IBOutlet UIButton *pieIconBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attributeIconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barChartLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *chartViewNavImg;
@property (weak, nonatomic) IBOutlet UILabel *misTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *chartsView;
@property (weak, nonatomic) IBOutlet UISwitch *selectAllAttributeSwitch;
@property (weak, nonatomic) IBOutlet UIView *rightSliderView;
@property (weak, nonatomic) IBOutlet UIButton *exportBtn;
@property (weak, nonatomic) IBOutlet UIButton *exportChartBtn;


- (IBAction)graphViewUpBtnPressed:(id)sender;
- (IBAction)selectAttributeDropDown:(id)sender;
- (IBAction)sliderMenuBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;
- (IBAction)homeBtnPressed:(id)sender;
- (IBAction)exportBtnPressed:(id)sender;
- (IBAction)exportChartsBtnPressed:(id)sender;

@end

@implementation MISViewController
{
//    GMSMapView *_mapView;
    
}

//- (void)loadView {
//    GMSCameraPosition *camera =
//    [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:10];
//    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, 500, 500) camera:camera];
//    self.view = _mapView;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    blurView = [[UIView alloc] initWithFrame:self.view.frame];
    blurView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:0];
    _mapView.camera = camera;
    
    _chartLegendsCollectionView.delegate = self;
    _chartLegendsCollectionView.dataSource = self;
    _misCollectionView.delegate = self;
    _misCollectionView.dataSource = self;
    
    _dropDownBtn.layer.cornerRadius = 5;
    _dropDownBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _dropDownBtn.layer.borderWidth = 1;
    
    _misTitleLabel.text = [NSString stringWithFormat:@"%@ - %@",_surveyName,_surveyType];
    
    maleImgArray = @[@"ic_0%",@"ic_10%",@"ic_20%",@"ic_30%",@"ic_40%",@"ic_50%",@"ic_60%",@"ic_70%",@"ic_80%",@"ic_90%",@"ic_100%"];
    femaleImgArray = @[@"ic_women_0%",@"ic_women_10%",@"ic_women_20%",@"ic_women_30%",@"ic_women_40%",@"ic_women_50%",@"ic_women_60%",@"ic_women_70%",@"ic_women_80%",@"ic_women_90%",@"ic_women_100%"];
    transgenderArray = @[@"ic_trancegender_0%",@"ic_trancegender_10%",@"ic_trancegender_20%",@"ic_trancegender_30%",@"ic_trancegender_40%",@"ic_trancegender_50%",@"ic_trancegender_60%",@"ic_trancegender_70%",@"ic_trancegender_80%",@"ic_trancegender_90%",@"ic_trancegender_100%"];
    doNotImgArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11"];
    ageGroupArray = @[@"ic_age_0to10",@"ic_age_10to20",@"ic_age_men_20to30",@"ic_age_men_30to40",@"ic_age_men_40to50",@"ic_age_men_50to60",@"ic_age_men_60to70",@"ic_age_men_70to80",@"ic_age_men_80to90",@"ic_age_men_90to100"];
    incomeGrpArray = @[@"ic_income_0",@"ic_income_1to3",@"ic_income_3to6",@"ic_income_6to10",@"ic_income_10to15",@"ic_income_15to20",@"ic_income_20to25",@"ic_income_greater than_25"];
    
    //[self showClusterOnMap];
    [_barIconBtn setHidden:YES];
    [self fetchAttributes];
    [self drawCharts];
    [self addGestures];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieChartView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.mapView = nil;
}

#pragma mark - Gestures

- (void)addGestures {
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRightGesture:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.rightSliderView addGestureRecognizer:swipeRight];
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
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [blurView removeFromSuperview];
    }];
}

- (void)swipeLeftGesture:(UISwipeGestureRecognizer *) sender {
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:0.5];
        [self.view addSubview:blurView];
        [self.view bringSubviewToFront:_rightSliderView];
        _sliderMenuTrailingConstraint.constant =  0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
//    [UIView animateWithDuration:1 animations:^{
//        [blurView setAlpha:0.5];
//        [self.view addSubview:blurView];
//        [self.view bringSubviewToFront:_rightSliderView];
//        _sliderMenuTrailingConstraint.constant =  0;
//        [self.view layoutIfNeeded];
//    }];
}



#pragma mark - Add charts

- (void)drawCharts {
    
    [self drawCircular];
    [self drawBarChart];
    [self drawPieChart];
    //[self getAttributeData];
    
    //[self.percentageLabel.layer setCornerRadius:90];
}

- (void)drawPieChart {
    
    [_attributeIconsView setHidden:true];
    [_pieChartView setHidden:false];
    [_cirCularChartBaseView setHidden:true];
    [_barChartBaseView setHidden:true];
    
    [_pieChartView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [_pieChartView setDelegate:self];
    [_pieChartView setDataSource:self];
    [_pieChartView setPieCenter:CGPointMake(_pieChartView.center.x+50, _pieChartView.center.y-60)];
    [_pieChartView setShowPercentage:NO];
    [_pieChartView setLabelColor:[UIColor blackColor]];
}

- (void)drawBarChart {
    
    [barChartView removeFromSuperview];
    [_barChartBaseView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    barChartView = [[BarChart alloc] initWithFrame:CGRectMake(30, 0, self.barChartBaseView.frame.size.width-60, self.barChartBaseView.frame.size.height)];

    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [tempArray addObject:[pieChartArray objectAtIndex:i]];
        }
    }
    barChartView.colorArray = tempArray;
    barChartView.textColor = [UIColor whiteColor];
    //barChartView.textFont = [UIFont fontWithName:@"Century Gothic-Bold" size:17];
    [barChartView setDataSource:self];
    [barChartView setDelegate:self];
    [barChartView setShowLegend:NO];
    [barChartView setLegendViewType:LegendTypeHorizontal];
    [barChartView setShowCustomMarkerView:TRUE];
    [barChartView drawBarGraph];
    //[barChartView setTextFont:[UIFont fontWithName:@"Century Gothic-Bold" size:17]];
    [barChartView setTextColor:[UIColor whiteColor]];
    [self.barChartBaseView addSubview:barChartView];
}

- (void)drawCircular {

    [cirecularChart removeFromSuperview];
    [_cirCularChartBaseView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    cirecularChart = [[CircularChart alloc] initWithFrame:CGRectMake(0, 0, self.cirCularChartBaseView.frame.size.width, self.cirCularChartBaseView.frame.size.height)];
    [cirecularChart setDataSource:self];
    [cirecularChart setDelegate:self];
    [cirecularChart setShowLegend:NO];
    //[chart setLegendViewType:LegendTypeHorizontal];
    [cirecularChart setShowCustomMarkerView:TRUE];
    [cirecularChart drawCircularChart];
    [self.cirCularChartBaseView addSubview:cirecularChart];
}


#pragma mark - BarChartDataSource
- (NSMutableArray *)xDataForBarChart{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [array addObject:[NSString stringWithFormat:@"%@",[[pieChartArray objectAtIndex:i] objectForKey:@"ATTRIBUTE_NAME"]]];
        }
    }
    return array;
}

- (NSInteger)numberOfBarsToBePlotted{
    return 1;
}

- (UIColor *)colorForTheBarWithBarNumber:(NSInteger)barNumber{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [tempArray addObject:[pieChartArray objectAtIndex:i]];
        }
    }
    if ([tempArray count]) {
        return [[tempArray objectAtIndex:barNumber] objectForKey:@"COLOR"];
    }
    return [UIColor clearColor];
}

- (CGFloat)widthForTheBarWithBarNumber:(NSInteger)barNumber{
    return 40;
}

- (NSString *)nameForTheBarWithBarNumber:(NSInteger)barNumber{
    NSLog(@"bar number : %ld",(long)barNumber);
    return [NSString stringWithFormat:@"%@ %@",[[pieChartArray objectAtIndex:barNumber] objectForKey:@"ATTRIBUTE_NAME"],[[pieChartArray objectAtIndex:barNumber] objectForKey:@"TOTAL_COUNT"]];
}


- (NSMutableArray *)yDataForBarWithBarNumber:(NSInteger)barNumber{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [array addObject:[[pieChartArray objectAtIndex:i] objectForKey:@"TOTAL_COUNT"]];
        }
    }
    return array;
}

- (UIView *)customViewForBarChartTouchWithValue:(NSNumber *)value{
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view.layer setCornerRadius:4.0F];
    [view.layer setBorderWidth:1.0F];
    [view.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowRadius:2.0F];
    [view.layer setShadowOpacity:0.3F];
    
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:12]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    NSInteger perCentage = ([value floatValue]/respondantCount)*100;
    [label setText:[NSString stringWithFormat:@"%ld %%",(long)perCentage]];
    [label setFrame:CGRectMake(0, 0, 100, 30)];
    [view addSubview:label];
    
    [view setFrame:label.frame];
    return view;
}


#pragma mark - BarChartDelegate
- (void)didTapOnBarChartWithValue:(NSString *)value{
    NSLog(@"Bar Chart: %@",value);
}


#pragma mark - CircularChartDataSource
- (CGFloat)strokeWidthForCircularChart{
    return 100;
}

- (NSInteger)numberOfValuesForCircularChart{
    //return 2;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [array addObject:[pieChartArray objectAtIndex:i]];
        }
    }
    return array.count;
//    return pieChartArray.count;
}

- (UIColor *)colorForValueInCircularChartWithIndex:(NSInteger)lineNumber{
//    NSInteger aRedValue = arc4random()%255;
//    NSInteger aGreenValue = arc4random()%255;
//    NSInteger aBlueValue = arc4random()%255;
//    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
//    return randColor;
//    if ([[[pieChartArray objectAtIndex:lineNumber] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//        return [[pieChartArray objectAtIndex:lineNumber] objectForKey:@"COLOR"];
//    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [array addObject:[pieChartArray objectAtIndex:i]];
        }
    }
    return [[array objectAtIndex:lineNumber] objectForKey:@"COLOR"];
}


- (NSString *)titleForValueInCircularChartWithIndex:(NSInteger)index{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [tempArray addObject:[[pieChartArray objectAtIndex:i] objectForKey:@"TOTAL_COUNT"]];
        }
    }

//    if ([[[tempArray objectAtIndex:index] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//
        return [NSString stringWithFormat:@"%@",[tempArray objectAtIndex:index]];
//    }
//    else {
//        return @"";
//    }
    //return [NSString stringWithFormat:@"data %ld",(long)index];
}

- (NSNumber *)valueInCircularChartWithIndex:(NSInteger)index{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [pieChartArray count]; i++) {
        if ([[[pieChartArray objectAtIndex:i] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [tempArray addObject:[[pieChartArray objectAtIndex:i] objectForKey:@"TOTAL_COUNT"]];
        }
    }
    return (NSNumber *)[tempArray objectAtIndex:index];
//    if ([[[tempArray objectAtIndex:index] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//        f.numberStyle = NSNumberFormatterNoStyle;
//        NSNumber *myNumber = [f numberFromString:[[tempArray objectAtIndex:index] objectForKey:@"TOTAL_COUNT"]];
//        return myNumber;
//    }
//    else {
//        return 0;
//    }
    //return [NSNumber numberWithLong:random() % 100];
}

- (UIView *)customViewForCircularChartTouchWithValue:(NSNumber *)value{
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view.layer setCornerRadius:4.0F];
    [view.layer setBorderWidth:1.0F];
    [view.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [view.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [view.layer setShadowRadius:2.0F];
    [view.layer setShadowOpacity:0.3F];
    
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:12]];
    [label setTextAlignment:NSTextAlignmentCenter];
    NSInteger perCentage = ([value floatValue]/respondantCount)*100;
    [label setText:[NSString stringWithFormat:@"%ld %%", (long)perCentage]];
    [label setFrame:CGRectMake(0, 0, 100, 30)];
    [label setAdjustsFontSizeToFitWidth:TRUE];
    [view addSubview:label];
    
    [view setFrame:label.frame];
    return view;
}

#pragma mark - CircularChartDelegate
- (void)didTapOnCircularChartWithValue:(NSString *)value{
    NSLog(@"Circular Chart: %@",value);
    
}

- (void)showClusterOnMap:(NSArray *)clusterInfoList {
    
    // Set up the cluster manager with default icon generator and renderer.
    id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    id<GMUClusterIconGenerator> iconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
    id<GMUClusterRenderer> renderer =
    [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView
                                  clusterIconGenerator:iconGenerator];
    _clusterManager = [[GMUClusterManager alloc] initWithMap:_mapView algorithm:algorithm renderer:renderer];
    
    // Generate and add random items to the cluster manager.
    [self generateClusterItemsLat:clusterInfoList];
    
    
    // Call cluster() after items have been added to perform the clustering and rendering on map.
    [_clusterManager cluster];
    
    // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
    [_clusterManager setDelegate:self mapDelegate:self];
}


#pragma mark - PieChartViewDelegate
-(CGFloat)centerCircleRadius
{
    return 10;
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    //    NSInteger count = 0;
    //    for (NSDictionary *itemDict in pieChartArray) {
    //        if ([[itemDict objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
    //            count++;
    //        }
    //    }
    //    return count;
    return pieChartArray.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    if ([[[pieChartArray objectAtIndex:index] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
        return [[[pieChartArray objectAtIndex:index] objectForKey:@"TOTAL_COUNT"] floatValue];
    }
    else {
        return 0;
    }
    //    return [[[pieChartArray objectAtIndex:index] objectForKey:@"TOTAL_COUNT"] integerValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    if ([[[pieChartArray objectAtIndex:index] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
        return [[pieChartArray objectAtIndex:index] objectForKey:@"COLOR"];
    }
    return [UIColor clearColor];
    //   return [[pieChartArray objectAtIndex:index] objectForKey:@"COLOR"];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %lu",index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %lu",index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %lu",index);
    pieChart.showPercentage = pieChart.showPercentage ? false:true;
    [pieChart reloadData];
    NSLog(@"%@",[NSString stringWithFormat:@"$%@",[pieChartArray objectAtIndex:index]]);
}


static inline UIColor *GetRandomUIColor()
{
    CGFloat r = arc4random() % 255;
    CGFloat g = arc4random() % 255;
    CGFloat b = arc4random() % 255;
    UIColor * color = [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1.0f];
    return color;
}

#pragma mark - GMUClusterManagerDelegate
- (BOOL)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
    GMSCameraPosition *newCamera =
    [GMSCameraPosition cameraWithTarget:cluster.position zoom:_mapView.camera.zoom + 1];
    GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newCamera];
    [_mapView moveCamera:update];
    return true;
}

//- (void)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
//  GMSCameraPosition *newCamera =
//      [GMSCameraPosition cameraWithTarget:cluster.position zoom:_mapView.camera.zoom + 1];
//  GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newCamera];
//  [_mapView moveCamera:update];
//}

- (void)initialCluster {
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
    [finalSelectedValues setObject:_surveyID forKey:@"SURVEY_ID"];
    
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
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/survey_latlng2.php" andParam:finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if (isSuccess) {
            
            //for (NSDictionary *cluster in response) {
            if ([response objectForKey:@"CLUSTERS"] != [NSNull null]) {
                [self showClusterOnMap:[response objectForKey:@"CLUSTERS"]];
                _filteredCountLabel.text = [NSString stringWithFormat:@"Total filtered respondent count : %lu",[[response objectForKey:@"CLUSTERS"] count]];
                _totalRespondantLabel.text = [NSString stringWithFormat:@"Total respondent : %@",[response objectForKey:@"TOTAL_RESP"]];
            }
            else {
                [_clusterManager clearItems];
            }
            
            if ([response objectForKey:@"COUNT"] != [NSNull null]) {
                countArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *attributeDict in [response objectForKey:@"COUNT"]) {
                    if ([[attributeDict objectForKey:@"OPTIONS"] count]) {
                        [countArray addObject:attributeDict];
                    }
                }
                [self.misCollectionView reloadData];
            }
            NSLog(@"%@",response);
        }
    }];
}

#pragma mark - GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    POIItem *poiItem = marker.userData;
    if (poiItem != nil) {
        NSLog(@"Did tap marker for cluster item %@", poiItem.name);
    } else {
        NSLog(@"Did tap a normal marker");
    }
    return NO;
}

#pragma mark - Private

// Randomly generates cluster items within some extent of the camera and adds them to the
// cluster manager.
- (void)generateClusterItemsLat:(NSArray *)clusterInfoList {
    //const double extent = 0.2;
    for (int index = 0; index < [clusterInfoList count]; ++index) {
        double lat = [[[clusterInfoList objectAtIndex:index] objectForKey:@"lat"] doubleValue];
        double lng = [[[clusterInfoList objectAtIndex:index] objectForKey:@"lng"] doubleValue];
        NSString *name =[NSString stringWithFormat:@"%@", [[clusterInfoList objectAtIndex:index] objectForKey:@"info"]];
        
        id<GMUClusterItem> item = [[POIItem alloc] initWithPosition:CLLocationCoordinate2DMake(lat, lng) name:name];
        [_clusterManager addItem:item];
    }
    //[_clusterManager cluster];
}

// Returns a random value between -1.0 and 1.0.
- (double)randomScale {
    return (double)arc4random() / UINT32_MAX * 2.0 - 1.0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - WebServices

-(void)getAttributeData:(NSString *)preID  andAttributeName:(NSString *)name {
    
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/get_chart_graph_data.php" andParam:@{@"SURVEY_ID":_surveyID,@"PRE_ID":preID,@"ATTRIBUTE_NAME":name} withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if (isSuccess) {
            pieChartArray = [[NSMutableArray alloc] init];
            pieChartArray = response;
            
            for (NSMutableDictionary *itemDict in pieChartArray) {
                [itemDict setObject:@"YES" forKey:@"isSelected"];
                UIColor *color = GetRandomUIColor();
                [itemDict setObject:color forKey:@"COLOR"];
            }
            [self.pieChartView reloadData];
            [self.chartLegendsCollectionView reloadData];
            [self drawCircular];
            [self drawBarChart];
            [barChartView reloadBarGraph];
            [self.attributeIconCollectionView reloadData];
            if ([preID isEqualToString:@"1"] || [preID isEqualToString:@"2"] || [preID isEqualToString:@"3"]) {
                [_barIconBtn setHidden:NO];
            }
            else {
                [_barIconBtn setHidden:YES];
            }
            
            //[self.cirCulerChartView reloadCircularChart];
        }
        else {
            
        }
    }];
}

- (void)fetchAttributes {
    
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/get_predefined_controls_user.php" andParam:@{@"DATA":_surveyID} withBlock:^(id response, BOOL isSuccess) {
    
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
//                if ([[tempDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"Toggle Switch"]) {
//                    [[tempDict objectForKey:@"OPTIONS"] insertObject:[@{@"OPTION_NAME":@"No"} mutableCopy] atIndex:1];
//                }
            }
            [demographicsArray removeObject:tempLocDict];
            [demographicsArray removeObject:tempTextBoxDict];
            [demographicsArray insertObject:tempLocDict atIndex:0];
            
            selectedDemoGraphicsList = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:demographicsArray]];
            
            NSMutableDictionary *locationDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *textBoxDict = [[NSMutableDictionary alloc] init];
            
            for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
                
                _totalRespondantLabel.text = [NSString stringWithFormat:@"Total Respondent : %@",[attributeDict objectForKey:@"RESPONDANT_COUNT"]];
                respondantCount = [[attributeDict objectForKey:@"RESPONDANT_COUNT"] integerValue];
                [attributeDict setObject:@"YES" forKey:@"SWITCH_VALUE"];
                
                if ([[attributeDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"TextBox"]) {
                    textBoxDict = attributeDict;
                    continue;
                }
                
                if ([[attributeDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"Toggle Switch"]) {
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:@"Yes" forKey:@"OPTION_NAME"];
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:1] setObject:@"No" forKey:@"OPTION_NAME"];
                }
                
//                if ([[attributeDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"Slider"]) {
//                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:[[[[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@"-"] lastObject] forKey:@"OPTION_NAME"];
//                }
                
                for (NSMutableDictionary *optionDict in [attributeDict objectForKey:@"OPTIONS"]) {
                    [optionDict setObject:@"YES" forKey:@"CHECKBOX_VALUE"];
                }
                
                if ([[attributeDict objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
                    //[demographicsArray removeObjectAtIndex:[selectedDemoGraphicsList indexOfObject:attributeDict]];
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:@"Country" forKey:@"BUTTON_NAME"];
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:1] setObject:@"State" forKey:@"BUTTON_NAME"];
                    [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:2] setObject:@"City" forKey:@"BUTTON_NAME"];
                    locationDict = attributeDict;
                }
                
            }
            [selectedDemoGraphicsList removeObject:locationDict];
            [selectedDemoGraphicsList removeObject:textBoxDict];
            [selectedDemoGraphicsList insertObject:locationDict atIndex:0];
            //[selectedDemoGraphicsList insertObject:locationDict atIndex:0];
            [self initialCluster];
            [self.misCollectionView reloadData];
            [self.demographicsTableView reloadData];
        }
        else {
            
        }
    }];
}

#pragma mark - UICollectionView Delegate / Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
   if (collectionView == _chartLegendsCollectionView) {
        return 1;
    }
   else if (collectionView == _attributeIconCollectionView) {
       return 1;
   }
    else {
        NSInteger count = 0;
        for (NSDictionary *attributeDict in countArray) {
            if ([[attributeDict objectForKey:@"OPTIONS"] count]) {
                count++;
            }
        }
        return count;
        
        //return [countArray count];
    }
     //return [[finalSelectedValues objectForKey:@""] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _chartLegendsCollectionView) {
//        NSInteger count = 0;
//        for (NSDictionary *itemDict in pieChartArray) {
//            if ([[itemDict objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                count++;
//            }
//        }
        return [pieChartArray count];
        //return count;
    }
    else if (collectionView == _attributeIconCollectionView) {
        if ([selectedPreID isEqualToString:@"1"] || [selectedPreID isEqualToString:@"2"] || [selectedPreID isEqualToString:@"3"]) {
            return [pieChartArray count];
        }
        return 0;
    }
    else {
        return [[[countArray objectAtIndex:section] objectForKey:@"OPTIONS"] count];
    }
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _chartLegendsCollectionView) {
        ChartLegendsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

        [cell.legendNameBtn setTitle:[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"] forState:UIControlStateNormal];
        [cell.legendColorBtn setBackgroundColor:[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"COLOR"]];
        if ([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [cell.legendNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        else {
            [cell.legendNameBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        cell.legendColorBtn.tag = indexPath.section*100+indexPath.row;
        cell.legendNameBtn.tag = indexPath.section*100+indexPath.row;
        [cell.legendColorBtn addTarget:self action:@selector(didTapOnLegend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.legendNameBtn addTarget:self action:@selector(didTapOnLegend:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if (collectionView == _attributeIconCollectionView) {
         AttributeIconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        
        if ([selectedPreID isEqualToString:@"1"]) {
            NSInteger perCentage = ([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"TOTAL_COUNT"] floatValue]/respondantCount)*100;
            NSInteger i = perCentage / 10;
            //cell.iconLabel.text = [NSString stringWithFormat:@"%@ (%ld%%)",[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"],(long)perCentage];
             cell.iconLabel.text = [NSString stringWithFormat:@"%@ (%@)",[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"],[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"TOTAL_COUNT"]];
            if ([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"] containsString:@"Male"]) {
                cell.iconImage.image = [UIImage imageNamed:[maleImgArray objectAtIndex:i]];
            }
            else if([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"] containsString:@"Female"]) {
                cell.iconImage.image = [UIImage imageNamed:[femaleImgArray objectAtIndex:i]];
            }
            else if([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"] containsString:@"Do not want to specify"]) {
                cell.iconImage.image = [UIImage imageNamed:[doNotImgArray objectAtIndex:i]];
            }
            else if([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"] containsString:@"Transgender"]) {
                cell.iconImage.image = [UIImage imageNamed:[transgenderArray objectAtIndex:i]];
            }
        }
        else if ([selectedPreID isEqualToString:@"2"]) {
           NSInteger maxAge = [[[[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"] componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue];
            NSInteger perCentage = ([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"TOTAL_COUNT"] floatValue]/respondantCount)*100;
            NSInteger i = maxAge / 10;
            
            cell.iconImage.image = [UIImage imageNamed:[ageGroupArray objectAtIndex:i]];
            //cell.iconLabel.text = [NSString stringWithFormat:@"%@ (%ld%%)",[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"],(long)perCentage];
            cell.iconLabel.text = [NSString stringWithFormat:@"%@ (%@)",[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"],[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"TOTAL_COUNT"]];
        }
        else if ([selectedPreID isEqualToString:@"3"]) {
            
            NSInteger index = [[[[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"] componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue]/100000;
            
            NSInteger perCentage = ([[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"TOTAL_COUNT"] floatValue]/respondantCount)*100;
            
            //cell.iconLabel.text = [NSString stringWithFormat:@"%@ (%ld%%)",[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"],(long)perCentage];
            cell.iconLabel.text = [NSString stringWithFormat:@"%@ (%@)",[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"ATTRIBUTE_NAME"],[[pieChartArray objectAtIndex:indexPath.row] objectForKey:@"TOTAL_COUNT"]];
            
            if (index <= 1 ) {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:0]];
            }
            else if(index > 1 && index <= 3) {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:1]];
            }
            else if(index > 3 && index <= 6) {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:2]];
            }
            else if(index > 6 && index <= 10) {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:3]];
            }
            else if(index > 10 && index <= 15) {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:4]];
            }
            else if(index > 15 && index <= 20) {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:5]];
            }
            else if(index > 20 && index <= 25) {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:6]];
            }
            else {
                cell.iconImage.image = [UIImage imageNamed:[incomeGrpArray objectAtIndex:7]];
            }
        }
        return cell;
    }
    else {
        MISCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        
//        NSAttributedString *headingLabel = [[NSAttributedString alloc] initWithString:[[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allKeys] objectAtIndex:indexPath.row] attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Century Gothic Bold" size:17] forKey:NSFontAttributeName]];
//
//        NSAttributedString *subHeadingLabel = [[NSAttributedString alloc] initWithString:[[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allValues] objectAtIndex:indexPath.row] attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Century Gothic Reguler" size:17] forKey:NSFontAttributeName]];

        cell.optionNameLabel.text = [NSString stringWithFormat:@"%@ - %@",[[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allKeys] objectAtIndex:indexPath.row],[[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allValues] objectAtIndex:indexPath.row]];
        //cell.optionNameLabel.text = [[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allKeys] objectAtIndex:indexPath.row];
       // cell.countLabel.text = [[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allValues] objectAtIndex:indexPath.row];
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView != _chartLegendsCollectionView) {

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
    }
    else if (collectionView == _attributeIconCollectionView) {
        SectionHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerView" forIndexPath:indexPath];
        return header;
    }
    else {
        SectionHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerView" forIndexPath:indexPath];
        return header;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (collectionView == _misCollectionView) {
        return CGSizeMake(164, 40);
    }
    else {
        return CGSizeMake(0, 0);
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (collectionView == _misCollectionView) {

        NSString *testString = [self getMaxLengthString:[[[countArray objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] allKeys]];
        CGSize calCulateSizze =[testString sizeWithAttributes:NULL];
        calCulateSizze.width = calCulateSizze.width+100;
        calCulateSizze.height = 40;
        return calCulateSizze;
    }
    else if (collectionView == _attributeIconCollectionView){
      
        return CGSizeMake(collectionView.frame.size.width/4, 170);
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

#pragma mark - UITableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [demographicsArray count];
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
        if (indexPath.row == 0) {
            LocationHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationHeadCell"];
            if (cell == nil) {
                cell = [[LocationHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationHeadCell"];
            }
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
//    else if ([[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Toggle Switch"]) {
//        ToggleSwitchTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
//        if (cell == nil) {
//            cell = [[[ToggleSwitchTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCell"];
//        }
//        cell.attributeNameLabel.text = [[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"ATTRIBUTE_NAME"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.attributeSwitch.tag = indexPath.section*100+indexPath.row;
//        [cell.attributeSwitch addTarget:self action:@selector(attributeSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
//        if ([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"SWITCH_VALUE"] isEqualToString:@"YES"]) {
//            [cell.attributeSwitch setOn:YES];
//            //[cell.toggleSwitch setEnabled:YES];
//        }
//        else {
//            [cell.attributeSwitch setOn:NO];
//            //[cell.toggleSwitch setEnabled:NO];
//        }
//        if ([[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"CHECKBOX_VALUE"] isEqualToString:@"YES"]) {
//            [cell.toggleSwitch setOn:YES];
//        }
//        else {
//            [cell.toggleSwitch setOn:NO];
//        }
//        //[cell.toggleSwitch setOn:[[[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"OPTIONS"] objectAtIndex:indexPath.row] objectForKey:@"OPTION_NAME"]];
//        cell.toggleSwitch.tag = indexPath.section*100+indexPath.row;
//        [cell.toggleSwitch addTarget:self action:@selector(toggleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
//        return cell;
//    }
    else if ([[[demographicsArray objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"TextBox"]) {
        TextFieldTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
        if (cell == nil) {
            cell = [[[TextFieldTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldCell"];
        }
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
    
    CheckBoxSubHeadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"checkBoxHeadCell"];
    if (cell == nil) {
        cell = [[[CheckBoxSubHeadTableViewCell alloc] init] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"checkBoxHeadCell"];
    }
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
    if([[[selectedDemoGraphicsList objectAtIndex:indexPath.section] objectForKey:@"INPUT_TYPE"] isEqualToString:@"Slider"]) {
        return 70;
    }
    return 44;
}

#pragma mark - Slider Delegate
- (void)updateSliderValues:(NSInteger)section andLowerValue:(NSString *)lValue andUpper:(NSString *)uValue {
    [[[[selectedDemoGraphicsList objectAtIndex:section] objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:[NSString stringWithFormat:@"%@-%@",lValue,uValue]  forKey:@"OPTION_NAME"];
}

#pragma mark - Export Delegate

-(void)pdfBtnPressed:(BOOL)isMap {
    
    finalSelectedValues = [[NSMutableDictionary alloc] init];
    [finalSelectedValues setObject:countArray forKey:@"DATA"];
    
    NSString *base64Str;
    if (isMap) {
        base64Str = [UIImagePNGRepresentation([self pb_takeSnapshot:self.mapView]) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    else {
        base64Str = [UIImagePNGRepresentation([self pb_takeSnapshot:_chartsView]) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    NSLog(@"IMGSTR : %@",base64Str);
    [finalSelectedValues setObject:base64Str forKey:@"MAP_IMAGE"];
    
    [finalSelectedValues setObject:_surveyName forKey:@"SURVEY_NAME"];
    [finalSelectedValues setObject:_surveyType forKey:@"SURVEY_TYPE"];
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *countryJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSMutableArray *countryNameList = [[NSMutableArray alloc] init];
    for (NSDictionary *countryDict in [[countryJson objectAtIndex:1] objectForKey:@"COUNTRY"]) {
        
        for (NSString *contryID in countryIDs) {
            if ([contryID isEqualToString:[countryDict objectForKey:@"id"]]) {
                [countryNameList addObject:[countryDict objectForKey:@"name"]];
            }
        }
    }
    [finalSelectedValues setObject:[[countryNameList valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"COUNTRY_NAME"];
    
    if (stateIDs == nil) {
        
        [finalSelectedValues setObject:@"" forKey:@"STATE_NAME"];
    }
    else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"State" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSArray *stateJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSMutableArray *stateNameList = [[NSMutableArray alloc] init];
        for (NSDictionary *stateDict in stateJson) {
            
            for (NSString *stateID in stateIDs) {
                if ([stateID isEqualToString:[stateDict objectForKey:@"id"]]) {
                    [stateNameList addObject:[stateDict objectForKey:@"name"]];
                }
            }
        }
        [finalSelectedValues setObject:[[stateNameList valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"STATE_NAME"];
    }
    
    if (cityIDs == nil) {
        [finalSelectedValues setObject:@"" forKey:@"CITY_NAME"];
    }
    else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"City" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSArray *cityJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSMutableArray *cityNameList = [[NSMutableArray alloc] init];
        for (NSDictionary *cityDict in cityJson) {
            
            for (NSString *cityID in cityIDs) {
                if ([cityID isEqualToString:[cityDict objectForKey:@"id"]]) {
                    [cityNameList addObject:[cityDict objectForKey:@"name"]];
                }
            }
        }
        [finalSelectedValues setObject:[[cityNameList valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"CITY_NAME"];
    }
    [finalSelectedValues setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"] forKey:@"CREATED_BY_ID"];
    [finalSelectedValues setObject:_surveyID forKey:@"SURVEY_ID"];
    
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/EXPORT_TO_PDF/examples/export_to_pdf.php" andParam:finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
        
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
            [mc addAttachmentData:data mimeType:@"application/pdf" fileName:[[[response objectForKey:@"LINK"] componentsSeparatedByString:@"/"] lastObject]];
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            if (![mc isEqual:[NSNull null]]) {
                [self presentViewController:mc animated:YES completion:NULL];
            }
        }
    }];
}

-(void)csvBtnPressed:(BOOL)isMap {

    finalSelectedValues = [[NSMutableDictionary alloc] init];
    [finalSelectedValues setObject:countArray forKey:@"DATA"];
    
    [finalSelectedValues setObject:_surveyName forKey:@"SURVEY_NAME"];
    [finalSelectedValues setObject:_surveyType forKey:@"SURVEY_TYPE"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *countryJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSMutableArray *countryNameList = [[NSMutableArray alloc] init];
    for (NSDictionary *countryDict in [[countryJson objectAtIndex:1] objectForKey:@"COUNTRY"]) {
        
        for (NSString *contryID in countryIDs) {
            if ([contryID isEqualToString:[countryDict objectForKey:@"id"]]) {
                [countryNameList addObject:[countryDict objectForKey:@"name"]];
            }
        }
    }
    [finalSelectedValues setObject:[[countryNameList valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"COUNTRY_NAME"];
    
    if (stateIDs == nil) {
        
        [finalSelectedValues setObject:@"" forKey:@"STATE_NAME"];
    }
    else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"State" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSArray *stateJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSMutableArray *stateNameList = [[NSMutableArray alloc] init];
        for (NSDictionary *stateDict in stateJson) {
            
            for (NSString *stateID in stateIDs) {
                if ([stateID isEqualToString:[stateDict objectForKey:@"id"]]) {
                    [stateNameList addObject:[stateDict objectForKey:@"name"]];
                }
            }
        }
        [finalSelectedValues setObject:[[stateNameList valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"STATE_NAME"];
    }
    
    if (cityIDs == nil) {
        [finalSelectedValues setObject:@"" forKey:@"CITY_NAME"];
    }
    else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"City" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSArray *cityJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSMutableArray *cityNameList = [[NSMutableArray alloc] init];
        for (NSDictionary *cityDict in cityJson) {
            
            for (NSString *cityID in cityIDs) {
                if ([cityID isEqualToString:[cityDict objectForKey:@"id"]]) {
                    [cityNameList addObject:[cityDict objectForKey:@"name"]];
                }
            }
        }
        [finalSelectedValues setObject:[[cityNameList valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"CITY_NAME"];
    }
    [finalSelectedValues setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"] forKey:@"CREATED_BY_ID"];
    [finalSelectedValues setObject:_surveyID forKey:@"SURVEY_ID"];
    
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/EXPORT_TO_EXCEL/export_to_csv.php" andParam:finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
        
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
            [mc addAttachmentData:data mimeType:@"text/csv" fileName:[[[response objectForKey:@"LINK"] componentsSeparatedByString:@"/"] lastObject]];
            
            if (isMap) {
                [mc addAttachmentData:UIImagePNGRepresentation([self pb_takeSnapshot:self.mapView]) mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png",_surveyName]];
            }
            else {
                [mc addAttachmentData:UIImagePNGRepresentation([self pb_takeSnapshot:self.chartsView]) mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png",_surveyName]];
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

#pragma mark - Selector methods

- (void)didTapOnLegend:(UIButton *)sender {
    
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    for (NSMutableDictionary *itemDict in pieChartArray) {
        if ([[itemDict objectForKey:@"ATTRIBUTE_NAME"] isEqualToString:sender.titleLabel.text]) {
            if ([[itemDict objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [itemDict setObject:@"NO" forKey:@"isSelected"];
            }
            else {
                [itemDict setObject:@"YES" forKey:@"isSelected"];
            }
            break;
        }
    }
    //[[pieChartArray objectAtIndex:sender.tag] setObject:@"NO" forKey:@"isSelected"];
    [self drawCircular];
    [self drawBarChart];
    //[barChartView reloadBarGraph];
    [_pieChartView reloadData];
    [_chartLegendsCollectionView performBatchUpdates:^{
        [_chartLegendsCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]]];
    } completion:^(BOOL finished) {}];
    //[self.chartLegendsCollectionView reloadSections:[NSIndexSet indexSetWithIndex:<#(NSUInteger)#>]];
}

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

- (void)selectedCityBtnPressed:(UIButton *)sender {
 
}

- (IBAction)selectAllAttributeSwitchValueChanged:(id)sender {
    
    if ([_selectAllAttributeSwitch isOn]) {
        
        for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
            
            [attributeDict setObject:@"YES" forKey:@"SWITCH_VALUE"];
            
            for (NSMutableDictionary *optionDict in [attributeDict objectForKey:@"OPTIONS"]) {
                [optionDict setObject:@"YES" forKey:@"CHECKBOX_VALUE"];
            }
            
//            if ([[attributeDict objectForKey:@"INPUT_TYPE"] isEqualToString:@"Slider"]) {
//                [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] setObject:<#(nonnull id)#> forKey:@"OPTION_NAME"];
//            }
            
//            if ([[attributeDict objectForKey:@"CONTROL_NAME"] isEqualToString:@"ddl_location"]) {
//                //[demographicsArray removeObjectAtIndex:[selectedDemoGraphicsList indexOfObject:attributeDict]];
//                countryIDs = [[NSMutableArray alloc] init];
//                [countryIDs addObjectsFromArray:[[[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:0] objectForKey:@"OPTION_NAME"] componentsSeparatedByString:@","]];
//
//                [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:1] setObject:@"State" forKey:@"BUTTON_NAME"];
//                [[[attributeDict objectForKey:@"OPTIONS"] objectAtIndex:2] setObject:@"City" forKey:@"BUTTON_NAME"];
//            }
            
        }
        //[self initialCluster];
        //[self.misCollectionView reloadData];
        [self.demographicsTableView reloadData];
    }
    else {
        for (NSMutableDictionary *attributeDict in selectedDemoGraphicsList) {
            
            [attributeDict setObject:@"NO" forKey:@"SWITCH_VALUE"];
            for (NSMutableDictionary *optionDict in [attributeDict objectForKey:@"OPTIONS"]) {
                [optionDict setObject:@"NO" forKey:@"CHECKBOX_VALUE"];
            }
        }
        [self.demographicsTableView reloadData];
    }
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

- (IBAction)graphViewPanGesture:(UIPanGestureRecognizer *)sender {
    
//    [self.view bringSubviewToFront:sender.view];
//    CGPoint translatedPoint = [sender translationInView:sender.view];
//
//    if (sender.state == UIGestureRecognizerStateBegan) {
//        NSLog(@"touches began in uiview");
//    }
//
//    translatedPoint = CGPointMake(sender.view.center.x+translatedPoint.x, sender.view.center.y+translatedPoint.y);
//
//    [sender.view setCenter:translatedPoint];
//    [sender setTranslation:CGPointZero inView:sender.view];
//
//    if (sender.state == UIGestureRecognizerStateEnded) {
//        CGFloat velocityX = (0.2*[sender velocityInView:self.view].x);
//        CGFloat velocityY = (0.2*[sender velocityInView:self.view].y);
//
//        CGFloat finalX = self.chartView.layer.frame.size.width/2;//translatedPoint.x + velocityX;
//        CGFloat finalY = self.view.layer.frame.size.height - self.chartView.layer.frame.size.height;
//
//        if(velocityY > 0)
//        {
//            NSLog(@"gesture moving Up");
//            finalY = self.view.layer.frame.size.height;
//        }
//        else
//        {
//            NSLog(@"gesture moving Bottom");
//            //finalY = self.view.layer.frame.size.height - self.chartView.layer.frame.size.height;
//        }
//
//        CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
//
//        NSLog(@"the duration is: %f", animationDuration);
//
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:animationDuration];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        [UIView setAnimationDelegate:self];
//        //[UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
//        //        [[sender view] setCenter:CGPointMake(self.bottomViewUp.layer.frame.size.width/2, self.view.layer.frame.size.height - 50)];
//
//        [[sender view] setCenter:CGPointMake(finalX, finalY)];
//        [UIView commitAnimations];
//    }

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

#pragma mark - UIButton Events

- (IBAction)attributeIconsBtnPressed:(UIButton *)sender {
    
    if (sender.tag == 0) {
        _cirIconBtn.tag = 1;
        _barIconBtn.tag = 1;
        _pieIconBtn.tag = 1;
        //[_attributeIconsView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        [_attributeIconsView setHidden:false];
    }
    else {
        _cirIconBtn.tag = 0;
        _barIconBtn.tag = 0;
        _pieIconBtn.tag = 0;
        //[_attributeIconsView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        [_attributeIconsView setHidden:true];
    }
    
    //[_pieChartView setHidden:true];
    //[_cirCularChartBaseView setHidden:true];
    //[_barChartBaseView setHidden:true];
}

- (IBAction)pieChartBtnPressed:(id)sender {
    if ([pieChartArray count]) {
        [_attributeIconsView setHidden:true];
        [_pieChartView setHidden:false];
        [_cirCularChartBaseView setHidden:true];
        [_barChartBaseView setHidden:true];
    }
    else {
        [self showAlertView:@"Alive 2.0" message:@"Please select valid attribute name"];
    }
}

- (IBAction)barChartBtnPressed:(id)sender {
     if ([pieChartArray count]) {
        [_attributeIconsView setHidden:true];
        [_pieChartView setHidden:true];
        [_cirCularChartBaseView setHidden:true];
        [_barChartBaseView setHidden:false];
     }
     else {
         [self showAlertView:@"Alive 2.0" message:@"Please select valid attribute name"];
     }
}

- (IBAction)doughtChartBtnPressed:(id)sender {
    if ([pieChartArray count]) {
        [_pieChartView setHidden:true];
        [_cirCularChartBaseView setHidden:false];
        [_barChartBaseView setHidden:true];
    }
    else {
        [self showAlertView:@"Alive 2.0" message:@"Please select valid attribute name"];
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
        
        finalSelectedValues = [[NSMutableDictionary alloc] init];
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
        [finalSelectedValues setObject:_surveyID forKey:@"SURVEY_ID"];
        
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
        
        [self.misCollectionView reloadData];
        
        [self showLoader:YES];
        [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/survey_latlng2.php" andParam:finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
            
            [self showLoader:NO];
            if (isSuccess) {
                
                if ([response objectForKey:@"CLUSTERS"] != [NSNull null]) {
                     [self showClusterOnMap:[response objectForKey:@"CLUSTERS"]];
                    _filteredCountLabel.text = [NSString stringWithFormat:@"Total filtered respondent count : %ld",[[response objectForKey:@"CLUSTERS"] count]];
                    NSLog(@"%@",[response objectForKey:@"TOTAL_RESP"]);
                   
                    //_totalRespondantLabel.text = [NSString stringWithFormat:@"Total respondant : %@",[response objectForKey:@"TOTAL_RESP"]];
                }
                else {
                    [_clusterManager clearItems];
                }
                
                [_clusterManager cluster];
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:0];
                _mapView.camera = camera;
                
                if ([response objectForKey:@"COUNT"] != [NSNull null]) {
                    countArray = [[NSMutableArray alloc] init];
                    [countArray addObjectsFromArray:[response objectForKey:@"COUNT"]];
                    NSInteger count = 0;
                    for (NSDictionary *attributeDict in countArray) {
                        if ([[attributeDict objectForKey:@"OPTIONS"] count]) {
                            count++;
                        }
                    }
                    if (!count) {
                        [self showAlertView:@"Alive 2.0" message:@"No respondent availabel"];
                    }
                    [self.misCollectionView reloadData];
                    
                    if (![_dropDownBtn.titleLabel.text isEqualToString:@"Select Attribute"]) {
                        [self updateCharts];
                    }
                    
                }
                // = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"COUNT"]];
                //[self.misCollectionView reloadData];
                NSLog(@"%@",response);
            }
        }];
    }
}


- (IBAction)graphViewUpBtnPressed:(id)sender {
    
    [UIView animateWithDuration:1 animations:^{
        _chartViewBottomConstraint.constant = (_chartViewBottomConstraint.constant == 410) ? 0:410;
        [self.view layoutIfNeeded];
    }];
    
}

- (IBAction)selectAttributeDropDown:(id)sender {
    
    [UIView animateWithDuration:1 animations:^{
        _chartViewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
    dropDownList = [[NSMutableArray alloc] init];
    for (NSDictionary *attributeDict in selectedDemoGraphicsList) {
        if ([[attributeDict objectForKey:@"ATTRIBUTE_NAME"] isEqualToString:@"Location"]) {
            continue;
        }
        [dropDownList addObject:[attributeDict objectForKey:@"ATTRIBUTE_NAME"]];
    }
    NSArray * arrImage = [[NSArray alloc] init];
    if(attributeDropDown == nil)
    {
        CGFloat f = 120;
        attributeDropDown = [[NIDropDown alloc]showDropDown:_dropDownBtn :&f :dropDownList :arrImage :@"down" :[UIImage imageNamed:@"umTxt.png"]];
        attributeDropDown.delegate = self;
    }
    else
    {
        [attributeDropDown hideDropDown:sender];
        attributeDropDown = nil;
    }
}

-(void)niDropDownDelegateMethod:(NIDropDown *)sender {
    attributeDropDown = nil;
    NSLog(@"%ld", _dropDownBtn.tag);
    NSLog(@"%@", [dropDownList objectAtIndex:_dropDownBtn.tag]);
    
    pieChartArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *attributeDict in countArray) {
        
        if ([[attributeDict objectForKey:@"ATTRIBUTE_NAME"] isEqualToString:[dropDownList objectAtIndex:_dropDownBtn.tag]]) {
            
            for (NSInteger i = 0; i < [[[attributeDict objectForKey:@"OPTIONS"] allKeys] count]; i++) {
                NSMutableDictionary *optionDict = [[NSMutableDictionary alloc] init];
                [optionDict setObject:[[[attributeDict objectForKey:@"OPTIONS"] allKeys] objectAtIndex:i] forKey:@"ATTRIBUTE_NAME"];
                [optionDict setObject:[[[attributeDict objectForKey:@"OPTIONS"] allValues] objectAtIndex:i] forKey:@"TOTAL_COUNT"];
                [pieChartArray addObject:[optionDict mutableCopy]];
            }
            
            for (NSMutableDictionary *itemDict in pieChartArray) {
                [itemDict setObject:@"YES" forKey:@"isSelected"];
                UIColor *color = GetRandomUIColor();
                [itemDict setObject:color forKey:@"COLOR"];
            }

            [self.pieChartView reloadData];
            [self.chartLegendsCollectionView reloadData];
            [self drawCircular];
            [self drawBarChart];
            if ([[attributeDict objectForKey:@"PRE_ID"] isEqualToString:@"1"] || [[attributeDict objectForKey:@"PRE_ID"] isEqualToString:@"2"] || [[attributeDict objectForKey:@"PRE_ID"] isEqualToString:@"3"]) {
                selectedPreID = [attributeDict objectForKey:@"PRE_ID"];
                [_barIconBtn setHidden:NO];
                [_attributeIconCollectionView reloadData];
            }
            else {
                [_barIconBtn setHidden:YES];
            }
        }
    }
    if (![pieChartArray count]) {
        [self.pieChartView reloadData];
        [self.chartLegendsCollectionView reloadData];
        [self drawCircular];
        [self showAlertView:@"Alive 2.0" message:@"No respondent data found for selected filtered"];
    }
}

- (void)updateCharts {
    pieChartArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *attributeDict in countArray) {
        
        if ([[attributeDict objectForKey:@"ATTRIBUTE_NAME"] isEqualToString:_dropDownBtn.titleLabel.text]) {
            
            for (NSInteger i = 0; i < [[[attributeDict objectForKey:@"OPTIONS"] allKeys] count]; i++) {
                NSMutableDictionary *optionDict = [[NSMutableDictionary alloc] init];
                [optionDict setObject:[[[attributeDict objectForKey:@"OPTIONS"] allKeys] objectAtIndex:i] forKey:@"ATTRIBUTE_NAME"];
                [optionDict setObject:[[[attributeDict objectForKey:@"OPTIONS"] allValues] objectAtIndex:i] forKey:@"TOTAL_COUNT"];
                [pieChartArray addObject:[optionDict mutableCopy]];
            }
            
            for (NSMutableDictionary *itemDict in pieChartArray) {
                [itemDict setObject:@"YES" forKey:@"isSelected"];
                UIColor *color = GetRandomUIColor();
                [itemDict setObject:color forKey:@"COLOR"];
            }
            
            [self.pieChartView reloadData];
            [self.chartLegendsCollectionView reloadData];
            [self drawCircular];
            [self drawBarChart];
            if ([[attributeDict objectForKey:@"PRE_ID"] isEqualToString:@"1"] || [[attributeDict objectForKey:@"PRE_ID"] isEqualToString:@"2"] || [[attributeDict objectForKey:@"PRE_ID"] isEqualToString:@"3"]) {
                selectedPreID = [attributeDict objectForKey:@"PRE_ID"];
                [_barIconBtn setHidden:NO];
                [_attributeIconCollectionView reloadData];
            }
            else {
                [_barIconBtn setHidden:YES];
            }
        }
    }
    if (![pieChartArray count]) {
        [self.pieChartView reloadData];
        [self.chartLegendsCollectionView reloadData];
        [self drawCircular];
        [self showAlertView:@"Alive 2.0" message:@"No respondent data found for selected filtered"];
    }
}

- (IBAction)sliderMenuBtnPressed:(id)sender {
    
    if (_sliderMenuTrailingConstraint.constant == 400) {
        [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [blurView setAlpha:0.5];
            [self.view addSubview:blurView];
            [self.view bringSubviewToFront:_rightSliderView];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
//    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
//
//    if (![_rightSliderView pointInside:locationPoint withEvent:event]) {
//        [UIView animateWithDuration:1 animations:^{
//            _sliderMenuTrailingConstraint.constant = (_sliderMenuTrailingConstraint.constant == 0) ? 400:400;
//            [self.view layoutIfNeeded];
//        }];
//    }
    //UIView* viewYouWishToObtain = [self hitTest:locationPoint withEvent:event];
}

- (IBAction)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeBtnPressed:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)exportBtnPressed:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        _sliderMenuTrailingConstraint.constant = (_sliderMenuTrailingConstraint.constant == 0) ? 400:400;
        [self.view layoutIfNeeded];
    }];
    ExportViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"ExportViewController"];
    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.preferredContentSize = CGSizeMake(375, 90);
    controller.delegate = self;
    controller.isMap = true;
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.delegate = self;
    popController.sourceRect = _exportBtn.frame;
    popController.sourceView = _exportBtn.superview;
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)exportChartsBtnPressed:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        _sliderMenuTrailingConstraint.constant = (_sliderMenuTrailingConstraint.constant == 0) ? 400:400;
        [self.view layoutIfNeeded];
    }];
    ExportViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"ExportViewController"];
    controller.modalPresentationStyle = UIModalPresentationPopover;
    controller.preferredContentSize = CGSizeMake(375, 90);
    controller.delegate = self;
    controller.isMap = false;
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.delegate = self;
    popController.sourceRect = _exportChartBtn.frame;
    popController.sourceView = _exportChartBtn.superview;
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [self presentViewController:controller animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

//- (void)exportViaMailWithImg:(UIImage *)screenShotImg andSender:(UIButton *)sender {
//
//    if (countryIDs == nil) {
//
//    }
//    else {
//        [UIView animateWithDuration:1 animations:^{
//            _sliderMenuTrailingConstraint.constant = (_sliderMenuTrailingConstraint.constant == 0) ? 400:400;
//            [self.view layoutIfNeeded];
//        }];
//
//        finalSelectedValues = [[NSMutableDictionary alloc] init];
//        [finalSelectedValues setObject:countArray forKey:@"DATA"];
//
//        NSString *base64Str = [UIImagePNGRepresentation(screenShotImg) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//        NSLog(@"IMGSTR : %@",base64Str);
//        [finalSelectedValues setObject:base64Str forKey:@"MAP_IMAGE"];
//
//        [finalSelectedValues setObject:_surveyName forKey:@"SURVEY_NAME"];
//        [finalSelectedValues setObject:_surveyType forKey:@"SURVEY_TYPE"];
//        [finalSelectedValues setObject:[[countryIDs valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"COUNTRY_ID"];
//
//        if (stateIDs == nil) {
//            [finalSelectedValues setObject:@"" forKey:@"STATE_ID"];
//        }
//        else {
//            [finalSelectedValues setObject:[[stateIDs valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"STATE_ID"];
//        }
//
//        if (cityIDs == nil) {
//            [finalSelectedValues setObject:@"" forKey:@"CITY_ID"];
//        }
//        else {
//            [finalSelectedValues setObject:[[cityIDs valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"CITY_ID"];
//        }
//
//    }
//}


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

#pragma mark - Utilities

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
