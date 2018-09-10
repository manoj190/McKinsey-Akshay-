//
//  fpOutput.m
//  mckinsey
//
//  Created by Mac on 26/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "fpOutput.h"
//#import "dashboard.h"
#define COEFF_PAD ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 2.0 : 1.0)

@interface fpOutput ()
{
    UIChart *chrt;
    IBOutlet UIImageView *graphView;
    UIButton *btnForward;
    UIButton *btnBackward;
    UILabel *lblSampleTitle;
    UISwitch *swhOrientation;
    UISwitch *swhNegativeSeries;
    UILabel *lblNegative;
    chartTypes currentChartType;
    NSMutableArray *dataItmsSeries0;
    NSMutableArray *dataItmsSeries1;
    NSMutableArray *dataItmsSeries2;
}
- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;

@end

@implementation fpOutput

- (void)viewDidLoad
{
    [super viewDidLoad];
    [swhOrientation setOn:YES];
    // Specify chart type
    currentChartType = point;
    // Define Chart Layout
    [self defineChart];
    
    // Run Chart
    [chrt DataBind];
    UILabel *lblHorizontal = [[UILabel alloc] initWithFrame:CGRectMake(swhOrientation.frame.origin.x - COEFF_PAD * 34, swhOrientation.frame.origin.y - 2, COEFF_PAD * 100, COEFF_PAD * 20)];
    [lblHorizontal setFont:[UIFont fontWithName:@"Georgia" size:COEFF_PAD * 7]];
    lblHorizontal.text = @"Horizontal";
    [self.view addSubview:lblHorizontal];
    UILabel *lblVertical = [[UILabel alloc] initWithFrame:CGRectMake(swhOrientation.frame.origin.x + swhOrientation.frame.size.width + 2, swhOrientation.frame.origin.y - 2, COEFF_PAD * 100, COEFF_PAD * 20)];
    [lblVertical setFont:[UIFont fontWithName:@"Georgia" size:COEFF_PAD * 7]];
    lblVertical.text = @"Vertical";
    [self.view addSubview:lblVertical];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)homeBtnClicked:(id)sender
{
//    NSArray *viewControllers = [[self navigationController] viewControllers];
//    for( int i=0;i<[viewControllers count];i++)
//    {
//        id obj=[viewControllers objectAtIndex:i];
//        if([obj isKindOfClass:[dashboard class]])
//        {
//            [[self navigationController] popToViewController:obj animated:YES];
//            return;
//        }
//    }
}

- (IBAction)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutBtnClicked:(id)sender
{
}

- (IBAction)notificationBtnClicked:(id)sender
{
}

