//
//  previewPage.m
//  mckinsey
//
//  Created by Mac on 27/08/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "previewPage.h"
#import "dashboard.h"
#import "loginView.h"
#import "previewCell.h"
#import "constant.h"
#import "loadingPage.h"
#import "Reachability.h"
#import "cardCell.h"
#import "surveyCell.h"
#import "notifications.h"


@interface previewPage ()
{
    loadingPage *loadingPageObj;

    IBOutlet UITableView *previewTable;
    IBOutlet UITextField *questionLbl;
    IBOutlet UIImageView *badgeCountImg;
    IBOutlet UILabel *badgeCountLbl;
    NSMutableDictionary *infoDictionary;
    NSMutableArray *infoArray;
    NSMutableArray *imageDataArr;
    IBOutlet UICollectionView *cardCollectionView;
    NSInteger tableIndex;
}

- (IBAction)homeBtnClicked:(id)sender;
- (IBAction)backBtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)notificationBtnClicked:(id)sender;
- (IBAction)exportBtnClicked:(id)sender;

@end

@implementation previewPage
@synthesize surveyName,surveyId,levelsArray,levelImgsArray,range;

- (void)viewDidLoad
{
    [super viewDidLoad];
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    [cardCollectionView registerNib:[UINib nibWithNibName:@"cardCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_PUSHED"]isEqualToString:@"NO"])
    {
        infoArray = [[NSUserDefaults standardUserDefaults]valueForKey:@"LEVEL_ARR"];
        imageDataArr = [[NSUserDefaults standardUserDefaults]valueForKey:@"IMAGE_ARR"];
        [cardCollectionView reloadData];
    }
    else
    {
        [self showLoader:YES];
        [self MckinseyJsonWebservice];
    }
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"SURVEY_PUSHED"];
    
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

- (IBAction)notificationBtnClicked:(id)sender
{
    badgeCountImg.hidden = YES;
    badgeCountLbl.hidden = YES;
    [self setBadgeNumber];
    notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
    [self.navigationController pushViewController:notificationViewObj animated:YES];

}

-(void)MckinseyJsonWebservice
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       
                       //New
                       //NSString *surveyname =[[[NSUserDefaults standardUserDefaults] valueForKey:@"SURVEY_NAME"] stringByReplacingOccurrencesOfString:@" " withString:@""];
                       
                       NSMutableDictionary *finalDict1 = [[NSMutableDictionary alloc]init];
                       [finalDict1 setObject:[NSString stringWithFormat:@"http://103.224.247.79/mckinsey/PHP/_IPHONE/MCKINSEY/SAVE_SURVEY/%@_%@_LEVEL.csv",surveyName,[[NSUserDefaults standardUserDefaults] valueForKey:@"ADMIN_ID"]] forKey:@"Data source URL"];
                       [finalDict1 setObject:[NSString stringWithFormat:@"http://103.224.247.79/mckinsey/PHP/_IPHONE/MCKINSEY/SAVE_SURVEY/%@_%@_DATA.csv",surveyName,[[NSUserDefaults standardUserDefaults] valueForKey:@"ADMIN_ID"]] forKey:@"Data source URL1"];
                       
