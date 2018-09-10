//
//  DemographicsViewController.m
//  mckinsey
//
//  Created by Mac on 19/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "DemographicsViewController.h"
#import "notifications.h"
#import "DemographicsCollectionViewCell.h"
#import "CurrencyViewController.h"
#import "RangeHeadTableViewCell.h"
#import "RangeSubHeadTableViewCell.h"
#import "DemoGraphics.h"
#import "TextFieldHeadTableViewCell.h"
#import "TextFieldSubHeadTableViewCell.h"
#import "DropDownHeadTableViewCell.h"
#import "DropDownSubHeadTableViewCell.h"
#import "CustomTableViewCell.h"
#import "CCDropDownMenu.h"
#import "CCDropDownMenus.h"
#import "NIDropDown.h"
#import "MultipleSelectViewController.h"
#import "APIManager.h"
#import "loadingPage.h"
#import "Reachability.h"
#import "analysisTypeView.h"
#import "loginView.h"
#import "dashboard.h"


@interface DemographicsViewController () <UICollectionViewDataSource,UICollectionViewDelegate,currencyProtocol,UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout,CCDropDownMenuDelegate,NIDropDownDelegate,UIPopoverPresentationControllerDelegate,LocationProtocol,UIPickerViewDelegate,UIPickerViewDataSource>
{
    //NSMutableArray *attributeList;
    loadingPage *loadingPageObj;
    
    NSMutableArray *demographicsList;
    BOOL isDrag;
    BOOL ignorePerpendicularSwipes;
    CGPoint locationPoint;
    CGPoint startPoint;
    
    NSIndexPath *indexPath;
    NSIndexPath *selectedIndex;
    DemographicsCollectionViewCell *cell;
    NSString *attributeName;
    NSString *surveyID;
    
    NSMutableArray *preDefineList;
    NSArray *inputTypeList;
    
    NIDropDown *inputTypeDropDown;
    //UITextField *currentTxtField;
    NSInteger currentRowIndex;
    
    NSInteger inputTypeRow;
    
    
    NSMutableArray *selectedCountries;
    NSMutableArray *selectedStates;
    NSMutableArray *selectedCities;
    
    NSMutableArray *countriIDs;
    NSMutableArray *stateIDs;
    NSMutableArray *cityIDs;
}

@property (weak, nonatomic) IBOutlet UIButton *currencyBtn;
@property (weak, nonatomic) IBOutlet UILabel *badgeCountLbl;
@property (weak, nonatomic) IBOutlet UIImageView *badgeCountImg;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *demoGraphicsTableView;
@property (weak, nonatomic) IBOutlet UITextField *surveyName;
@property (weak, nonatomic) IBOutlet UIPickerView *inputPickerView;
@property (weak, nonatomic) IBOutlet UIView *inputTypeView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIView *adminQueView;
@property (weak, nonatomic) IBOutlet UITextField *mostPreQuesTextField;
@property (weak, nonatomic) IBOutlet UITextField *leasetPreQuesTextField;


- (IBAction)saveQuesBtnPressed:(id)sender;
- (IBAction)saveBtnPressed:(id)sender;
- (IBAction)logoutBtnPressed:(id)sender;
- (IBAction)homeBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;
- (IBAction)notificationBtnPressed:(id)sender;
- (IBAction)addNewBtnPressed:(id)sender;
- (IBAction)selectInputTypeBtnPressed:(id)sender;
- (IBAction)cancelInputTypeBtnPressed:(id)sender;
- (IBAction)questionTextBtnPressed:(id)sender;
- (IBAction)cancelBtnPresedd:(id)sender;

@end

@implementation DemographicsViewController
@synthesize currentTxtField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];    
    inputTypeRow = -1;
    ignorePerpendicularSwipes = YES;
    
    surveyID = @"NA";
    
    //DropdownList,CheckBox,RadioButton,Range,TextBox,Toggle Switch,Slider
    inputTypeList = @[@"RadioButton",@"DropdownList",@"CheckBox",@"TextBox",@"Toggle Switch",@"Slider",@"Range"];
    demographicsList = [[NSMutableArray alloc] init];
    
    NSString * result = [[inputTypeList valueForKey:@"description"] componentsJoinedByString:@","];
    NSLog(@"%@",result);
    
    //attributeList = [[NSMutableArray alloc] init];
    //[attributeList addObjectsFromArray:@[@"Age",@"Location",@"GENDER1",@"Income Group",@"AGE2",@"LOCATION2",@"Gender",@"INCOME2",@"AGE3",@"LOCATION3",@"GENDER3",@"INCOME3"]];
    
//    preDefineList = [[NSMutableArray alloc] init];
//
//    DemoGraphics *age = [[DemoGraphics alloc] initWithAttributeName:@"Age" andInputTye:@"Range" andOptions:[[NSMutableArray alloc]initWithArray:@[@"5-13",@"14-18",@"19-25",@"26-75"]]];
//
//    DemoGraphics *location = [[DemoGraphics alloc] initWithAttributeName:@"Location" andInputTye:@"Dropdown/CheckBox" andOptions:[[NSMutableArray alloc]initWithArray:@[@"Country",@"State",@"City"]]];
//
//    DemoGraphics *gender = [[DemoGraphics alloc] initWithAttributeName:@"Gender" andInputTye:@"Radio Button" andOptions:[[NSMutableArray alloc]initWithArray:@[@"Male",@"Female",@"Transgender",@"Do not Specify"]]];
//
//    DemoGraphics *incomeGrp = [[DemoGraphics alloc] initWithAttributeName:@"Income Group" andInputTye:@"Range" andOptions:[[NSMutableArray alloc]initWithArray:@[@"1 lac - 3 lac",@"4 lac - 6 lac",@"7 lac - above"]]];
//
//    [preDefineList addObject:age];
//    [preDefineList addObject:location];
//    [preDefineList addObject:gender];
//    [preDefineList addObject:incomeGrp];
    
   // [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(save) userInfo:nil repeats:YES];
    
    [_inputTypeView setHidden:true];
    
    //[self showHideKeyboard];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"DEMOGRAPHICS_DATA"] != NULL) {
        demographicsList = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"DEMOGRAPHICS_DATA"]];
    }
    else {
        NSLog(@"null");
         [self fetchPredefineAttribute];
    }    
    //[self fetchCountry];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *countryJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSLog(@"%@",countryJson);
    
    [self getQuestions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    //[super viewWillAppear:animated];
    _badgeCountImg.hidden = YES;
    _badgeCountLbl.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadgeNumber) name:@"setbadge" object:nil];
}

-(void)showHideKeyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


-(void) keyboardWillShow:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.demoGraphicsTableView.frame;
    
    // Start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Reduce size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height -= keyboardBounds.size.height;
    else
        frame.size.height -= keyboardBounds.size.height;
    
    // Apply new size of table view
    self.demoGraphicsTableView.frame = frame;
    
    // Scroll the table view to see the TextField just above the keyboard
    if (self.currentTxtField)
    {
        CGRect textFieldRect = [self.demoGraphicsTableView convertRect:self.currentTxtField.bounds fromView:self.currentTxtField];
        [self.demoGraphicsTableView scrollRectToVisible:textFieldRect animated:NO];
    }
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.demoGraphicsTableView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Increase size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height += keyboardBounds.size.height;
    else
        frame.size.height += keyboardBounds.size.height;
    
    // Apply new size of table view
    self.demoGraphicsTableView.frame = frame;
    
    [UIView commitAnimations];
}

//- (void)keyboardDidShow: (NSNotification *) notif
//{
//    NSLog(@"%ld",(long)currentTxtField.tag);
//    if (self.view.frame.origin.y != -250 && currentTxtField.tag != 101)
//    {
//        [UIView beginAnimations: @"animateTextField" context: nil];
//        [UIView setAnimationBeginsFromCurrentState: YES];
//        [UIView setAnimationDuration: 0.3f];
//        self.view.frame = CGRectOffset(self.view.frame, 0, -250);
//        [UIView commitAnimations];
//       // containerView.frame = CGRectMake(21, 312, 753, 300);
//        //inputTableMaxDif.frame = CGRectMake(0, 0, 753, 300);
//    }
//}
//
//- (void)keyboardDidHide: (NSNotification *) notif
//{
//    if (self.view.frame.origin.y != 0)
//    {
//        [UIView beginAnimations: @"animateTextField" context: nil];
//        [UIView setAnimationBeginsFromCurrentState: YES];
//        [UIView setAnimationDuration: 0.3f];
//        self.view.frame = CGRectOffset(self.view.frame, 0, 250);
//        [UIView commitAnimations];
//        //containerView.frame = CGRectMake(21, 312, 753, 388);
//        //inputTableMaxDif.frame = CGRectMake(0, 0, 753, 388);
//    }
//}


