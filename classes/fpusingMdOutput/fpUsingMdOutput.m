//
//  fpUsingMdOutput.m
//  mckinsey
//
//  Created by Mac on 26/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "fpUsingMdOutput.h"
#import "dashboard.h"
#import "loginView.h"
#import "NSMutableArray+TTMutableArray.h"
#import "fpUsingMdCell.h"
#import "addFpUsingMdCell.h"
#import "constant.h"
#import "loadingPage.h"
#import "APIManager.h"

@interface fpUsingMdOutput ()
{
    NIDropDown *dropDown;
    loadingPage *loadingPageObj;
    IBOutlet UITableView *scenarioBldTable;
    IBOutlet UILabel *cumulativeValuePointLbl;
    IBOutlet UIImageView *pointGraphBgView;
    IBOutlet UILabel *netValueLbl;
    IBOutlet UILabel *netCostLbl;
    IBOutlet UILabel *cumulativeCostLbl;
    
    NSMutableArray *levelArr;
    UITextField *currentTxtField;
    NSMutableArray *rowCountArr;
    UIPickerView *pickerView;
    UIToolbar *toolBar;
    NSMutableArray *fromLevelArr;
    NSMutableArray *toLevelArr;
    NSMutableArray *fromValueArr;
    NSMutableArray *toValueArr;
    NSMutableArray *fromCostArr;
    NSMutableArray *toCostArr;
    NSMutableArray *valueArr;
    NSMutableArray *costArr;
    NSInteger cost,value;
    NSInteger pickerIndexPath;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    NSMutableArray *netCostArray,*netValueArray;

}

- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)viewGraphBtnClicked:(id)sender;
- (IBAction)exportBtnClicked:(id)sender;
- (IBAction)calculateNetChangeBtnClicked:(id)sender;
- (IBAction)expandBtnClicked:(id)sender;

@end

@implementation fpUsingMdOutput
@synthesize surveyDetailArr,surveyId,maxDiffOutputObj,currencyType;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
    [self loadPointGraph:surveyDetailArr  :CGRectMake(50.0, 100.0, 900.0,400.0)];

    NSLog(@"arr data : %@",surveyDetailArr);
    [cumulativeValuePointLbl setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];

    // add a toolbar with Done button
    cost=0;
    value=0;
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 1024, 40)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerViewDoneBtnClicked:)];
    [toolBar setItems:[NSArray arrayWithObjects:doneButton, nil]];
    pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
}

-(void)setUI
{
    netCostArray    = [[NSMutableArray alloc]initWithObjects:@"", nil];
    netValueArray   = [[NSMutableArray alloc]initWithObjects:@"", nil];
    fromValueArr    = [[NSMutableArray alloc]init];
    toValueArr      = [[NSMutableArray alloc]init];
    valueArr        = [[NSMutableArray alloc]init];
    costArr         = [[NSMutableArray alloc]init];
    rowCountArr     = [[NSMutableArray alloc]initWithObjects:@"L",@"A", nil];
    fromLevelArr    = [[NSMutableArray alloc]initWithObjects:@"", nil];
    toLevelArr      = [[NSMutableArray alloc]initWithObjects:@"", nil];
    toValueArr      = [[NSMutableArray alloc]initWithObjects:@"", nil];
    fromValueArr    = [[NSMutableArray alloc]initWithObjects:@"", nil];
    toCostArr       = [[NSMutableArray alloc]initWithObjects:@"", nil];
    fromCostArr     = [[NSMutableArray alloc]initWithObjects:@"", nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_chart reloadData];
}