// Define Chart Layout
- (void)defineChart
{
    [chrt removeFromSuperview];
    
    // Create UIChart object
  //  chrt = [[UIChart alloc] initWithFrame:CGRectMake(COEFF_PAD * 10,  COEFF_PAD * 40, self.view.frame.size.width - COEFF_PAD * 40, self.view.frame.size.height - COEFF_PAD * 190)];
    chrt = [[UIChart alloc] initWithFrame:CGRectMake(50, 20, 950,459)];

    chrt.delegate = self; // set UIChart's delegate to self (otherwise events will not work)
    
    // Add UIChart object into app's main view layout
    [graphView addSubview:chrt];
    chrt.chartType = currentChartType;
    
    // Define chart's colors
    chrt.backgroundColor = [UIColor clearColor];
   // chrt.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:19.0/255.0 blue:30.0/255.0 alpha:1.0];

    chrt.foregroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:1 alpha:1];
    //chrt.orientation = swhOrientation.isOn ? vertical : horizontal;
    chrt.orientation =  vertical;
    
    // Define chart plot area
    chrt.plotArea.backgroundColor = [UIColor clearColor];
    //chrt.plotArea.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:19.0/255.0 blue:30.0/255.0 alpha:1.0];
    // Define data sources for chart items
    [self dataItemsSeries];
    
    // Draw all kinds of Chart Types
 if (currentChartType == point)
 {
        lblSampleTitle.text = @"Point Chart";
        
        // Define chart's Layout style
        //chrt.layoutStyle = layoutStyleGradient;
        // Define chart's gradient
        chrt.gradientStyle = gradientStyleRadial;
        chrt.gradientRadius = 200;
        chrt.gradientColorTop = [UIColor colorWithRed:0.1 green:0.8 blue:0.1 alpha:0.4];
        chrt.gradientColorTopExtra = [UIColor clearColor];
        chrt.gradientColorBottom = [UIColor clearColor];
        chrt.gradientColorBottomExtra = [UIColor colorWithRed:0.1 green:0.1 blue:0.8 alpha:0.4];
        chrt.gradientDirection = gradientDirectionHorizontal;
     
        // Assign chart's Title
//        chrt.chartTitle.text = @"Prevalence of 3 types of apples across Continents";
//        [chrt.chartTitle setFont:[UIFont fontWithName:@"Georgia" size:COEFF_PAD * 13]];
//        [chrt.chartTitle setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.8 alpha:0.1]];
//        [chrt.chartTitle setTextColor:[UIColor whiteColor]];
//        chrt.chartTitle.frame = CGRectMake(COEFF_PAD * 5, COEFF_PAD * 5, COEFF_PAD * 310, COEFF_PAD * 18);
     
        // Add marked region into chart plot area
        markedRegion *markedRgn = [[markedRegion alloc] init];
        markedRgn.yTop = .5;
        markedRgn.yBottom = .3;
        markedRgn.Title.text = @"Marked Area";
        markedRgn.Title.textColor = [UIColor yellowColor];
        markedRgn.Title.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 8];
        // Adjust marked region location
        markedRgn.titleVerticalLocation = verticalLocationTop;
        markedRgn.titleHorizontalLocation = horizontalLocationMid;
       // [chrt.markedRegions addObject:markedRgn];
        
        // Set X axis title
        chrt.xAxisTitleLabel.text = @"Continents";
        chrt.xAxisTitleLabel.textColor = [UIColor purpleColor];
        chrt.xAxisTitleLabel.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 8];
        chrt.xAxisTitleHorizontalLocation = horizontalLocationMid;
        // X axis labels
        chrt.xAxisLinesHidden = NO;
    
        chrt.xAxisLabelsHidden = NO;
        chrt.xAxisLabelsFont = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 6];
        chrt.xAxisLabelsTextColor = [UIColor whiteColor];
     
        chrt.yAxisTitleLabel.text = @"Marked Area";
        chrt.yAxisTitleVerticalLocation = verticalLocationMid;
     
        // Y axis labels
        chrt.yAxisLinesHidden = NO;
        chrt.yAxisLabelsFont = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 6];
        chrt.yAxisLabelsTextColor = [UIColor whiteColor];
        
        // Draw Legend Zone
        chrt.legendZone.layer.borderColor = [UIColor yellowColor].CGColor;
        chrt.legendZone.layer.borderWidth = COEFF_PAD * 0.5;
        chrt.legendsInterpositions = horizontal;
        chrt.legendZoneHorizontalLocation = horizontalLocationMid;
        chrt.legendZoneVerticalLocation = verticalLocationBottom;
     
        // Create legend items to add into the legend zone
        legend *lgd = [[legend alloc] init];
        lgd.legendLabel.text = @"Rejuvenating Apple";
        lgd.legendLabel.textColor = [UIColor whiteColor];
        lgd.legendLabel.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 7];
        lgd.legendBulletType = legendBulletTypeTriangle;
        lgd.legendBulletWidth = COEFF_PAD * 12;
        lgd.legendBulletFillColor = [UIColor whiteColor];
        lgd.legendBulletStrokeLineColor = [UIColor redColor];
        lgd.legendBulletStrokeLineWidth = COEFF_PAD * 2;
        lgd.legendMargin = COEFF_PAD * 3;
        //[chrt.legends addObject:lgd];
        lgd = [[legend alloc] init];
        lgd.legendLabel.text = @"Apple of Discord";
        lgd.legendLabel.textColor = [UIColor whiteColor];
        lgd.legendLabel.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 7];
        lgd.legendBulletType = legendBulletTypeDot;
        lgd.legendBulletFillColor = [UIColor redColor];
        lgd.legendBulletWidth = COEFF_PAD * 12;
        lgd.legendMargin = COEFF_PAD * 3;
        //[chrt.legends addObject:lgd];
        lgd = [[legend alloc] init];
        lgd.legendLabel.text = @"Hesperides Apple";
        lgd.legendLabel.textColor = [UIColor whiteColor];
        lgd.legendLabel.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 7];
        lgd.legendBulletType = legendBulletTypeRect;
        lgd.legendBulletFillColor = [UIColor blueColor];
        lgd.legendBulletWidth = COEFF_PAD * 12;
        lgd.legendMargin = COEFF_PAD * 3;
       // [chrt.legends addObject:lgd];
        
        // Define chart series
        ChartSeries *srs0 = [[ChartSeries alloc] init];
        ChartSeries *srs1 = [[ChartSeries alloc] init];
        ChartSeries *srs2 = [[ChartSeries alloc] init];
        
        // Fill out chart items of 1st series
        // Define the series' line shape
        srs0.shape.lineWidth = COEFF_PAD * .3;
        for (NSMutableArray *itm in dataItmsSeries0)
        {
            NSLog(@"ITEM DATA: %@",itm);
            ChartItem *chIt = [[ChartItem alloc] init];
            chIt.value = [[itm objectAtIndex:1] floatValue];
            chIt.Title.text = [itm objectAtIndex:2];
            chIt.Title.textColor = [UIColor whiteColor];
            chIt.Title.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 6];
            chIt.layer.borderColor = [UIColor whiteColor].CGColor;
            chIt.layer.borderWidth = COEFF_PAD * 0.3;
            chIt.titleVerticalLocation = verticalLocationBottom-2.5;
            chIt.titleHorizontalLocation = horizontalLocationMid;
            chIt.pointType = pointTypeDot;
            chIt.pointWidth = COEFF_PAD * 9;
            chIt.pointFillColor = [UIColor whiteColor];
            chIt.pointStrokeLineWidth = COEFF_PAD * .2;
            chIt.pointStrokeLineColor = [UIColor redColor];
            chIt.layoutStyle = layoutStyleFlat;
            // X axis label text
            
            chIt.xAxisLabel.text = [itm objectAtIndex:0];
            // Add chart item into series
            [srs0.Items addObject:chIt];
        }
        
        // Fill out chart items of 2nd series
        // Define the series' line shape
        srs1.shape.lineWidth = COEFF_PAD * 3;
        srs1.shape.strokeColor = [UIColor redColor].CGColor;
        // Define line shadow
        srs1.shape.shadowColor = [UIColor blackColor].CGColor;
        srs1.shape.shadowOpacity = .9;
        srs1.shape.shadowOffset = CGSizeMake(COEFF_PAD * 10, COEFF_PAD * 10);
        srs1.shape.shadowRadius = 10;
        srs1.shape.shadowPath = srs0.shape.path;
        for (NSMutableArray *itm in dataItmsSeries0)
        {
            ChartItem *chIt = [[ChartItem alloc] init];
            chIt.value = [[itm objectAtIndex:1] floatValue];
            NSLog(@"DATA: %@",[itm objectAtIndex:2]);
            chIt.Title.text = [itm objectAtIndex:2];
            chIt.Title.textColor = [UIColor blackColor];
            chIt.Title.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 6];
            chIt.titleVerticalLocation = verticalLocationTop;
            chIt.titleHorizontalLocation = horizontalLocationMid;
            chIt.pointWidth = 0;
            chIt.pointType = pointTypeDot;
            chIt.pointWidth = COEFF_PAD * 9;
            chIt.pointFillColor = [UIColor redColor];
            chIt.layoutStyle = layoutStyleFlat;
            // Add chart item into series
            [srs1.Items addObject:chIt];
        }
        
        // Fill out chart items of 3rd series
        // Define the series' line shape
        srs2.shape.lineWidth = COEFF_PAD * 3;
        srs2.shape.strokeColor = [UIColor blueColor].CGColor;
        // Define line shadow
        srs2.shape.shadowColor = [UIColor blackColor].CGColor;
        srs2.shape.shadowOpacity = .9;
        srs2.shape.shadowOffset = CGSizeMake(COEFF_PAD * 10, COEFF_PAD * 10);
        srs2.shape.shadowRadius = 10;
        srs2.shape.shadowPath = srs0.shape.path;
        for (NSMutableArray *itm in dataItmsSeries2)
        {
            ChartItem *chIt = [[ChartItem alloc] init];
            chIt.value = [[itm objectAtIndex:1] floatValue] * (swhNegativeSeries.on ? -1 : 1);
            chIt.Title.text = [NSString stringWithFormat:@"%.2f", chIt.value];
            chIt.Title.textColor = [UIColor blueColor];
            chIt.Title.font = [UIFont fontWithName:@"Georgia" size:COEFF_PAD * 6];
            chIt.titleVerticalLocation = verticalLocationTop;
            chIt.titleHorizontalLocation = horizontalLocationMid;
            chIt.pointType = pointTypeRect;
            chIt.pointWidth = COEFF_PAD * 9;
            chIt.pointFillColor = [UIColor blueColor];
            chIt.layoutStyle = layoutStyleFlat;
            // Add chart item into series
            [srs2.Items addObject:chIt];
        }
        // Add series into chart
        [chrt.series addObject:srs0];
       // [chrt.series addObject:srs1];
       //[chrt.series addObject:srs2];
    }
}