//                       //OLD
//                       NSMutableDictionary *finalDict1 = [[NSMutableDictionary alloc]init];
//                       [finalDict1 setObject:@"http://hardcastlegis.co.in/_IPHONE/MCKINSEY/DATACSV.csv" forKey:@"Data source URL1"];
//                       [finalDict1 setObject:@"http://hardcastlegis.co.in/_IPHONE/MCKINSEY/final_data.csv" forKey:@"Data source URL"];
                       
                       
//                       //OLD
//                       NSMutableDictionary *finalDict1 = [[NSMutableDictionary alloc]init];
//                       [finalDict1 setObject:@"http://hardcastlegis.co.in/_IPHONE/MCKINSEY/NO_OF_CARDS.csv" forKey:@"Data source URL1"];
//                       [finalDict1 setObject:@"http://hardcastlegis.co.in/_IPHONE/MCKINSEY/OPTION_DATA.csv" forKey:@"Data source URL"];
                       
                       NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
                       [finalDict setObject:finalDict1 forKey:@"GlobalParameters"];
                       
                       NSLog(@"Final Dict = %@",finalDict);
                       
                       NSError * err;
                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:finalDict options:0 error:&err];
                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                       
                       NSString * URLstr;
                       if (range == 3)
                       {
//                           URLstr=@"https://ussouthcentral.services.azureml.net/workspaces/aca19128d0a54309a75f5be4052c34a9/services/aee04e32d13d435d8d53b518b8504c5b/execute?api-version=2.0&details=true";
                           
                           URLstr = @"https://ussouthcentral.services.azureml.net/workspaces/aca19128d0a54309a75f5be4052c34a9/services/aee04e32d13d435d8d53b518b8504c5b/execute?api-version=2.0&details=true";
                       }
                       else if (range == 4)
                       {
                           URLstr=@"https://ussouthcentral.services.azureml.net/workspaces/aca19128d0a54309a75f5be4052c34a9/services/a98fd224e6e44331989944b460112171/execute?api-version=2.0&details=true";
                       }
                       else
                       {
//                          URLstr=@"https://ussouthcentral.services.azureml.net/workspaces/aca19128d0a54309a75f5be4052c34a9/services/3b88b582d06f4294a5e0432f34901715/execute?api-version=2.0&details=true";
                           
                           URLstr=@"https://ussouthcentral.services.azureml.net/workspaces/aca19128d0a54309a75f5be4052c34a9/services/72a80928c1564d75a89589c64fe865c3/execute?api-version=2.0&details=true";
                       }
                       
                       NSURL *url = [NSURL URLWithString:URLstr];
                       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                       
                       
                       NSData *requestData = [myString dataUsingEncoding:NSUTF8StringEncoding];
                       [request setHTTPMethod:@"POST"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                       NSString* authStr= @"Bearer ";
                       if (range == 3)
                       {
                           [request addValue:[authStr stringByAppendingString:@"Qn83z7Lq10SixRAYAWEjnwfnuxVTyDR3GQsYj1FehXPXvhGEGLNLVva/ldnodNJ3kSoxKxPQnBsvB84vIoHT8Q=="]
                          forHTTPHeaderField:@"Authorization"];
                       }
                       else if (range == 4)
                       {
                           [request addValue:[authStr stringByAppendingString:@"kPfZ4KCpo30bTFDn57U+T1gTY33bioA7dziEHp5xgLzbHtZmIOdeP6w0uRGZgEazR9/hXnygCI/MqlW7mtsrMw=="]
                          forHTTPHeaderField:@"Authorization"];
                       }
                       else
                       {
                           
                           [request addValue:[authStr stringByAppendingString:@"XUWQv5oMfFOKhwOJwWNXYw7Tfgu4r2hHhil4Clu6CBcoEPhCWaVNgT6qeMtFEt/pRfbhV5Z2jeRxV/1pKNTWbw=="]
                          forHTTPHeaderField:@"Authorization"];
                       }
                       
                       [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
                       [request setHTTPBody: requestData];
                       
                       NSURLResponse *response;
                       
                       NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
                       if (responseData)
                       {
                           NSString *resSrt = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
                           infoDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];

                           infoArray = [[[[infoDictionary valueForKey:@"Results"]valueForKey:@"output1"]valueForKey:@"value"]valueForKey:@"Values"];
                           [self responseResult:infoArray];
                       }
                       else
                       {
                           
                       }
                   });
}