- (void)loadPointGraph:(NSMutableArray *)graphDetailArr :(CGRect )greaphFrame
{
    //Currency Type
    cumulativeCostLbl.text = [NSString stringWithFormat:@"Cumulative Cost(%@)",currencyType];
    _values    = [[NSMutableArray alloc]init];
    barValues  = [[NSMutableArray alloc]init];
    upperValue = [[NSMutableArray alloc]init];
    lowerValue = [[NSMutableArray alloc]init];
    levelArr   = [[NSMutableArray alloc]init];
    _barColors = [[NSMutableArray alloc]init];
    NSInteger b = 0;
    NSInteger a = 0;
    NSInteger valueOfBar = 0;
    NSInteger maxValue=0;
    
    for (int i =0; i<graphDetailArr.count; i++)
    {
        if (maxValue < [[[graphDetailArr objectAtIndex:i] valueForKey:@"INCREMENTAL_COST"] integerValue])
        {
            maxValue = [[[graphDetailArr objectAtIndex:i] valueForKey:@"INCREMENTAL_COST"] integerValue];
        }
        
    }
    maxValue = maxValue + (maxValue%10);
    NSInteger avgXvalue= maxValue/graphDetailArr.count;
    b = 0;
    a = 0;
    
    for (int i =0; i<graphDetailArr.count; i++)
    {
        valueOfBar = valueOfBar + avgXvalue;
        
        [_values addObject:[NSString stringWithFormat:@"%ld",(long)valueOfBar]];
        [barValues addObject:[[graphDetailArr objectAtIndex:i]valueForKey:@"LEVEL_NAME"]];
        [levelArr addObject:[[graphDetailArr objectAtIndex:i]valueForKey:@"LEVEL_NAME"]];
        
        [lowerValue addObject:[NSString stringWithFormat:@"%ld",(long)[[[graphDetailArr objectAtIndex:i] valueForKey:@"INCREMENTAL_COST"] floatValue]]];
        [upperValue addObject:[NSString stringWithFormat:@"%ld",(long)[[[graphDetailArr objectAtIndex:i] valueForKey:@"INCREMENTAL_VALUE"] floatValue]]];
        [_barColors addObject:[UIColor whiteColor]];
    }
    
    _currentBarColor				= 0;
    CGRect chartFrame				= greaphFrame;
    _chart							= [[SimpleBarChart alloc] initWithFrame:chartFrame];
    _chart.graphType                = @"POINT GRAPH";
    _chart.delegate					= self;
    _chart.dataSource				= self;
    _chart.barShadowOffset			= CGSizeMake(2.0, 1.0);
    _chart.animationDuration		= 1.0;
    _chart.barShadowColor			= [UIColor grayColor];
    _chart.barShadowAlpha			= 0.5;
    _chart.barShadowRadius			= 1.0;
    _chart.barWidth					= 18.0;
    _chart.xLabelType				= SimpleBarChartXLabelTypeVerticle;
    _chart.incrementValue			= 10;
    _chart.barTextType				= SimpleBarChartBarTextTypeTop;
    _chart.barTextColor				= [UIColor whiteColor];
    _chart.gridColor				= [UIColor grayColor];
    
    [self.view addSubview:_chart];
    //[pointGraphBgView addSubview:_chart];
}