// Define data source for chart items in 3 Series
- (void)dataItemsSeries
{
    // Data source for 1st Series
    dataItmsSeries0 = [[NSMutableArray alloc] init];
    NSMutableArray *itm = [[NSMutableArray alloc] init];
    [itm addObject:@"10"];
    [itm addObject:@"40"];
    [itm addObject:@"Ambrosia"];
    [dataItmsSeries0 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"30"];
    [itm addObject:@"50"];
    [itm addObject:@"Pink Lady"];
    [dataItmsSeries0 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"65"];
    [itm addObject:@"45"];
    [itm addObject:@"McIntosh"];
    [dataItmsSeries0 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"30"];
    [itm addObject:@"35"];
    [itm addObject:@"Fuji"];
    [dataItmsSeries0 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"68"];
    [itm addObject:@"70"];
    [itm addObject:@"Gala"];
    [dataItmsSeries0 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"78"];
    [itm addObject:@"60"];
    [itm addObject:@"Golden Delicious"];
    [dataItmsSeries0 addObject:itm];
    
    // Data source for 2nd Series
    dataItmsSeries1 = [[NSMutableArray alloc] init];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"10"];
    [itm addObject:@"60"];
    [dataItmsSeries1 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"20"];
    [itm addObject:@"50"];
    [dataItmsSeries1 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"30"];
    [itm addObject:@"40"];
    [dataItmsSeries1 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"40"];
    [itm addObject:@"30"];
    [dataItmsSeries1 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"50"];
    [itm addObject:@"20"];
    [dataItmsSeries1 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"60"];
    [itm addObject:@"10"];
    [dataItmsSeries1 addObject:itm];
    
    // Data source for 3rd Series
    dataItmsSeries2 = [[NSMutableArray alloc] init];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"RAW"];
    [itm addObject:@".80"];
    [dataItmsSeries2 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"PIES"];
    [itm addObject:@".7"];
    [dataItmsSeries2 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"BAKING"];
    [itm addObject:@".55"];
    [dataItmsSeries2 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"SAUCE"];
    [itm addObject:@".6"];
    [dataItmsSeries2 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"JUICE"];
    [itm addObject:@".9"];
    [dataItmsSeries2 addObject:itm];
    itm = [[NSMutableArray alloc] init];
    [itm addObject:@"WINE"];
    [itm addObject:@".8"];
    [dataItmsSeries2 addObject:itm];
}

// rotate iPhone/iPad
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duratio
{
    // Define main screen width and height
    CGFloat mainWidth = ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) ? self.view.frame.size.height : self.view.frame.size.width);
    CGFloat mainHeight = ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) ? self.view.frame.size.width : self.view.frame.size.height);
    btnBackward.frame = CGRectMake(0, chrt.frame.origin.y + chrt.frame.size.height / 2, COEFF_PAD * 15, COEFF_PAD * 15);
    btnForward.frame = CGRectMake(chrt.frame.origin.x + chrt.frame.size.width - 5, chrt.frame.origin.y + chrt.frame.size.height / 2, COEFF_PAD * 15, COEFF_PAD * 15);
}

// Event-handling procedure that fires when the chart is tapped
- (void)chartTapped:(UIChart *)chart
{
    // Show a message
    [self msgbox:@"The chartTapped event has been implemented." title:@"Chart is Tapped!"];
    return;
}

// Show message box
- (void)msgbox:(NSString *)msg title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}


@end