-(void)responseResult:(NSArray  *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if (result.count == 0)
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"Error generating model"];
                           [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"SURVEY_ID"];
                       }
                       else
                       {
                           infoArray = [[NSMutableArray alloc]init];
                           NSMutableArray *firstArr = [[NSMutableArray alloc]initWithArray:[result objectAtIndex:0]];
                           for (int i =0; i<firstArr.count; i++)
                           {
                               NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                               for (int j = 0; j<result.count; j++)
                               {
                                   [tempArr addObject:[[result objectAtIndex:j]objectAtIndex:i]];
                               }
                               [infoArray addObject:tempArr];
                           }
                           
                           imageDataArr = [[NSMutableArray alloc]init];;
                           for (int i = 0; i<infoArray.count; i++)
                           {
                               NSMutableArray *imgArr = [[NSMutableArray alloc]init];
                               
                               NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:[infoArray objectAtIndex:i]];
                               for (int j = 0; j<dataArr.count; j++)
                               {
                                   NSString *str = [dataArr objectAtIndex:j];

                                   for (int a = 0; a<levelsArray.count-1; a++)
                                   {
                                       NSLog(@"Value = %@",[levelsArray objectAtIndex:a]);
                                       if ([[levelsArray objectAtIndex:a]  isEqualToString:str])
                                       {
                                           if ([[levelImgsArray objectAtIndex:a] isKindOfClass:[NSString class]])
                                           {
                                                UIImage *image = [UIImage imageNamed:@"noImgAvailable.png"];
                                                NSData *imageData = UIImagePNGRepresentation(image);                            [imgArr addObject:imageData];
                                           }
                                           else
                                           {
                                               [imgArr addObject:[levelImgsArray objectAtIndex:a]];
                                           }
                                           break;
                                       }
                                   }
                               }
                               [imageDataArr addObject:imgArr];
                           }

                           [cardCollectionView reloadData];
                           [self saveDataToLocal:infoArray :imageDataArr];
                       }
                });
}

-(void)saveDataToLocal:(NSMutableArray *)lArray :(NSMutableArray *)iDataArr
{
    [[NSUserDefaults standardUserDefaults] setObject:lArray forKey:@"LEVEL_ARR"];
    [[NSUserDefaults standardUserDefaults] setObject:iDataArr forKey:@"IMAGE_ARR"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSLog(@"Level array  = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"LEVEL_ARR"]);
}

-(void)testing
{
    NSMutableArray *firstArr = [[NSMutableArray alloc]init];
    NSMutableArray *secondArr = [[NSMutableArray alloc]init];
    NSMutableArray *thirdArr = [[NSMutableArray alloc]init];
    
    firstArr=[[NSMutableArray alloc]initWithObjects:@"1",@"11",@"111",@"1111", nil];
    secondArr=[[NSMutableArray alloc]initWithObjects:@"2",@"22",@"222",@"2222", nil];
    thirdArr=[[NSMutableArray alloc]initWithObjects:@"3",@"33",@"333",@"333", nil];
    infoArray = [[NSMutableArray alloc]initWithObjects:firstArr,secondArr,thirdArr,firstArr,secondArr,thirdArr,firstArr,secondArr,thirdArr,nil];
    if(infoArray.count<6)
    {
        cardCollectionView.layer.masksToBounds=YES;
        cardCollectionView.frame=CGRectMake((self.view.frame.size.width/2-(155* (infoArray.count))/2), cardCollectionView.frame.origin.y , (155* (infoArray.count)+20), cardCollectionView.frame.size.height);
    }
    [cardCollectionView reloadData];

}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass: [UITableViewHeaderFooterView class]])
    {
        UITableViewHeaderFooterView* castView = (UITableViewHeaderFooterView*) view;
        [castView.textLabel setTextColor:[UIColor whiteColor]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (IBAction)pushPreviewMethod:(UIButton *)sender
{
    [self showLoader:YES];
    [self pushData];
}

-(void)pushData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       
                       NSMutableDictionary *questionDict =[[NSMutableDictionary alloc] init];
                       [questionDict setObject:infoArray forKey:@"QUESTION"];
                       NSLog(@"survey id = %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"SURVEY_ID"]);
                       [questionDict setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"SURVEY_ID"] forKey:@"SURVEY_ID"];
                       [questionDict setObject:@"Test Question" forKey:@"QUESTION_TEXT"];

                       NSMutableDictionary * savedict=[[NSMutableDictionary alloc] init];
                       [savedict setObject:questionDict forKey:@"DATA"];
                       NSString *strCount = [[infoArray objectAtIndex:0]objectAtIndex:0];
                       NSError * err;
                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:savedict options:0 error:&err];
                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                       
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"pushSurvey.php"]]];
                    
                       NSData *requestData = [myString dataUsingEncoding:NSUTF8StringEncoding];
                       [request setHTTPMethod:@"POST"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                       [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
                       [request setHTTPBody: requestData];
                       
                       NSURLResponse *response;
                       
                       NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
                       if (responseData)
                       {
                           NSString *resSrt = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
                           resSrt=[resSrt stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                           resSrt=[resSrt stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                           resSrt=[resSrt stringByReplacingOccurrencesOfString:@" " withString:@""];
                           [self pushResponse:resSrt];
                       }
                       else
                       {
                           
                       }
                   });
}

-(void)pushResponse:(NSString *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       if ([result isEqualToString:@"SUCCESS"])
                       {
                           [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"LOCAL_DATA_SAVED"];
                           [self showAlertView:@"ALIVE 2.0" message:@"Your survey submitted successfully"];
                           [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SURVEY_PUSHED"];
                           [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"SURVEY_ID"];
                       }
                       else
                       {
                           [self showAlertView:@"ALIVE 2.0" message:@"Error pushing survey"];
                       }
                   });
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
                                handler:^(UIAlertAction * action)
                                {
                                    [self goToHomePage];
                                }];
    
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)goToHomePage
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