- (void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    int movementDistance = 0;
    
    movementDistance = -250;
    
    const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark - Web Services
- (void)fetchPredefineAttribute {
    [self showLoader:YES];
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/predefined_attributes.php" andParam:@{@"ADMIN_ID":[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"]}  withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if(isSuccess) {
            preDefineList = [[NSMutableArray alloc] init];
            for (NSDictionary *attributeDict in response) {
                
                NSMutableArray *optionArray = [[NSMutableArray alloc] init];
                for (NSDictionary *options in [attributeDict objectForKey:@"OPTIONS"]) {
                    [optionArray addObject:[options objectForKey:@"OPTION_NAME"]];
                }
                DemoGraphics *obj = [[DemoGraphics alloc] initWithAttributeName:[attributeDict objectForKey:@"ATTRIBUTE_NAME"] andInputTye:[attributeDict objectForKey: @"INPUT_TYPE"] andOptions:optionArray andControlName:[attributeDict objectForKey:@"CONTROL_NAME"] andAttributeType:@"Old" andPredefineID:[attributeDict objectForKey:@"PRE_ID"]];
                
                [preDefineList addObject:obj];
            }
            [self.collectionView reloadData];
        }
    }];
}


- (void)fetchCountry {
    [self showLoader:YES];
    [[APIManager new] postRequest:@"mckinsey/PHP/_IPHONE/country.php" andParam:@"" withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if (isSuccess) {
            //NSMutableDictionary *dataDict = (NSMutableDictionary *)response;
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:response];
            selectedCountries = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in tempArray) {
                
                NSMutableDictionary *dir = [NSMutableDictionary dictionaryWithDictionary:dict];
                dir[@"isSelected"] = @"NO";
                [selectedCountries addObject:dir];
                NSLog(@"%@",dict);
            }
            NSMutableDictionary *tempDict = [[ NSMutableDictionary alloc] initWithDictionary:@{@"COUNTRY_NAME":@"Select all",@"isSelected":@"NO"}];
            [selectedCountries insertObject:tempDict atIndex:0];
            //[self.locationTableView reloadData];
        }
    }];
}

- (void)fetchStates:(NSArray *)contriesID {
    
//    [self showLoader:YES];
//    NSDictionary *paramDict = @{@"DATA":contriesID};
//    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/states.php" andParam:paramDict withBlock:^(id response, BOOL isSuccess) {
//
//        [self showLoader:NO];
//        if (isSuccess) {
//            selectedStates = [[NSMutableArray alloc] init];
//            selectedStates = response;
////            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
////            [tempDict setObject:@"" forKey:@"COUNTRY_NAME"];
////            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
////
////            NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] init];
////            [stateDict setObject:@"Select all" forKey:@"STATE_NAME"];
////            [stateDict setObject:@"NO" forKey:@"isSelected"];
////            [tempArray addObject:stateDict];
////            [tempDict setObject:stateDict forKey:@"STATES"];
////
//            //[selectedStates insertObject:tempDict atIndex:0];
//        }
//    }];
}

- (void)fetchCities:(NSArray *)stateIds {
    [self showLoader:YES];
    NSDictionary *paramDict = @{@"DATA":stateIds};
    [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/cities.php" andParam:paramDict withBlock:^(id response, BOOL isSuccess) {
        
        [self showLoader:NO];
        if (isSuccess) {
            selectedCities = [[NSMutableArray alloc] init];
            selectedCities = response;
        }
    }];
}

- (void)getQuestions {
    [[APIManager new] postJSONRequestWithJSONResponse:@"mckinsey/PHP/_IPHONE/MCKINSEY/get_question.php" andParam:@{@"ADMIN_ID":[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"]} withBlock:^(id response, BOOL isSuccess) {
        
        if (isSuccess) {
            NSLog(@"%@",response);
            _mostPreQuesTextField.text = [[response objectAtIndex:0] objectForKey:@"QUESTION1"];
            _leasetPreQuesTextField.text = [[response objectAtIndex:0] objectForKey:@"QUESTION2"];
        }
        else {
            
        }
    }];
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
        _badgeCountLbl.text = [[dict objectForKey:@"BADGE_COUNT"] stringValue];
        if ([[dict objectForKey:@"BADGE_COUNT"]intValue] == 0)
        {
            _badgeCountImg.hidden = YES;
            _badgeCountLbl.hidden = YES;
        }
        else
        {
            _badgeCountImg.hidden = NO;
            _badgeCountLbl.hidden = NO;
        }
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
}


#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (![preDefineList count]) {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(collectionView.center.x, collectionView.center.y, 300, 30)];
        textLabel.text = @"No predefine attributes";
        textLabel.textColor = [UIColor blackColor];
        [collectionView.backgroundView addSubview:textLabel];
        return 1;
    }
    collectionView.backgroundView = nil;
    return  1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [preDefineList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DemographicsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    }
    NSLog(@"%@",[[preDefineList objectAtIndex:indexPath.row] attributeNameStr]);
    cell.attributeNameLabel.text = [[preDefineList objectAtIndex:indexPath.row] attributeNameStr];
    
    UILongPressGestureRecognizer *panGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellMoved:)];
    panGesture.minimumPressDuration = 0.1;
    panGesture.delegate = self;
    
    cell.hidden = false;
    cell.contentView.tag = indexPath.row;
    [cell addGestureRecognizer:panGesture];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((CGRectGetWidth(collectionView.frame)/4)-20, (CGRectGetHeight(collectionView.frame)));
}

