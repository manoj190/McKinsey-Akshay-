//
//  fpOutput2.h
//  mckinsey
//
//  Created by Mac on 11/05/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleBarChart.h"
#import "fpUsingMdOutput.h"
#import "ALIVE_2_0_Admin-Swift.h"

@interface fpOutput2 : UIViewController<SimpleBarChartDataSource, SimpleBarChartDelegate,MFMailComposeViewControllerDelegate>
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
@property (strong, nonatomic) NSString *surveyName;

@end