#pragma marks collection view delegate and datasources

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return infoArray.count;
}

- (cardCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    cardCell *cell = [cardCollectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.cellData  = [infoArray objectAtIndex:indexPath.item];
    cell.imageData = [imageDataArr objectAtIndex:indexPath.item];
    cell.delegate=self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)exportBtnClicked:(id)sender
{
    [self showLoader:YES];
    [self exportWebservice];
}

-(void)exportWebservice
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableDictionary *questionDict =[[NSMutableDictionary alloc] init];
                       [questionDict setObject:infoArray forKey:@"ARR"];
                       NSString *surveyNameStr = [[NSString stringWithFormat:@"%@_%@_%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_NAME"],[[NSUserDefaults standardUserDefaults]valueForKey:@"SURVEY_ID"],[self curentDateStringFromDate:[NSDate date] withFormat:@"dd-MM-yyyy"]]stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
                       
                       [questionDict setObject:surveyNameStr forKey:@"SURVEY_NAME"];
                       NSMutableDictionary * savedict=[[NSMutableDictionary alloc] init];
                       [savedict setObject:questionDict forKey:@"DATA"];
                       
                       NSError * err;
                       NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:savedict options:0 error:&err];
                       NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                       
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[constantUrl stringByAppendingString:@"SURVEY_EXCEL/exportExcel.php"]]];
                       
                       NSData *requestData = [myString dataUsingEncoding:NSUTF8StringEncoding];
                       [request setHTTPMethod:@"POST"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                       [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                       [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
                       [request setHTTPBody: requestData];
                       
                       NSURLResponse *response;
                       
                       NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
                       if (responseData)
                       {
                           NSString *resSrt = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
                           resSrt=[resSrt stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                           resSrt=[resSrt stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                           resSrt=[resSrt stringByReplacingOccurrencesOfString:@" " withString:@""];
                           [self exportWebserviceResponse:resSrt];
                       }
                       else
                       {
                           
                       }
                   });
}

-(void)exportWebserviceResponse:(NSString *)result
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self showLoader:NO];
                       [self sendMail:result];
                   });
}

- (NSString *)curentDateStringFromDate:(NSDate *)dateTimeInLine withFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:dateFormat];
    
    NSString *convertedString = [formatter stringFromDate:dateTimeInLine];
    
    return convertedString;
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


@end