#pragma mark - UITableView Datasource/ Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [demographicsList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%@",[[demographicsList objectAtIndex:indexPath.section] inputType]);
    NSLog(@"%@",[[demographicsList objectAtIndex:indexPath.section] attributeNameStr]);
    
    if ([[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"Toggle Switch"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"TextBox"]) {
        return 1;
    }
    return [[[demographicsList objectAtIndex:section] optionList] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[demographicsList objectAtIndex:indexPath.section] controlName] isEqualToString:@"ddl_age"] || [[[demographicsList objectAtIndex:indexPath.section] controlName] isEqualToString:@"ddl_income"] || [[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"Slider"] || [[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"Range"]) {
        if (indexPath.row == 0) {
            RangeHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rangeHeadCell"];
            if(cell == nil) {
                cell = [[RangeHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rangeHeadCell"];
                cell.backgroundColor = [UIColor clearColor];//manoj changed
            }
            NSLog(@"%@",[[demographicsList objectAtIndex:indexPath.section] attributeType]);
            if ([[[demographicsList objectAtIndex:indexPath.section] attributeType] isEqualToString:@"Old"]) {
                [cell.attributeNameTextField setEnabled:NO];
            }
            else {
                [cell.attributeNameTextField setEnabled:YES];
            }
            cell.srNoLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section+1];
            cell.attributeNameTextField.text = [[demographicsList objectAtIndex:indexPath.section] attributeNameStr];
            [cell.inputTypeBtn setTitle:[[demographicsList objectAtIndex:indexPath.section] inputType] forState:UIControlStateNormal];
            [cell.inputTypeBtn setEnabled:false];
            
            NSLog(@"%@",[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row]);
            if ([[NSString stringWithFormat:@"%@",[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row]] containsString:@"-"] ) {
                cell.rangeFrom.text = [[[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"] objectAtIndex:0];
                cell.rangeTo.text = [[[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"] objectAtIndex:1];
            }
            else {
                cell.rangeFrom.text = @"";
                cell.rangeTo.text = @"";
            }
            NSLog(@"%lu",(unsigned long)[[[demographicsList objectAtIndex:indexPath.section] optionList] count]);
            if ([[[demographicsList objectAtIndex:indexPath.section] optionList] count] > 1 || [[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"Slider"]) {
                [cell.addBtn setHidden:true];
            }
            else {
                [cell.addBtn setHidden:false];
            }
            
            cell.addBtn.tag = indexPath.section*100+indexPath.row;
            [cell.addBtn addTarget:self action:@selector(addOptions:) forControlEvents:UIControlEventTouchUpInside];
            if ([[[demographicsList objectAtIndex:indexPath.section] optionList] count] > 1) {
                [cell.closeBtn setHidden:false];
            }
            else {
                [cell.closeBtn setHidden:true];
            }
            cell.closeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeBtn addTarget:self action:@selector(deleteOptions:)  forControlEvents:UIControlEventTouchUpInside];
            cell.closeAttributeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeAttributeBtn addTarget:self action:@selector(deleteSection:)  forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        else {
            RangeSubHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rangeSubCell"];
            if(cell == nil) {
                cell = [[RangeSubHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rangeSubCell"];
            }
            if ([[NSString stringWithFormat:@"%@",[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row]] containsString:@"-"] ) {
                cell.rangeFrom.text = [[[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"] objectAtIndex:0];
                cell.rangeTo.text = [[[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row] componentsSeparatedByString:@"-"] objectAtIndex:1];
            }
            else {
                cell.rangeFrom.text = @"";
                cell.rangeTo.text = @"";
            }
            cell.closeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeBtn addTarget:self action:@selector(deleteOptions:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.addBtn.tag = indexPath.section*100+indexPath.row;
            [cell.addBtn addTarget:self action:@selector(addOptions:) forControlEvents:UIControlEventTouchUpInside];
            
            NSLog(@"last obj %@",[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:[[[demographicsList objectAtIndex:indexPath.section] optionList] count]-1]);
            NSLog(@"current obj %@",[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row]);
            
            if ([[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:[[[demographicsList objectAtIndex:indexPath.section] optionList] count]-1] isEqualToString:[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row]]) {
                 [cell.addBtn setHidden:false];
            }
            else {
                [cell.addBtn setHidden:true];
            }
            
            return cell;
        }
    }
    else if([[[demographicsList objectAtIndex:indexPath.section] controlName] isEqualToString:@"ddl_gender"]) {
        if (indexPath.row == 0) {
            TextFieldHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldHeadCell"];
            if(cell == nil) {
                cell = [[TextFieldHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldHeadCell"];
            }
            if ([[[demographicsList objectAtIndex:indexPath.section] attributeType] isEqualToString:@"Old"]) {
                [cell.attributeNameTextField setEnabled:NO];
            }
            else {
                [cell.attributeNameTextField setEnabled:YES];
            }
            if ([[[demographicsList objectAtIndex:indexPath.section] optionList] count] > 1) {
                [cell.closeBtn setHidden:false];
            }
            else {
                [cell.closeBtn setHidden:true];
            }
            cell.addBtn.tag = indexPath.section*100+indexPath.row;
            [cell.addBtn addTarget:self action:@selector(addOptions:) forControlEvents:UIControlEventTouchUpInside];
            cell.srNoLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section+1];
            cell.attributeNameTextField.text = [[demographicsList objectAtIndex:indexPath.section] attributeNameStr];
            [cell.inputTypeBtn setEnabled:false];
            [cell.inputTypeBtn setTitle:@"RadioButton" forState:UIControlStateNormal];
            cell.optionTextField.text = [[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row];
            cell.optionTextField.tag = 2000;
            if ([[[demographicsList objectAtIndex:indexPath.section] optionList] count] > 1) {
                [cell.addBtn setHidden:true];
            }
            else {
                [cell.addBtn setHidden:false];
            }
            
            cell.closeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeBtn addTarget:self action:@selector(deleteOptions:) forControlEvents:UIControlEventTouchUpInside];
            cell.closeAttributeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeAttributeBtn addTarget:self action:@selector(deleteSection:)  forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else {
            TextFieldSubHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldSubHeadCell"];
            if(cell == nil) {
                cell = [[TextFieldSubHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldSubHeadCell"];
            }
            cell.optionTextField.text = [[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row];
            cell.optionTextField.tag = 2000;
            cell.addBtn.tag = indexPath.section*100+indexPath.row;
            [cell.addBtn addTarget:self action:@selector(addOptions:) forControlEvents:UIControlEventTouchUpInside];
            cell.closeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeBtn addTarget:self action:@selector(deleteOptions:) forControlEvents:UIControlEventTouchUpInside];
            if ([[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:[[[demographicsList objectAtIndex:indexPath.section] optionList] count]-1] isEqualToString:[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row]]) {
                [cell.addBtn setHidden:false];
            }
            else {
                [cell.addBtn setHidden:true];
            }
            return cell;
        }
    }
    else if([[[demographicsList objectAtIndex:indexPath.section] controlName] isEqualToString:@"ddl_location"]) {
        if (indexPath.row == 0) {
            DropDownHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropDownHeadCell"];
            if(cell == nil) {
                cell = [[DropDownHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dropDownHeadCell"];
            }
            if ([[[demographicsList objectAtIndex:indexPath.section] attributeType] isEqualToString:@"Old"]) {
                [cell.attributeNameTextField setEnabled:NO];
            }
            else {
                [cell.attributeNameTextField setEnabled:YES];
            }
            [cell.inputTypeBtn setEnabled:false];
            cell.attributeNameTextField.text =[[demographicsList objectAtIndex:indexPath.section] attributeNameStr];
            cell.srNoLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section+1];
            [cell.inputTypeBtn setTitle:@"DropdownList" forState:UIControlStateNormal];
            [cell.optionBtn setTitle:[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            [cell.optionBtn addTarget:self action:@selector(countryBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.addBtn setHidden:true];
            [cell.closeBtn setHidden:true];
            cell.closeAttributeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeAttributeBtn addTarget:self action:@selector(deleteSection:)  forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else {
            DropDownSubHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropDownSubHeadCell"];
            if(cell == nil) {
                cell = [[DropDownSubHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dropDownSubHeadCell"];
            }
            [cell.optionBtn addTarget:self action:@selector(stateCityBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.optionBtn setTitle:[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            [cell.addBtn setHidden:true];
            [cell.closeBtn setHidden:true];
            return cell;
        }
    }
    else if([[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"RadioButton"] || [[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"DropdownList"] || [[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"CheckBox"]) {
        
        if (indexPath.row == 0) {
            TextFieldHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldHeadCell"];
            if(cell == nil) {
                cell = [[TextFieldHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldHeadCell"];
            }
            if ([[[demographicsList objectAtIndex:indexPath.section] attributeType] isEqualToString:@"Old"]) {
                [cell.attributeNameTextField setEnabled:NO];
            }
            else {
                [cell.attributeNameTextField setEnabled:YES];
            }
            if ([[[demographicsList objectAtIndex:indexPath.section] optionList] count] > 1) {
                [cell.closeBtn setHidden:false];
            }
            else {
                [cell.closeBtn setHidden:true];
            }
            cell.addBtn.tag = indexPath.section*100+indexPath.row;
            [cell.addBtn addTarget:self action:@selector(addOptions:) forControlEvents:UIControlEventTouchUpInside];
            cell.srNoLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section+1];
            cell.attributeNameTextField.text = [[demographicsList objectAtIndex:indexPath.section] attributeNameStr];
            cell.optionTextField.text = [[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row];
            cell.optionTextField.tag = 3000;
            [cell.inputTypeBtn setEnabled:false];
            [cell.inputTypeBtn setTitle:[[demographicsList objectAtIndex:indexPath.section] inputType] forState:UIControlStateNormal];
            if ([[[demographicsList objectAtIndex:indexPath.section] optionList] count] > 1) {
                [cell.addBtn setHidden:true];
            }
            else {
                [cell.addBtn setHidden:false];
            }
            cell.closeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeBtn addTarget:self action:@selector(deleteOptions:) forControlEvents:UIControlEventTouchUpInside];
            cell.closeAttributeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeAttributeBtn addTarget:self action:@selector(deleteSection:)  forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else {
            TextFieldSubHeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldSubHeadCell"];
            if(cell == nil) {
                cell = [[TextFieldSubHeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldSubHeadCell"];
            }
            cell.addBtn.tag = indexPath.section*100+indexPath.row;
            [cell.addBtn addTarget:self action:@selector(addOptions:) forControlEvents:UIControlEventTouchUpInside];
            cell.closeBtn.tag = indexPath.section*100+indexPath.row;
            [cell.closeBtn addTarget:self action:@selector(deleteOptions:) forControlEvents:UIControlEventTouchUpInside];
            cell.optionTextField.text = [[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row];
            cell.optionTextField.tag = 3000;
            if ([[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:[[[demographicsList objectAtIndex:indexPath.section] optionList] count]-1] isEqualToString:[[[demographicsList objectAtIndex:indexPath.section] optionList] objectAtIndex:indexPath.row]]) {
                [cell.addBtn setHidden:false];
            }
            else {
                [cell.addBtn setHidden:true];
            }
            return cell;
        }
    }
    else if ([[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"Toggle Switch"] || [[[demographicsList objectAtIndex:indexPath.section] inputType] isEqualToString:@"TextBox"]) {
        CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
        if(cell == nil) {
            cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"customCell"];
        }
        if ([[[demographicsList objectAtIndex:indexPath.section] attributeType] isEqualToString:@"Old"]) {
            [cell.attributeNameTextField setEnabled:NO];
        }
        else {
            [cell.attributeNameTextField setEnabled:YES];
        }
        cell.srNoLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section+1];
        [cell.inputTypeBtn setEnabled:false];
        cell.attributeNameTextField.text = [[demographicsList objectAtIndex:indexPath.section] attributeNameStr];
        [cell.inputTypeBtn setTitle:[[demographicsList objectAtIndex:indexPath.section] inputType] forState:UIControlStateNormal];
        cell.inputTypeBtn.tag = indexPath.section*100+indexPath.row;
        cell.closeAttributeBtn.tag = indexPath.section*100+indexPath.row;
        [cell.closeAttributeBtn addTarget:self action:@selector(deleteSection:)  forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    if(cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"customCell"];
    }
    if ([[[demographicsList objectAtIndex:indexPath.section] attributeType] isEqualToString:@"Old"]) {
        [cell.attributeNameTextField setEnabled:NO];
    }
    else {
        [cell.attributeNameTextField setEnabled:YES];
    }
    cell.srNoLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section+1];
    [cell.inputTypeBtn setEnabled:true];
    cell.attributeNameTextField.text = [[demographicsList objectAtIndex:indexPath.section] attributeNameStr];
    
    [cell.inputTypeBtn setTitle:@"Input Type" forState:UIControlStateNormal];
    cell.inputTypeBtn.tag = indexPath.section*100+indexPath.row;
    [cell.inputTypeBtn addTarget:self action:@selector(inputBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.closeAttributeBtn.tag = indexPath.section*100+indexPath.row;
    [cell.closeAttributeBtn addTarget:self action:@selector(deleteSection:)  forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (inputTypeRow >= 0) {
        if (inputTypeRow == indexPath.section) {
            return 200.0;
        }
    }
    return 50.0;
}


#pragma mark - Picker view


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [inputTypeList count];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [inputTypeList objectAtIndex:row];
}

#pragma mark - Pan Gesture
- (void)cellMoved:(UILongPressGestureRecognizer *)longPress {
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            locationPoint = [longPress locationInView:longPress.view];
            [self.view bringSubviewToFront:longPress.view];
        }
        break;
            
        case UIGestureRecognizerStateEnded: {
            //CGPoint myNewPositionAtTheEnd = [longPress locationInView:longPress.view];
            CGPoint newCoord = [longPress locationInView:self.view];
             if (CGRectContainsPoint(_demoGraphicsTableView.frame, newCoord)) {
                 //[demographicsList addObject:@"1"];
                 self.demoGraphicsTableView.backgroundColor = [UIColor clearColor];
                 
                 [longPress.view removeFromSuperview];
                 [self.collectionView performBatchUpdates:^{
                     [demographicsList addObject:[preDefineList objectAtIndex:selectedIndex.item]];
                     [preDefineList removeObjectAtIndex:selectedIndex.item];
                     [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:selectedIndex]];
                 } completion:^(BOOL finished) {
                     [self.collectionView reloadData];
//                     NSRange range = NSMakeRange(0, [demographicsList count]);
//                     NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
//                     [self.demoGraphicsTableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
                 }];
                 [self.demoGraphicsTableView reloadData];
             }
             else {
                 self.demoGraphicsTableView.backgroundColor = [UIColor clearColor];
                 [UIView animateWithDuration:2 animations:^{
                     longPress.view.frame = CGRectMake(startPoint.x,
                                                       startPoint.y,
                                                       longPress.view.frame.size.width,
                                                       longPress.view.frame.size.height);
                 }];
                 [longPress.view removeFromSuperview];
                 [self.collectionView reloadData];
             }
        }
        break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint p = [longPress locationInView:self.collectionView];
            indexPath = [self.collectionView indexPathForItemAtPoint:p];
            if (indexPath == nil){
                NSLog(@"couldn't find index path");
            }
            else {
                cell = (DemographicsCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                startPoint = cell.contentView.frame.origin;
                selectedIndex = indexPath;
                attributeName = [[preDefineList objectAtIndex:indexPath.row] attributeNameStr];
                NSLog(@"%@",[[preDefineList objectAtIndex:indexPath.row] attributeNameStr]);
                NSLog(@"indexpath : %ld",(long)indexPath.row);
           
                NSLog(@"number of sections count %ld",(long)[_demoGraphicsTableView numberOfSections]);
                //manoj
                if ([demographicsList count] != 0) {
                    NSLog(@"demographicsList count %lu",(unsigned long)[demographicsList count]);

                    if ([attributeName isEqualToString:@"Toggle Switch"]) {
                        
                DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:[demographicsList count] - 1] attributeNameStr] andInputTye:[inputTypeList objectAtIndex:4] andOptions:[[NSMutableArray alloc]initWithArray:@[@"Yes",@"No"]] andControlName:[inputTypeList objectAtIndex:4] andAttributeType:@"New" andPredefineID:@""];
                
                [demographicsList replaceObjectAtIndex:[demographicsList count] - 1 withObject:obj];
                [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:[demographicsList count] - 1] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }else {
                    if ([attributeName isEqualToString:@"Toggle Switch"]) {
                        
                        DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:0] attributeNameStr] andInputTye:[inputTypeList objectAtIndex:4] andOptions:[[NSMutableArray alloc]initWithArray:@[@"Yes",@"No"]] andControlName:[inputTypeList objectAtIndex:4] andAttributeType:@"New" andPredefineID:@""];
                        
                        [demographicsList replaceObjectAtIndex:0 withObject:obj];
                        [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }
            
            CGPoint newCoord = [longPress locationInView:self.view];
            longPress.view.frame = CGRectMake(newCoord.x-locationPoint.x, newCoord.y-locationPoint.y, longPress.view.frame.size.width, longPress.view.frame.size.height);
            [self.view addSubview:longPress.view];
            //[self.view bringSubviewToFront:longPress.view];
            
            if (CGRectContainsPoint(_demoGraphicsTableView.frame, newCoord)) {
                NSLog(@"move to tableview");
                NSLog(@"name of attribute %@",cell.attributeNameLabel.text);
                self.demoGraphicsTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            }
            else {
                NSLog(@"not in tableview");
                self.demoGraphicsTableView.backgroundColor = [UIColor clearColor];
            }
        }
        break;
            
        default:
            break;
    }
}

- (void)removeObjectFormPredefine:(DemoGraphics *)obj {
    for (DemoGraphics *preObj in preDefineList) {
        if ([[preObj attributeNameStr] isEqualToString:[obj attributeNameStr]]) {
            [preDefineList removeObjectAtIndex:[preDefineList indexOfObject:preObj]];
            break;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture
{
   
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"currencyPop"]) {
        [[[segue destinationViewController] popoverPresentationController] setSourceRect:[_currencyBtn bounds]];
        CurrencyViewController *destObj = (CurrencyViewController *)segue.destinationViewController;
        destObj.delegate = self;
        
        //NSMutableArray *currencyList = [[NSMutableArray alloc] init];
        //["USD-American Samoa", "EUR-Austria", "GBP-United Kingdom", "INR-India", "AUD-Australia", "CAD-Canada", "SGD-Singapore"];
//
//        NSDictionary *currencyDict = @{@"CURRENCY_NAME":@"American Samoa",@"CURRENCY_CODE":@"USD"};
//
//        [currencyList addObject:@{@"MOSTLY_USED":@[currencyDict]}];
//        [currencyList addObject:@{@"ALL":selectedCountries}];
//
        //destObj.currencyList = currencyList;
    }
}


#pragma mark - Currency Delegate method
- (void)setCurrency:(NSDictionary *)currencyDict {
    
    [_currencyBtn setTitle:[currencyDict objectForKey:@"currency_code"] forState:UIControlStateNormal];
}

#pragma mark - Button events

- (IBAction)currencyBtnPressed:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)saveQuesBtnPressed:(id)sender {
    
    if ([_mostPreQuesTextField.text isEqualToString:@""]) {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter most preferred question"];
    }
    else if([_leasetPreQuesTextField.text isEqualToString:@""]) {
        [self showAlertView:@"ALIVE 2.0" message:@"Please enter least preferred question"];
    }
    else {
        [self showLoader:YES];
        [[APIManager new] postJSONRequestWithJSONResponse:@"mckinsey/PHP/_IPHONE/MCKINSEY/update_question.php" andParam:@{@"ADMIN_ID":[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"],@"QUESTION1":_mostPreQuesTextField.text,@"QUESTION2":_leasetPreQuesTextField.text} withBlock:^(id response, BOOL isSuccess) {
            
            [self showLoader:NO];
            if (isSuccess) {
                NSLog(@"%@",response);
                if ([[[response objectAtIndex:0] objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]) {
                    [self.adminQueView removeFromSuperview];
                    [self showAlertView:@"ALIVE 2.0" message:@"Questions updated successfully"];
                }
                else {
                    [self showAlertView:@"ALIVE 2.0" message:@"Failed to update questions.. Please try again"];
                }
            }
            else {
                [self showAlertView:@"ALIVE 2.0" message:@"Failed to update questions"];
            }
        }];
    }
}

- (IBAction)saveBtnPressed:(id)sender {
    
//    NSCoder *encoder;
//    [encoder encodeObject:[demographicsList objectAtIndex:0] forKey:@"first"];
//
//   // NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:[encoder encodeObject:[demographicsList objectAtIndex:0] forKey:@"first"]];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:[encoder encodeObject:[demographicsList objectAtIndex:0] forKey:@"first"] forKey:@"DEMOGRA"];
//    [defaults synchronize];
    
    if ([_surveyName.text isEqualToString:@""]) {
        [self showAlertView:@"Alive 2.0" message:@"Please enter survey name"];
    }
    else if([_currencyBtn.titleLabel.text isEqualToString:@"Select Currency"]) {
        [self showAlertView:@"Alive 2.0" message:@"Please select currency for the survey"];
    }
    else if (![self checkAttributeName]) {
        [self showAlertView:@"Alive 2.0" message:@"Please enter attribute name"];
    }
    else if(![self checkInputType]) {
        [self showAlertView:@"Alive 2.0" message:@"Please select input type"];
    }
    else if(![self checkOptionList]) {
        [self showAlertView:@"Alive 2.0" message:@"Please enter options"];
    }
    else if(![self checkForRepeatedAtrribute]) {
        [self showAlertView:@"Alive 2.0" message:@"Attribute name should not be reapeted"];
    }
    else {

        NSMutableDictionary *postParam = [[NSMutableDictionary alloc] init];
        NSMutableArray *controllerList = [[NSMutableArray alloc] init];
        for (DemoGraphics *controller in demographicsList) {
            NSMutableDictionary *controllersDict = [[NSMutableDictionary alloc] init];

            if ([controller.controlName isEqualToString:@"ddl_location"]) {
                if (countriIDs != nil) {
                [controller.optionList replaceObjectAtIndex:0 withObject:[[countriIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                [controller.optionList replaceObjectAtIndex:1 withObject:[[stateIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                [controller.optionList replaceObjectAtIndex:2 withObject:[[cityIDs valueForKey:@"description"] componentsJoinedByString:@","]];

                [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                [controllersDict setObject:controller.inputType forKey:@"input_type"];
                [controllersDict setObject:controller.optionList forKey:@"options"];
                [controllersDict setObject:controller.controlName forKey:@"control_name"];
                [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                [controllerList addObject:controllersDict];
                }else {
                    //                    [controller.optionList replaceObjectAtIndex:0 withObject:@" " componentsJoinedByString:@","];
                    [controller.optionList replaceObjectAtIndex:0 withObject:@""];
                    
                    [controller.optionList replaceObjectAtIndex:1 withObject: @""];
                    [controller.optionList replaceObjectAtIndex:2 withObject:@""];
                    
                    [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                    [controllersDict setObject:controller.inputType forKey:@"input_type"];
                    [controllersDict setObject:controller.optionList forKey:@"options"];
                    [controllersDict setObject:controller.controlName forKey:@"control_name"];
                    [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                    [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                    //[controllerList insertObject:controllersDict atIndex:0];
                    [controllerList addObject:controllersDict];
                }
            }
            else {
                [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                [controllersDict setObject:controller.inputType forKey:@"input_type"];
                [controllersDict setObject:controller.optionList forKey:@"options"];
                [controllersDict setObject:controller.controlName forKey:@"control_name"];
                [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                [controllerList addObject:controllersDict];
            }
        }
        [postParam setObject:controllerList forKey:@"controllers"];
        [postParam setObject:_surveyName.text forKey:@"SURVEY_NAME"];
        [postParam setObject:_currencyBtn.titleLabel.text forKey:@"CURRENCY_VAL"];
        [postParam setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"] forKey:@"ADMIN_ID"];
        //[postParam setObject:surveyID forKey:@"SURVEY_ID"];
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:postParam forKey:@"DATA"];

        [self showLoader:YES];
        [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/insert_demog3.php" andParam:paramDict withBlock:^(id response, BOOL isSuccess) {

            [self showLoader:NO];
            if (isSuccess) {

                NSLog(@"response %@",response);
                if ([[response objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]) {

                   // surveyID = [response objectForKey:@"SURVEY_ID"];
                    [self showAlertView:@"ALIVE 2.0" message:@"Survey saved successfully"];
                    NSLog(@"data saved successfully");
                }
                else {
                    [self showAlertView:@"ALIVE 2.0" message:@"Failed to save survey, Please try again"];
                    NSLog(@"failed to save data");
                }
            }
            else {
                [self showAlertView:@"Alive 2.0" message:@"Failed to submit, Please try again later"];
            }
        }];

        NSLog(@"%@",postParam);
    }
}

- (IBAction)logoutBtnPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_DATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"data = %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"USER_DATA"]);
    
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for( int i=0;i<[viewControllers count];i++)
    {
        id obj=[viewControllers objectAtIndex:0];
        if ([obj isKindOfClass:[loginView class]])
        {
            UINavigationController * navigationController = self.navigationController;
            [navigationController popToRootViewControllerAnimated:NO];
            return;
        }
        else if ([obj isKindOfClass:[dashboard class]])
        {
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            //[navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
        }
        else if ([obj isKindOfClass:[userManagement class]])
        {
            loginView *loginViewObj = [[loginView alloc]initWithNibName:[NSString stringWithFormat:@"loginView"] bundle:nil];
            UINavigationController * navigationController = self.navigationController;
            //[navigationController popToRootViewControllerAnimated:NO];
            [navigationController pushViewController:loginViewObj animated:NO];
            return;
            
        }
    }

}

- (IBAction)homeBtnPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:true];
}

- (IBAction)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)notificationBtnPressed:(id)sender {
    _badgeCountImg.hidden = YES;
    _badgeCountLbl.hidden = YES;
    [self setBadgeCountZeroInPlist];
    notifications *notificationViewObj = [[notifications alloc]initWithNibName:@"notifications" bundle:nil];
    [self.navigationController pushViewController:notificationViewObj animated:YES];
}

- (IBAction)addNewBtnPressed:(id)sender {
//    [_collectionView reloadData];
//    if ([preDefineList count]) {
//        NSLog(@"yes");
//        NSLog(@"%@",[[preDefineList objectAtIndex:0] attributeNameStr]);
//        NSLog(@"%@",[[preDefineList objectAtIndex:0] optionList]);
//        NSLog(@"%@",[[preDefineList objectAtIndex:0] inputType]);
//    }
    
    [self.view endEditing:true];
    DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:@"" andInputTye:@"" andOptions:[[NSMutableArray alloc]initWithArray:@[@"custom"]] andControlName:@"custom" andAttributeType:@"New" andPredefineID:@"0"];
    [demographicsList addObject:obj];
    [self.demoGraphicsTableView reloadData];
}


- (IBAction)selectInputTypeBtnPressed:(UIButton *)sender {
    NSLog(@"%@",[inputTypeList objectAtIndex:[_inputPickerView selectedRowInComponent:0]]);
    
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    NSLog(@"%ld",section);
    NSLog(@"%ld",(long)row);
    inputTypeDropDown = nil;

    //CustomTableViewCell *cell = (CustomTableViewCell *)[self.demoGraphicsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];

    NSInteger index = [inputTypeList indexOfObject:[inputTypeList objectAtIndex:[_inputPickerView selectedRowInComponent:0]]];
    NSLog(@"%@",[inputTypeList objectAtIndex:index]);

    if ([[inputTypeList objectAtIndex:index] isEqualToString:@"RadioButton"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"DropdownList"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"CheckBox"]) {
        DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:section] attributeNameStr] andInputTye:[inputTypeList objectAtIndex:index] andOptions:[[NSMutableArray alloc]initWithArray:@[@""]] andControlName:[inputTypeList objectAtIndex:index] andAttributeType:@"New" andPredefineID:@""];

        [demographicsList replaceObjectAtIndex:section withObject:obj];
        [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        //[self.demoGraphicsTableView reloadSections: withRowAnimation:UITableViewRowAnimationFade];
    }
    else if([[inputTypeList objectAtIndex:index] isEqualToString:@"Range"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"Slider"]) {
        DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:section] attributeNameStr] andInputTye:[inputTypeList objectAtIndex:index] andOptions:[[NSMutableArray alloc]initWithArray:@[@"-"]] andControlName:[inputTypeList objectAtIndex:index] andAttributeType:@"New" andPredefineID:@""];

        [demographicsList replaceObjectAtIndex:section withObject:obj];
        [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if([[inputTypeList objectAtIndex:index] isEqualToString:@"Toggle Switch"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"TextBox"]){
        DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:section] attributeNameStr] andInputTye:[inputTypeList objectAtIndex:index] andOptions:[[NSMutableArray alloc]initWithArray:@[@"Yes",@"No"]] andControlName:[inputTypeList objectAtIndex:index] andAttributeType:@"New" andPredefineID:@""];
        
        [demographicsList replaceObjectAtIndex:section withObject:obj];
        [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    }
    inputTypeRow = -1;
    [self.demoGraphicsTableView beginUpdates];
    [self.demoGraphicsTableView endUpdates];

    [_inputTypeView setHidden:true];
}

- (IBAction)cancelInputTypeBtnPressed:(id)sender {
    [_inputTypeView setHidden:true];
    //[self.view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
}

- (IBAction)questionTextBtnPressed:(id)sender {
    [_adminQueView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [self.view addSubview:_adminQueView];
}

- (IBAction)cancelBtnPresedd:(id)sender {
    [self.adminQueView removeFromSuperview];
}

- (void)inputBtnPressed:(UIButton *)inputBtn {
    
//    NSInteger section = inputBtn.tag / 100;
//    NSInteger row = inputBtn.tag % 100;
//
//    _inputTypeView.tag = section*100+row;
    _selectBtn.tag = inputBtn.tag;
    [_inputTypeView setHidden:false];
    [_inputPickerView reloadAllComponents];
    [_inputTypeView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];

    [self.view endEditing:YES];
//    NSArray * arrImage = [[NSArray alloc] init];
//    if(inputTypeDropDown == nil)
//    {
//        NSInteger section = inputBtn.tag / 100;
//        inputTypeRow = section;
//        [self.demoGraphicsTableView beginUpdates];
//        [self.demoGraphicsTableView endUpdates];
//        CGFloat f = 140;
//        inputTypeDropDown = [[NIDropDown alloc]showDropDown:inputBtn :&f :inputTypeList :arrImage :@"down" :[UIImage imageNamed:@"umTxt.png"]];
//        inputTypeDropDown.delegate = self;
//    }
//    else
//    {
//        inputTypeRow = -1;
//        [self.demoGraphicsTableView beginUpdates];
//        [self.demoGraphicsTableView endUpdates];
//        [inputTypeDropDown hideDropDown:inputBtn];
//        inputTypeDropDown = nil;
//    }
}

- (BOOL)checkAttributeName {
    
    for (DemoGraphics *controller in demographicsList) {
        if ([controller.attributeNameStr isEqualToString:@""]) {
            return false;
        }
    }
    return true;
}

- (BOOL)checkInputType {
    
    for (DemoGraphics *controller in demographicsList) {
        if ([controller.inputType isEqualToString:@""]) {
            return false;
        }
    }
    return true;
}

- (BOOL)checkOptionList {
    
    for (DemoGraphics *controller in demographicsList) {
        
        for (NSString *option in controller.optionList) {
            NSLog(@"%@",controller.inputType);
            if ([controller.inputType isEqualToString:@"TextBox"] || [controller.inputType isEqualToString:@"Toggle Switch"]) {
                
            }
            else {
                if ([option isEqualToString:@""] || [option isEqualToString:@"-"]) {
                    return false;
                }
            }
        }
    }
    return true;
}

- (BOOL)checkForRepeatedAtrribute {
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (DemoGraphics *attributeDict in demographicsList) {
        [names addObject:attributeDict.attributeNameStr.lowercaseString];
    }
    NSCountedSet *set = [[NSCountedSet alloc] initWithArray:names];
    for (id item in set)
    {
        if ([set countForObject:item] > 1) {
            return false;
        }
        NSLog(@"Name=%@, Count=%lu", item, (unsigned long)[set countForObject:item]);
    }
    return true;
}


- (IBAction)nextBtnPressed:(id)sender {
    
    [self checkForRepeatedAtrribute];
    
    if ([_surveyName.text isEqualToString:@""]) {
        [self showAlertView:@"Alive 2.0" message:@"Please enter survey name"];
    }
    else if([_currencyBtn.titleLabel.text isEqualToString:@"Select Currency"]) {
        [self showAlertView:@"Alive 2.0" message:@"Please select currency for the survey"];
    }
    else if (![self checkAttributeName]) {
         [self showAlertView:@"Alive 2.0" message:@"Please enter attribute name"];
    }
    else if(![self checkInputType]) {
        [self showAlertView:@"Alive 2.0" message:@"Please select input type"];
    }
    else if(![self checkOptionList]) {
        [self showAlertView:@"Alive 2.0" message:@"Please enter options"];
    }
    else if(![self checkForRepeatedAtrribute]) {
        [self showAlertView:@"Alive 2.0" message:@"Attribute name should not be reapeted"];
    }
    else {
        
        NSMutableDictionary *postParam = [[NSMutableDictionary alloc] init];
        NSMutableArray *controllerList = [[NSMutableArray alloc] init];
        for (DemoGraphics *controller in demographicsList) {
            NSMutableDictionary *controllersDict = [[NSMutableDictionary alloc] init];
            
            if ([controller.controlName isEqualToString:@"ddl_location"]) {
                if (countriIDs != nil) {
                [controller.optionList replaceObjectAtIndex:0 withObject:[[countriIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                [controller.optionList replaceObjectAtIndex:1 withObject:[[stateIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                [controller.optionList replaceObjectAtIndex:2 withObject:[[cityIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                
                [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                [controllersDict setObject:controller.inputType forKey:@"input_type"];
                [controllersDict setObject:controller.optionList forKey:@"options"];
                [controllersDict setObject:controller.controlName forKey:@"control_name"];
                [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                //[controllerList insertObject:controllersDict atIndex:0];
                [controllerList addObject:controllersDict];
               
                }else {
//                    [controller.optionList replaceObjectAtIndex:0 withObject:@" " componentsJoinedByString:@","];
                    [controller.optionList replaceObjectAtIndex:0 withObject:@""];
                    
                    [controller.optionList replaceObjectAtIndex:1 withObject: @""];
                    [controller.optionList replaceObjectAtIndex:2 withObject:@""];
                    
                    [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                    [controllersDict setObject:controller.inputType forKey:@"input_type"];
                    [controllersDict setObject:controller.optionList forKey:@"options"];
                    [controllersDict setObject:controller.controlName forKey:@"control_name"];
                    [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                    [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                    //[controllerList insertObject:controllersDict atIndex:0];
                    [controllerList addObject:controllersDict];
                }
            }
            else {
                [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                [controllersDict setObject:controller.inputType forKey:@"input_type"];
                [controllersDict setObject:controller.optionList forKey:@"options"];
                [controllersDict setObject:controller.controlName forKey:@"control_name"];
                [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                [controllerList addObject:controllersDict];
            }
        }
        [postParam setObject:controllerList forKey:@"controllers"];
        [postParam setObject:_surveyName.text forKey:@"SURVEY_NAME"];
        [postParam setObject:_currencyBtn.titleLabel.text forKey:@"CURRENCY_VAL"];
        [postParam setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"] forKey:@"ADMIN_ID"];
        //[postParam setObject:surveyID forKey:@"SURVEY_ID"];
        
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:postParam forKey:@"DATA"];
        
        [self showLoader:YES];
        [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/insert_demog3.php" andParam:paramDict withBlock:^(id response, BOOL isSuccess) {
            
            [self showLoader:NO];
            if (isSuccess) {
                
                NSLog(@"response %@",response);
                if ([[response objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]) {
                    
                    surveyID = [response objectForKey:@"SURVEY_ID"];
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@"Alive 2.0"
                                                 message:@"Demographics data saved successfully for survey"
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    //Handle your yes please button action here
                                                    analysisTypeView *analysisTypeViewObj;
                                                    analysisTypeViewObj = [[analysisTypeView alloc]initWithNibName:@"analysisTypeView" bundle:nil];
                                                    analysisTypeViewObj.surveyName = _surveyName.text;
                                                    analysisTypeViewObj.surveyID = surveyID;
                                                    analysisTypeViewObj.surveyCurrency = _currencyBtn.titleLabel.text;
                                                    [self.navigationController pushViewController:analysisTypeViewObj animated:YES];
                                                }];
                    
                    [alert addAction:yesButton];
                    //[alert addAction:noButton];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@"Alive 2.0"
                                                 message:[response objectForKey:@"MSG"]
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:@"OK"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    
                                                }];
                    
                    [alert addAction:yesButton];
                    //[alert addAction:noButton];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            else {
                [self showAlertView:@"Alive 2.0" message:@"Failed to submit, Please try again later"];
            }
        }];
        
        NSLog(@"%@",postParam);
    }
}


- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
    // ...
}

#pragma mark - Selector Methods
- (void)deleteOptions:(UIButton *)sender {
    [self.view endEditing:YES];
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    if ([[[demographicsList objectAtIndex:section] optionList] count] > 1) {
        [[[demographicsList objectAtIndex:section] optionList] removeObjectAtIndex:row];
        [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        NSLog(@"You cant");
    }
}

- (void)deleteSection:(UIButton *)sender {
    [self.view endEditing:YES];
    NSInteger section = sender.tag / 100;

    if([[[demographicsList objectAtIndex:section] controlName] isEqualToString:@"ddl_age"] || [[[demographicsList objectAtIndex:section] controlName] isEqualToString:@"ddl_gender"] || [[[demographicsList objectAtIndex:section] controlName] isEqualToString:@"ddl_location"] ||
       [[[demographicsList objectAtIndex:section] controlName] isEqualToString:@"ddl_income"] || [[[demographicsList objectAtIndex:section] attributeType] isEqualToString:@"Old"]) {
        
        [self.collectionView performBatchUpdates:^{
            [preDefineList addObject:[demographicsList objectAtIndex:section]];
            [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]];
            [demographicsList removeObjectAtIndex:section];
            [self.collectionView reloadData];
        } completion:^(BOOL finished) {
            [self.collectionView reloadData];
            [self.demoGraphicsTableView reloadData];
        }];
        
//        [preDefineList addObject:[demographicsList objectAtIndex:section]];
//        [self.collectionView reloadData];
    }
    else {
//        [preDefineList addObject:[demographicsList objectAtIndex:section]];
//        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]];
        [demographicsList removeObjectAtIndex:section];
        [self.demoGraphicsTableView reloadData];
    }
}

- (void)addOptions:(UIButton *)sender {
    [self.view endEditing:YES];
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    
    if ([[[demographicsList objectAtIndex:section] controlName] isEqualToString:@"ddl_age"] ||
        [[[demographicsList objectAtIndex:section] controlName] isEqualToString:@"ddl_income"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"Range"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"Slider"]) {
        
        if ([[[[demographicsList objectAtIndex:section] optionList] objectAtIndex:row] isEqualToString:@"-"]) {
            NSLog(@"Not possible to add");
        }
        else {
            [[[demographicsList objectAtIndex:section] optionList] addObject:@"-"];
        }
    }
    else if([[[demographicsList objectAtIndex:section] controlName] isEqualToString:@"ddl_gender"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"RadioButton"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"DropdownList"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"CheckBox"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"TextBox"]){
        if ([[[[demographicsList objectAtIndex:section] optionList] objectAtIndex:row] isEqualToString:@""]) {
            NSLog(@"Not possible to add");
        }
        else {
            [[[demographicsList objectAtIndex:section] optionList] addObject:@""];
        }
    }
//    else if ([[[demographicsList objectAtIndex:section] attributeNameStr] isEqualToString:@"Range"] || [[[demographicsList objectAtIndex:section] inputType] isEqualToString:@"Slider"]) {
//        if ([[[[demographicsList objectAtIndex:section] optionList] objectAtIndex:row] isEqualToString:@""]) {
//            NSLog(@"Not possible to add");
//        }
//        else {
//            [[[demographicsList objectAtIndex:section] optionList] addObject:@"-"];
//        }
//    }
    [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)stateCityBtnPressed:(UIButton *)sender {
    
    NSLog(@"%@",sender.titleLabel.text);
    if ([sender.titleLabel.text rangeOfString:@"state" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        MultipleSelectViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MultipleSelectViewController"];
        controller.delegate = self;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        if ([selectedStates count]) {
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

-(void)countryBtnPressed:(UIButton *)sender {
    
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

- (void)save {

    if ([_surveyName.text isEqualToString:@""]) {
        [self showAlertView:@"Alive 2.0" message:@"Please enter survey name"];
    }
    else if([_currencyBtn.titleLabel.text isEqualToString:@"Select Currency"]) {
        [self showAlertView:@"Alive 2.0" message:@"Please select currency for the survey"];
    }
    else {
        
        NSMutableDictionary *postParam = [[NSMutableDictionary alloc] init];
        NSMutableArray *controllerList = [[NSMutableArray alloc] init];
        for (DemoGraphics *controller in demographicsList) {
            
            NSMutableDictionary *controllersDict = [[NSMutableDictionary alloc] init];
            
            if ([controller.controlName isEqualToString:@"ddl_location"]) {
                [controller.optionList replaceObjectAtIndex:0 withObject:[[countriIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                [controller.optionList replaceObjectAtIndex:1 withObject:[[stateIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                [controller.optionList replaceObjectAtIndex:2 withObject:[[cityIDs valueForKey:@"description"] componentsJoinedByString:@","]];
                
                [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                [controllersDict setObject:controller.inputType forKey:@"input_type"];
                [controllersDict setObject:controller.optionList forKey:@"options"];
                [controllersDict setObject:controller.controlName forKey:@"control_name"];
                [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                [controllerList addObject:controllersDict];
            }
            else {
                [controllersDict setObject:controller.attributeNameStr forKey:@"attribute_name"];
                [controllersDict setObject:controller.inputType forKey:@"input_type"];
                [controllersDict setObject:controller.optionList forKey:@"options"];
                [controllersDict setObject:controller.controlName forKey:@"control_name"];
                [controllersDict setObject:controller.attributeType forKey:@"attribute_type"];
                [controllersDict setObject:controller.predefineID forKey:@"predefine_id"];
                [controllerList addObject:controllersDict];
            }
        }
        [postParam setObject:controllerList forKey:@"controllers"];
        [postParam setObject:_surveyName.text forKey:@"SURVEY_NAME"];
        [postParam setObject:_currencyBtn.titleLabel.text forKey:@"CURRENCY_VAL"];
        [postParam setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"ADMIN_ID"] forKey:@"ADMIN_ID"];
        
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
        [paramDict setObject:postParam forKey:@"DATA"];
        
        [self showLoader:YES];
        [[APIManager new] postJSONRequest:@"mckinsey/PHP/_IPHONE/insert_demog3.php" andParam:paramDict withBlock:^(id response, BOOL isSuccess) {
            
            [self showLoader:NO];
            if (isSuccess) {
                
                NSLog(@"response %@",response);
                if ([[response objectForKey:@"STATUS"] isEqualToString:@"SUCCESS"]) {
                    
                }
                else {
                  
                }
            }
            else {
                [self showAlertView:@"Alive 2.0" message:@"Failed to submit, Please try again later"];
            }
        }];
        
        NSLog(@"%@",postParam);
    }
}

- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .01;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [self flashOn:v];
    }];
}

- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:.05 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1;
    } completion:^(BOOL finished) {
        [self flashOff:v];
    }];
}

#pragma mark - Location Delegate

- (void)getAllCountry:(NSArray *)countryList {
    NSLog(@"count %lu",(unsigned long)[countryList count]);
    NSLog(@"list %@",countryList);
    
    [self showLoader:YES];
    selectedCountries = [[NSMutableArray alloc] initWithArray:countryList];
    countriIDs = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"State" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *stateJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    selectedStates = [[NSMutableArray alloc] init];
    for (NSDictionary *contry in [[countryList objectAtIndex:1] objectForKey:@"COUNTRY"]) {
        if ([[contry objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            
            NSMutableDictionary *states = [[NSMutableDictionary alloc] init];
            [states setObject:[contry objectForKey:@"name"] forKey:@"COUNTRY_NAME"];
            NSMutableArray *stateArray = [[NSMutableArray alloc] init];
            for (NSDictionary *state in stateJson) {
                
                if([[contry objectForKey:@"id"] isEqualToString:[state objectForKey:@"country_id"]]) {
                    [stateArray addObject:state];
                }
            }
            [states setObject:stateArray forKey:@"STATES"];
            [selectedStates addObject:states];
            [countriIDs addObject:[contry objectForKey:@"id"]];
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
    
    for (DemoGraphics *obj in demographicsList) {
        if ([[obj controlName] isEqualToString:@"ddl_location"]) {
            [[obj optionList] replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%lu country selected",(unsigned long)[countriIDs count]]];
            [[[demographicsList objectAtIndex:[demographicsList indexOfObject:obj]] optionList] replaceObjectAtIndex:1 withObject:@"State"];
            [[[demographicsList objectAtIndex:[demographicsList indexOfObject:obj]] optionList] replaceObjectAtIndex:2 withObject:@"City"];
            [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex: [demographicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
    [self showLoader:NO];
    //[self fetchStates:countriIDs];
}

- (void)getAllState:(NSArray *)stateList {
    
    NSLog(@"%@",stateList);
    [self showLoader:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        selectedCities = [[NSMutableArray alloc] init];
        stateIDs = [[NSMutableArray alloc] init];
        selectedStates = [[NSMutableArray alloc] initWithArray:stateList];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"City" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSMutableDictionary *cityJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
       
        for(NSInteger i=1; i < [stateList count]; i++) {
            for (NSDictionary *state in [[stateList objectAtIndex:i] objectForKey:@"STATES"]) {
                if ([[state objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                    
                    NSMutableDictionary *cities = [[NSMutableDictionary alloc] init];
                    [cities setObject:[state objectForKey:@"name"] forKey:@"STATE_NAME"];
                    NSMutableArray *citiesArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *city in cityJson) {
                        
                        if([[city objectForKey:@"state_id"] isEqualToString:[state objectForKey:@"id"]]) {
                            [citiesArray addObject:city];
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
        
        dispatch_async(dispatch_get_main_queue(), ^
                                          {
            for (DemoGraphics *obj in demographicsList) {
                if ([[obj controlName] isEqualToString:@"ddl_location"]) {
                    [[obj optionList] replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%lu state selected",(unsigned long)[stateIDs count]]];
                    [[[demographicsList objectAtIndex:[demographicsList indexOfObject:obj]] optionList] replaceObjectAtIndex:2 withObject:@"City"];
                    [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex: [demographicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                }
            }
            [self showLoader:NO];
        });
    });
    //[self fetchCities:stateIDs];
}

- (void)getAllCity:(NSArray *)cityList {
    NSLog(@"%@",cityList);
    [self showLoader:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
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
    
        dispatch_async(dispatch_get_main_queue(), ^
                                      {
            for (DemoGraphics *obj in demographicsList) {
                if ([[obj controlName] isEqualToString:@"ddl_location"]) {
                    [[obj optionList] replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%lu city selected",(unsigned long)[cityIDs count]]];
                    [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:[demographicsList indexOfObject:obj]] withRowAnimation:UITableViewRowAnimationFade];
                    break;
                }
            }
            [self showLoader:NO];
        });
    });
}

//- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
//    return UIModalPresentationPopover; // 20
//}
//
//- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
//
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
//    return navController; // 21
//}

#pragma mark - NIDrop Down Delegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender
{
//    NSInteger section = sender.tag / 100;
//    NSInteger row = sender.tag % 100;
//    NSLog(@"%ld",section);
//    NSLog(@"%ld",(long)row);
//    inputTypeDropDown = nil;
//
//    CustomTableViewCell *cell = (CustomTableViewCell *)[self.demoGraphicsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
//
//    NSLog(@"%@",cell.inputTypeBtn.titleLabel.text);
//
//    //DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:section] attributeNameStr] andInputTye:cell.inputTypeBtn.titleLabel.text andOptions:[[NSMutableArray alloc]initWithArray:@[@""]]];
//
//
//    inputTypeRow = -1;
//    [self.demoGraphicsTableView beginUpdates];
//    [self.demoGraphicsTableView endUpdates];
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender withIndex:(NSInteger )index {
    
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    NSLog(@"%ld",section);
    NSLog(@"%ld",(long)row);
    inputTypeDropDown = nil;
    
    //CustomTableViewCell *cell = (CustomTableViewCell *)[self.demoGraphicsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    
    NSLog(@"%@",[inputTypeList objectAtIndex:index]);
    
    if ([[inputTypeList objectAtIndex:index] isEqualToString:@"RadioButton"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"DropdownList"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"CheckBox"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"TextBox"]) {
        DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:section] attributeNameStr] andInputTye:[inputTypeList objectAtIndex:index] andOptions:[[NSMutableArray alloc]initWithArray:@[@" "]] andControlName:[inputTypeList objectAtIndex:index] andAttributeType:@"New" andPredefineID:@""];
        
        [demographicsList replaceObjectAtIndex:section withObject:obj];
        [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        //[self.demoGraphicsTableView reloadSections: withRowAnimation:UITableViewRowAnimationFade];
    }
    else if([[inputTypeList objectAtIndex:index] isEqualToString:@"Range"] || [[inputTypeList objectAtIndex:index] isEqualToString:@"Slider"]) {
        DemoGraphics *obj = [[DemoGraphics new] initWithAttributeName:[[demographicsList objectAtIndex:section] attributeNameStr] andInputTye:[inputTypeList objectAtIndex:index] andOptions:[[NSMutableArray alloc]initWithArray:@[@"-"]] andControlName:[inputTypeList objectAtIndex:index] andAttributeType:@"New" andPredefineID:@""];
        
        [demographicsList replaceObjectAtIndex:section withObject:obj];
        [self.demoGraphicsTableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    }
    inputTypeRow = -1;
    [self.demoGraphicsTableView beginUpdates];
    [self.demoGraphicsTableView endUpdates];
}

#pragma mark - UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:self.demoGraphicsTableView];
//    CGPoint contentOffset = self.demoGraphicsTableView.contentOffset;
//
//    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
//
//    NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
//    [self.demoGraphicsTableView setContentOffset:contentOffset animated:YES];
    
    if (textField.tag == 555) {
        [self.adminQueView setFrame:CGRectMake(_adminQueView.frame.origin.x, _adminQueView.frame.origin.y-100, _adminQueView.frame.size.width, _adminQueView.frame.size.height)];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero
                                                  toView: self.demoGraphicsTableView];
        NSIndexPath *indexPath = [self.demoGraphicsTableView indexPathForRowAtPoint:buttonPosition];
        
        [self.demoGraphicsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    if (textField.tag == 555) {
        [self.adminQueView setFrame:CGRectMake(_adminQueView.frame.origin.x, _adminQueView.frame.origin.y+100, _adminQueView.frame.size.width, _adminQueView.frame.size.height)];
    }
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag != 101 && textField.tag != 555) {

        CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:self.demoGraphicsTableView];
        CGPoint contentOffset = self.demoGraphicsTableView.contentOffset;
        
        contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
        
        NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
        [self.demoGraphicsTableView setContentOffset:contentOffset animated:YES];
    }
    currentTxtField = textField;
    CGPoint touchPoint = [currentTxtField convertPoint:CGPointZero toView:_demoGraphicsTableView];
    NSIndexPath *clickedButtonIndexPath = [_demoGraphicsTableView indexPathForRowAtPoint:touchPoint];
    currentRowIndex = clickedButtonIndexPath.row;
    NSLog(@"Row index = %ld",(long)clickedButtonIndexPath.row);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag != 101 && textField.tag != 555) {

        [textField resignFirstResponder];
        CGPoint touchPoint = [currentTxtField convertPoint:CGPointZero toView:_demoGraphicsTableView];
        NSIndexPath *clickedButtonIndexPath = [_demoGraphicsTableView indexPathForRowAtPoint:touchPoint];
    
        NSLog(@"%@",[[demographicsList objectAtIndex:clickedButtonIndexPath.section] inputType]);
        if (textField.tag == 1000) {
            [[demographicsList objectAtIndex:clickedButtonIndexPath.section] setAttributeNameStr:textField.text];
        }
    
        if ([[[demographicsList objectAtIndex:clickedButtonIndexPath.section] controlName] isEqualToString:@"ddl_age"] ||
            [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] controlName] isEqualToString:@"ddl_income"] ||
            [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] inputType] isEqualToString:@"Range"] ||
            [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] inputType] isEqualToString:@"Slider"]) {
            
            NSLog(@"demo %@",[NSString stringWithFormat:@"%@",[[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] objectAtIndex:clickedButtonIndexPath.row]]);
            
            if (textField.tag == 1 || textField.tag == 2) {
                RangeHeadTableViewCell *cell = [self.demoGraphicsTableView cellForRowAtIndexPath:clickedButtonIndexPath];
                UITextField *firstTextField = (UITextField*)[cell.contentView viewWithTag:1];
                UITextField *secondTextField = (UITextField*)[cell.contentView viewWithTag:2];
                
                [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[NSString stringWithFormat:@"%@-%@",firstTextField.text,secondTextField.text]];
                cell.backgroundColor = [UIColor clearColor];//manoj changed
            }
            else if(textField.tag == 3 || textField.tag == 4) {
                RangeHeadTableViewCell *cell = [self.demoGraphicsTableView cellForRowAtIndexPath:clickedButtonIndexPath];
                UITextField *firstTextField = (UITextField*)[cell.contentView viewWithTag:3];
                UITextField *secondTextField = (UITextField*)[cell.contentView viewWithTag:4];
                
                [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[NSString stringWithFormat:@"%@-%@",firstTextField.text,secondTextField.text]];
            }
            
            
//             [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[NSString stringWithFormat:@"%@ - %@",[[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] objectAtIndex:clickedButtonIndexPath.row],textField.text]];
            
//            if (textField.tag == 1 || textField.tag == 3) {
//                [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[NSString stringWithFormat:@"%@ -",textField.text]];
//            }
//            else if (textField.tag == 2 || textField.tag == 4) {
//                NSLog(@"%@",[[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] objectAtIndex:clickedButtonIndexPath.row]);
//                [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:[NSString stringWithFormat:@"%@ %@",[[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] objectAtIndex:clickedButtonIndexPath.row],textField.text]];
//            }
    //        else if (textField.tag == 1000) {
    //            [[demographicsList objectAtIndex:clickedButtonIndexPath.section] setAttributeNameStr:textField.text];
    //        }
        }
        else if ([[[demographicsList objectAtIndex:clickedButtonIndexPath.section] controlName] isEqualToString:@"ddl_gender"]) {
            if(textField.tag == 2000) {
                [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:textField.text];
            }
    //        else if (textField.tag == 1000) {
    //             [[demographicsList objectAtIndex:clickedButtonIndexPath.section] setAttributeNameStr:textField.text];
    //        }
        }
       else if([[[demographicsList objectAtIndex:clickedButtonIndexPath.section] inputType] isEqualToString:@"RadioButton"] || [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] inputType] isEqualToString:@"DropdownList"] || [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] inputType] isEqualToString:@"CheckBox"] || [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] inputType] isEqualToString:@"TextBox"]) {
           
    //       if (textField.tag == 1000) {
    //           [[demographicsList objectAtIndex:clickedButtonIndexPath.section] setAttributeNameStr:textField.text];
    //       }
               [[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:textField.text];
       }
        //[[[demographicsList objectAtIndex:clickedButtonIndexPath.section] optionList] replaceObjectAtIndex:clickedButtonIndexPath.row withObject:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    
    if (textField.tag == 1000) {
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return newLength <= 20;
    }
    if (textField.tag == 1 || textField.tag == 2 || textField.tag == 3 || textField.tag == 4) {
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:textField.text];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
        return stringIsValid;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 150;
    
    return true;
}
#pragma mark - Utilities

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

#pragma mark - Notification
-(void)setBadgeCountZeroInPlist
{
    NSMutableArray *nameArr = [[NSMutableArray alloc]init];
    int badgeCount = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"notification_Data.plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    nameArr = [dict objectForKey:@"NOTIFICATION_DATA"];
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    
    if (nameArr != nil )
    {
        [plistDict setObject:nameArr forKey:@"NOTIFICATION_DATA"];
        [plistDict setValue:[NSNumber numberWithInt:badgeCount] forKey:@"BADGE_COUNT"];
    }
    else
    {
        
    }
    
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if(plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Data saved sucessfully");
    }
    else
    {
        NSLog(@"Data not saved");
    }
}

@end

//@interface UITextField ()
//@IBInspectable var maxLength: Int {
//    get {
//        guard let length = maxLengths[self]
//        else {
//            return Int.max
//        }
//        return length
//    }
//    set {
//        maxLengths[self] = newValue
//        addTarget(
//                  self,
//                  action: Selector("limitLength:"),
//                  forControlEvents: UIControlEvents.EditingChanged
//                  )
//    }
//}
//
//func limitLength(textField: UITextField) {
//    guard let prospectiveText = textField.text
//    where prospectiveText.characters.count > maxLength else {
//        return
//    }
//    let selection = selectedTextRange
//    text = prospectiveText.substringWithRange(
//                                              Range<String.Index>(prospectiveText.startIndex ..< prospectiveText.startIndex.advancedBy(maxLength))
//                                              )
//    selectedTextRange = selection
//}
//
//@end
//
//@end
