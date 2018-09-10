//
//  fpUsingMdOutput.h
//  mckinsey
//
//  Created by Mac on 26/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleBarChart.h"
#import "NIDropDown.h"
#import "maxDiffOutput.h"
#import <MessageUI/MessageUI.h>

@interface fpUsingMdOutput : UIViewController<SimpleBarChartDataSource, SimpleBarChartDelegate,NIDropDownDelegate,UIPickerViewDelegate,UIPickerViewDataSource,MFMailComposeViewControllerDelegate>
{
    NSMutableArray *_values,*_xAxisValues;
    NSMutableArray * upperValue, *lowerValue,*barValues,*_barColors;
    
    SimpleBarChart *_chart;
   // NSArray *_barColors;
    NSInteger _currentBarColor;
}
@property (strong, nonatomic)NSMutableArray *surveyDetailArr;
@property (strong, nonatomic) NSString *currencyType;
@property (strong, nonatomic) NSString *surveyId;
@property (strong, nonatomic) maxDiffOutput *maxDiffOutputObj;

@property (strong, nonatomic) NSDictionary *finalSelectedValues;

@end
