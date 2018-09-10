//
//  maxDiffOutput.h
//  mckinsey
//
//  Created by Mac on 26/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleBarChart.h"
#import <MessageUI/MessageUI.h>

@interface maxDiffOutput : UIViewController <SimpleBarChartDataSource, SimpleBarChartDelegate,MFMailComposeViewControllerDelegate>
{
    NSMutableArray *_values;
    NSMutableArray * upperValue, *lowerValue,*barValues;
    
    SimpleBarChart *_chart;
    
    NSArray *_barColors;
    NSInteger _currentBarColor;
}
@property (strong,nonatomic) NSString *titleForNavBar;
@property (strong, nonatomic) NSMutableArray *surveyDetailArr;
@property (strong, nonatomic) NSString *surveyId;
@property (strong, nonatomic) NSString *surveyName;
@end
