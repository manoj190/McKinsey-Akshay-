//
//  maxDiffGraph.h
//  mckinsey
//
//  Created by Apple on 10/8/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleBarChart.h"
#import "fpUsingMdOutput.h"
#import "ALIVE_2_0_Admin-Swift.h"

@interface maxDiffGraph : UIViewController<SimpleBarChartDataSource, SimpleBarChartDelegate,MFMailComposeViewControllerDelegate>
{
    NSMutableArray *_values;
    NSMutableArray * upperValue, *lowerValue,*barValues;
    
    SimpleBarChart *_chart;
    
    NSArray *_barColors;
    NSInteger _currentBarColor;
}
@property (strong, nonatomic) NSMutableArray *surveyDetailArr;
@property (strong, nonatomic) NSString *surveyId;
@property (strong, nonatomic) fpUsingMdOutput *fpUsingMdOutputObj;

@end