#pragma mark SimpleBarChartDataSource

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart
{
    return _values.count;
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForPoints:(NSUInteger)index
{
    return [_barColors objectAtIndex:index];
}

- (NSString *)barChart:(SimpleBarChart *)barChart upperLimit:(NSUInteger)index
{
    return [upperValue objectAtIndex:index] ;
}

- (NSString *)barChart:(SimpleBarChart *)barChart lowerLimit:(NSUInteger)index
{
    return [lowerValue objectAtIndex:index];
}

- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
    return [[_values objectAtIndex:index] floatValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
    return [barValues objectAtIndex:index] ;
}

- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index
{
    return [_values objectAtIndex:index] ;
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    return [_barColors objectAtIndex:_currentBarColor];
}

- (NSString *)barChart:(SimpleBarChart *)barChart setBarValues:(NSUInteger)index;
{
    return [barValues objectAtIndex:index];
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

- (IBAction)logoutBtnClicked:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"data = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"]);

    NSArray *viewControllers = [[self navigationController] viewControllers];
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return rowCountArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([[rowCountArr objectAtIndex:indexPath.row]isEqualToString:@"L"])
    {
        NSString *cellIdentifier = @"cell";
        fpUsingMdCell *cell = [scenarioBldTable dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"fpUsingMdCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.fromLevel.text = [fromLevelArr objectAtIndex:indexPath.row];
        cell.toLevel.text = [toLevelArr objectAtIndex:indexPath.row];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.fromLevel.inputView = pickerView;
        cell.toLevel.inputView = pickerView;
        cell.fromLevel.inputAccessoryView = toolBar;
        cell.toLevel.inputAccessoryView = toolBar;
        
        if (cell.fromLevel.text.length==0 || cell.toLevel.text.length==0)
        {
            cell.costLbl.text=@"";
            cell.valueLbl.text=@"";
        }
        else
        {
            if ([[fromCostArr objectAtIndex:indexPath.row] floatValue]<[[toCostArr objectAtIndex:indexPath.row] floatValue])
            {
                float costChnage = [[toCostArr objectAtIndex:indexPath.row] floatValue]-[[fromCostArr objectAtIndex:indexPath.row] floatValue];
                cell.costLbl.text = [NSString stringWithFormat:@"%.02f%@",(costChnage*100 /[[fromCostArr objectAtIndex:indexPath.row] floatValue]),@"%"];
                
//                cell.costLbl.text= [NSString stringWithFormat:@"%ld",([[toCostArr objectAtIndex:indexPath.row] integerValue]-[[fromCostArr objectAtIndex:indexPath.row] integerValue])];
                [cell.costImg setImage:[UIImage imageNamed:@"redUpArrow.png"]];
                
                cell.valueLbl.text= [NSString stringWithFormat:@"%.02f%@",(([[toValueArr objectAtIndex:indexPath.row] floatValue]-[[fromValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[toValueArr objectAtIndex:indexPath.row] floatValue],@"%"];
                
                [netCostArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%.02f",([[toCostArr objectAtIndex:indexPath.row] floatValue]-[[fromCostArr objectAtIndex:indexPath.row] floatValue])]];
                [netValueArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%.02f",(([[toValueArr objectAtIndex:indexPath.row] floatValue]-[[fromValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[toValueArr objectAtIndex:indexPath.row] floatValue]]];
            }
            else
            {
                NSInteger costChnage = [[fromCostArr objectAtIndex:indexPath.row] floatValue]-[[toCostArr objectAtIndex:indexPath.row] floatValue];
                
                cell.costLbl.text = [NSString stringWithFormat:@"%.02f%@",(costChnage*100 /[[fromCostArr objectAtIndex:indexPath.row] floatValue]),@"%"];
                
//                cell.costLbl.text= [NSString stringWithFormat:@"%ld",([[fromCostArr objectAtIndex:indexPath.row] integerValue]-[[toCostArr objectAtIndex:indexPath.row] integerValue])];
                
                cell.valueLbl.text= [NSString stringWithFormat:@"%.02f%@",(([[fromValueArr objectAtIndex:indexPath.row] floatValue]-[[toValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[fromValueArr objectAtIndex:indexPath.row] floatValue],@"%"];
                [cell.costImg setImage:[UIImage imageNamed:@"greenUpArrow.png"]];
                
                [netCostArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%.02f",([[fromCostArr objectAtIndex:indexPath.row] floatValue]-[[toCostArr objectAtIndex:indexPath.row] floatValue])]];
                [netValueArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%.02f",(([[fromValueArr objectAtIndex:indexPath.row] floatValue]-[[toValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[fromValueArr objectAtIndex:indexPath.row] floatValue]]];
            }
            
            if (((([[fromValueArr objectAtIndex:indexPath.row] floatValue]-[[toValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[fromValueArr objectAtIndex:indexPath.row] floatValue]) < 0)
            {
                [cell.valueImg setImage:[UIImage imageNamed:@"greenDownArrow.png"]];
                cell.valueLbl.text= [NSString stringWithFormat:@"%.02f%@",((([[fromValueArr objectAtIndex:indexPath.row] floatValue]-[[toValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[fromValueArr objectAtIndex:indexPath.row] floatValue])*-1,@"%"];
                [netValueArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%.02f",((([[fromValueArr objectAtIndex:indexPath.row] floatValue]-[[toValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[fromValueArr objectAtIndex:indexPath.row] floatValue])*-1]];
            }
            else
            {
                [cell.valueImg setImage:[UIImage imageNamed:@"redDownArrow.png"]];
                cell.valueLbl.text= [NSString stringWithFormat:@"%.02f%@",(([[fromValueArr objectAtIndex:indexPath.row] floatValue]-[[toValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[fromValueArr objectAtIndex:indexPath.row] floatValue],@"%"];
                [netValueArray replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%.02f",(([[fromValueArr objectAtIndex:indexPath.row] floatValue]-[[toValueArr objectAtIndex:indexPath.row] floatValue])*100)/[[fromValueArr objectAtIndex:indexPath.row] floatValue]]];
            }
        }
        return cell;
    }
    else
    {
        NSString *cellIdentifier = @"cell";
        addFpUsingMdCell *cell = [scenarioBldTable dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"addFpUsingMdCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        [cell.addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

-(void)addBtnClicked:(id)sender
{
    [rowCountArr insertObject:@"L" atIndex:rowCountArr.count-1];
    [netCostArray addObject:@""];
    [netValueArray addObject:@""];
    [fromLevelArr addObject:@""];
    [fromValueArr addObject:@""];
    [toLevelArr addObject:@""];
    [toValueArr addObject:@""];
    [toCostArr addObject:@""];
    [fromCostArr addObject:@""];
    [costArr addObject:@""];
    [valueArr addObject:@""];
    [scenarioBldTable reloadData];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return surveyDetailArr.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[surveyDetailArr objectAtIndex:row]valueForKey:@"LEVEL_NAME"];
}

-(void)pickerViewDoneBtnClicked:(UIBarButtonItem *)sender
{
    if (currentTxtField.tag == 101)
    {
        
    }
    else if (currentTxtField.tag == 102)
    {
        
    }
    
    NSLog(@"Picker view index = %ld",(long)[pickerView selectedRowInComponent:0]);
    pickerIndexPath=[pickerView selectedRowInComponent:0];
    NSString *selectedId = [[surveyDetailArr objectAtIndex:[pickerView selectedRowInComponent:0]]valueForKey:@"LEVEL_NAME"];
    currentTxtField.text = selectedId;
    [currentTxtField resignFirstResponder];
}

- (IBAction)notificationBtnClicked:(id)sender
{
    
}

- (IBAction)viewGraphBtnClicked:(id)sender
{
    maxDiffOutputObj = [[maxDiffOutput alloc]initWithNibName:@"maxDiffOutput" bundle:nil];
    maxDiffOutputObj.surveyId = surveyId;
    [self.navigationController pushViewController:maxDiffOutputObj animated:YES];
}

-(NSMutableDictionary *)getDetailsForExcelSheet
{
    NSMutableArray *dataArray2 = [[NSMutableArray alloc]init];
    for (int i =0; i<surveyDetailArr.count; i++)
    {
        NSMutableDictionary *dataDict2 = [[NSMutableDictionary alloc]init];
        [dataDict2 setObject:[[surveyDetailArr objectAtIndex:i] valueForKey:@"INCREMENTAL_COST"] forKey:@"COST"];
        [dataDict2 setObject:[[surveyDetailArr objectAtIndex:i] valueForKey:@"INCREMENTAL_VALUE"] forKey:@"VALUE"];
        [dataArray2 addObject:dataDict2];
    }
    NSMutableDictionary *dataDict3 = [[NSMutableDictionary alloc]init];
    [dataDict3 setObject:dataArray2 forKey:@"ARR"];
    [dataDict3 setObject:@"Test" forKey:@"SURVEY_NAME"];
    
    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
    [finalDict setObject:dataDict3 forKey:@"DATA"];
    
    return finalDict;
}

- (IBAction)exportBtnClicked:(id)sender
{
    [self showLoader:YES];
    [self callWebServiceToExportExcelSheet];
}

- (IBAction)calculateNetChangeBtnClicked:(id)sender
{
    NSInteger netValue = 0,netCost=0;
    for (int i = 0; i<netValueArray.count; i++)
    {
        netValue = netValue + [[netValueArray objectAtIndex:i ] integerValue];
        netCost = netCost + [[netCostArray objectAtIndex:i ] integerValue];
    }
    
    netCostLbl.text = [NSString stringWithFormat:@"%lu",netCost / netValueArray.count];
    netValueLbl.text = [NSString stringWithFormat:@"%lu",netValue / netValueArray.count];
}

- (IBAction)expandBtnClicked:(id)sender
{
    //[_chart removeFromSuperview];
   // pointGraphBgView.frame = CGRectMake(13, 72, 998, 800);
    [self loadPointGraph:surveyDetailArr :CGRectMake(50.0, 100.0, 900.0,800.0)];
}


-(void)callWebServiceToExportExcelSheet
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//                   {
//                       NSError * err;
//                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:[self getDetailsForExcelSheet] options:0 error:&err];
//                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
//
//                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"GRAPH_EXCEL/GRAPH_EXCEL.php"]]];
//
//                       NSData *requestData = [myString dataUsingEncoding:NSUTF8StringEncoding];
//                       [request setHTTPMethod:@"POST"];
//                       [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//                       [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//                       [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
//                       [request setHTTPBody: requestData];
//
//                       NSURLSession *session = [NSURLSession sharedSession];
//                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
//                                                                                 NSURLResponse *response,
//                                                                                 NSError *error) {
//                           if (data == nil)
//                           {
//                               [self errorResponse:@"Error in login"];
//                           }
//                           else
//                           {
//                               NSString *resSrt = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
//                               [self exportWebserviceResponce:resSrt];
//                           }
//                       }] resume];
//
//                   });
    
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/MCKINSEY/EXPORT_TO_EXCEL/export.php" andParam:_finalSelectedValues withBlock:^(id response, BOOL isSuccess) {
        
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
            //application/pdf  - just changed manoj
            [mc addAttachmentData:data mimeType:@"application/excel" fileName:[[[response objectForKey:@"LINK"] componentsSeparatedByString:@"/"] lastObject]];
            
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            if (![mc isEqual:[NSNull null]]) {
                [self presentViewController:mc animated:YES completion:NULL];
            }
        }
    }];
}

-(void)exportWebserviceResponce:(NSString  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       [self sendMail:result];

                   });
}

-(void)errorResponse:(NSString *)msg
{
    [self showAlertView:@"Alive 2.0" message:msg];
    [self showLoader:NO];

    
}


-(void)sendMail:(NSString *)link
{
    // Email Subject
    NSString *emailTitle = @"Excel Sheet";
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


-(void)rel
{
    dropDown = nil;
}


- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
    [self rel];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTxtField = textField;
    [self animateTextField:currentTxtField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint touchPoint = [textField convertPoint:CGPointZero toView:scenarioBldTable];
    NSIndexPath *clickedButtonIndexPath = [scenarioBldTable indexPathForRowAtPoint:touchPoint];
    if (textField.tag==101)
    {
        //Calculation on cumulative value n cumulative cost
        [fromLevelArr replaceObjectAtIndex:clickedButtonIndexPath.row withObject:textField.text];
        [fromCostArr replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[[surveyDetailArr objectAtIndex:pickerIndexPath]valueForKey:@"INCREMENTAL_COST"]];
        [fromValueArr replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[[surveyDetailArr objectAtIndex:pickerIndexPath]valueForKey:@"INCREMENTAL_VALUE"]];

    }
    if (textField.tag==102)
    {
        //Calculation on cumulative value n cumulative cost
        [toLevelArr replaceObjectAtIndex:clickedButtonIndexPath.row withObject:textField.text];
        [toValueArr replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[[surveyDetailArr objectAtIndex:pickerIndexPath]valueForKey:@"INCREMENTAL_VALUE"]];
        [toCostArr replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[[surveyDetailArr objectAtIndex:pickerIndexPath]valueForKey:@"INCREMENTAL_COST"]];
        
    }
    [self animateTextField:currentTxtField up:NO];
    [scenarioBldTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    int movementDistance = 0;
    
    if (textField.tag == 101 || textField.tag == 102)
    {
         movementDistance = -280;
    }
        const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
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
