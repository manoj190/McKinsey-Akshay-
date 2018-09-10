//
//  MultipleSelectViewController.m
//  mckinsey
//
//  Created by Mac on 26/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "MultipleSelectViewController.h"
#import "Reachability.h"
#import "loadingPage.h"
#import "LocationTableViewCell.h"
#import "APIManager.h"
#import "DemographicsViewController.h"
#import "STATES.h"

@interface MultipleSelectViewController () <UITableViewDelegate,UITableViewDataSource>
{
    loadingPage *loadingPageObj;
    NSArray *searchresult;
    
    NSMutableArray *selectedList;
    //NSMutableArray *infoArray;
    //NSMutableArray *selectedCountryList;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
//@property (weak, nonatomic) IBOutlet UITableView *locationTableview;

@end

@implementation MultipleSelectViewController
@synthesize infoArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if ([_locationType isEqualToString:@"COUNTRY"]) {
        
        //selectedList = [[NSMutableArray alloc] initWithArray:_inforArray];
        if (![infoArray count]) {
            infoArray = [[NSMutableArray alloc] init];
            selectedList = [[NSMutableArray alloc] init];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Country" ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            selectedList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            infoArray = selectedList;
        }
        else {
            selectedList = infoArray;
        }
    }
    else if ([_locationType isEqualToString:@"STATE"]) {
        //selectedList = [[NSMutableArray alloc] init];
//        for (NSDictionary *country in infoArray) {
//            STATES *obj = [[STATES alloc] init:country];
//            [selectedList addObject:obj];
//        }
        selectedList = infoArray;
    }
    else {
        selectedList = infoArray;
    }
    
    // Do any additional setup after loading the view.
    //loadingPageObj=[[loadingPage alloc]initWithNibName:@"loadingPage" bundle:nil];
    //[self showLoader:YES];
    //selectedCountryList = [[NSMutableArray alloc] init];
    //[self fetchList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([_locationType isEqualToString:@"COUNTRY"]) {
        [_delegate getAllCountry:selectedList];
    }
    else if([_locationType isEqualToString:@"STATE"]) {
        [_delegate getAllState:selectedList];
    }
    else {
        [_delegate getAllCity:selectedList];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableview Delegate/ Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_locationType isEqualToString:@"COUNTRY"]) {
        if (_searchBar.text.length > 0) {
            return 1;
        }
        return [infoArray count];
    }
    else if([_locationType isEqualToString:@"STATE"]) {
        if (_searchBar.text.length > 0) {
            return 1;
        }
        return [infoArray count];
    }
    else if([_locationType isEqualToString:@"CITY"]) {
        if (_searchBar.text.length > 0) {
            return 1;
        }
        return [infoArray count];
    }
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([_locationType isEqualToString:@"COUNTRY"]) {
        if (_searchBar.text.length > 0) {
            return [infoArray count];
        }
        return [[[infoArray objectAtIndex:section] objectForKey:@"COUNTRY"] count];
    }
    else if([_locationType isEqualToString:@"STATE"]) {
        if (_searchBar.text.length > 0) {
            return [infoArray count];
        }
        return [[[infoArray objectAtIndex:section] objectForKey:@"STATES"] count];
    }
    else {
        if (_searchBar.text.length > 0) {
            return [infoArray count];
        }
        return [[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] count];
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string;
    if ([_locationType isEqualToString:@"COUNTRY"]) {
        if (_searchBar.text.length > 0) {
            string = @"";
        }
        else {
            string = [[infoArray objectAtIndex:section] objectForKey:@"SECTION_NAME"];
        }
    }
    else if ([_locationType isEqualToString:@"STATE"]) {
        if (_searchBar.text.length > 0) {
            string = @"";
        }
        else {
            string = [[infoArray objectAtIndex:section] objectForKey:@"COUNTRY_NAME"];
        }
    }
    else if([_locationType isEqualToString:@"CITY"]) {
        if (_searchBar.text.length > 0) {
            string = @"";
        }
        else {
            string = [[infoArray objectAtIndex:section] objectForKey:@"STATE_NAME"];
        }
    }
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[LocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.titleLabel.tag = indexPath.section*1000+indexPath.row;
    cell.checkBoxBtn.tag = indexPath.section*1000+indexPath.row;
    
    if ([_locationType isEqualToString:@"COUNTRY"]) {
        NSLog(@"%ld",(long)indexPath.section);
        NSLog(@"%ld",(long)indexPath.row);
        
        if (_searchBar.text.length > 0) {
            [cell.titleLabel setTitle:[[infoArray objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
            if ([[[infoArray objectAtIndex:indexPath.row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
            }
            else {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
            }
        }
        else {
            [cell.titleLabel setTitle:[[[[infoArray objectAtIndex:indexPath.section] objectForKey:@"COUNTRY"] objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
            if ([[[[[infoArray objectAtIndex:indexPath.section] objectForKey:@"COUNTRY"] objectAtIndex:indexPath.row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
            }
            else {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
            }
        }
    }
    else if([_locationType isEqualToString:@"STATE"]) {
        if (_searchBar.text.length > 0) {
            [cell.titleLabel setTitle:[[infoArray objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
            
            if ([[[infoArray objectAtIndex:indexPath.row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
            }
            else {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
            }
        }
        else {
            [cell.titleLabel setTitle:[[[[infoArray objectAtIndex:indexPath.section] objectForKey:@"STATES"] objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
            
            if ([[[[[infoArray objectAtIndex:indexPath.section] objectForKey:@"STATES"] objectAtIndex:indexPath.row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
            }
            else {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
            }
        }
    }
    else if([_locationType isEqualToString:@"CITY"]) {
        
        if (_searchBar.text.length > 0) {
            if (![[infoArray objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
                [cell.titleLabel setTitle:[[infoArray objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
            }
            if ([[[infoArray objectAtIndex:indexPath.row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
            }
            else {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
            }
        }
        else {
            if (![[[[infoArray objectAtIndex:indexPath.section] objectForKey:@"CITIES"] objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
                [cell.titleLabel setTitle:[[[[infoArray objectAtIndex:indexPath.section] objectForKey:@"CITIES"] objectAtIndex:indexPath.row] objectForKey:@"name"] forState:UIControlStateNormal];
                
            }
            if ([[[[[infoArray objectAtIndex:indexPath.section] objectForKey:@"CITIES"] objectAtIndex:indexPath.row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
            }
            else {
                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
            }
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.titleLabel addTarget:self action:@selector(titleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.checkBoxBtn addTarget:self action:@selector(titleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%@",[[infoArray objectAtIndex:indexPath.row] objectForKey:@"COUNTRY_NAME"]);
    
//    LocationTableViewCell *cell = (LocationTableViewCell *)[self.locationTableView cellForRowAtIndexPath:indexPath];
//    [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
}

#pragma mark - Selector methods

- (void)titleBtnClicked:(UIButton *)sender {
    
    if ([_locationType isEqualToString:@"COUNTRY"]) {
        NSInteger section = sender.tag / 1000;
        NSInteger row = sender.tag % 1000;
        
        NSLog(@"%ld",section);
        
        if ([[[[[infoArray objectAtIndex:section] objectForKey:@"COUNTRY"] objectAtIndex:row] objectForKey:@"name"] isEqualToString:@"Select all"]) {
            [self selectAllCountry];
        }
        else {
            [self setSelectedCountry:section andRow:row];
        }
    }
    else if([_locationType isEqualToString:@"STATE"]) {
        NSInteger section = sender.tag / 1000;
        NSInteger row = sender.tag % 1000;
        if ([[[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] objectForKey:@"name"] isEqualToString:@"Select all"]) {
            [self selectAllState];
        }
        else {
            [self setSelectedState:section andRow:row];
        }
        //[self setSelectedState:[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row]];
    }
    else if([_locationType isEqualToString:@"CITY"]) {
        NSInteger section = sender.tag / 1000;
        NSInteger row = sender.tag % 1000;
        if ([[[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] objectForKey:@"name"] isEqualToString:@"Select all"]) {
            [self selectAllCity];
        }
        else {
            [self setSelectedCity:section andRow:row];
        }
    }
}

- (void)setSelectedCity:(NSInteger)section andRow:(NSInteger)row {
    
    if ([[[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] objectForKey:@"name"] isEqualToString:@"Select all"]) {
        if ([[[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
        }
    }
    
    if (_searchBar.text.length > 0) {
        if ([[[infoArray objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[infoArray objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
        }
        else {
            [[infoArray objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
        }
    }
    else {
        if ([[[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
        }
        else {
            [[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
        }
    }
    [self.locationTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"%@",selectedList);
}


- (void)selectAllCity {
    NSLog(@"%@",[[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] objectForKey:@"isSelected"]);
    if ([[[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
        
        NSLog(@"%@",[[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] objectForKey:@"isSelected"]);
        [[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
        
        for(NSInteger i = 0;i<[infoArray count];i++) {
            for (NSMutableDictionary *country in [[infoArray objectAtIndex:i] objectForKey:@"CITIES"]) {
                [country setObject:@"NO" forKey:@"isSelected"];
            }
        }
    }
    else {
        [[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] setObject:@"YES" forKey:@"isSelected"];
        for(NSInteger i = 0;i<[infoArray count];i++) {
            for (NSMutableDictionary *country in [[infoArray objectAtIndex:i] objectForKey:@"CITIES"]) {
                [country setObject:@"YES" forKey:@"isSelected"];
            }
        }
    }
    [self.locationTableView reloadData];
}

- (void)setSelectedState:(NSInteger)section andRow:(NSInteger)row {
    
    if ([[[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] objectForKey:@"name"] isEqualToString:@"Select all"]) {
        if ([[[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
        }
    }
    
    if (_searchBar.text.length > 0) {
        if ([[[infoArray objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[infoArray objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
        }
        else {
            [[infoArray objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
        }
    }
    else {
        if ([[[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
        }
        else {
            [[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
        }
    }
    //[self.locationTableView];
    [self.locationTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"%@",selectedList);
}


- (void)selectAllCountry {
    
    NSLog(@"%@",[[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] objectForKey:@"isSelected"]);
    if ([[[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
        
        NSLog(@"%@",[[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] objectForKey:@"isSelected"]);
        [[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
        for (NSMutableDictionary *country in [[infoArray objectAtIndex:1] objectForKey:@"COUNTRY"]) {
            [country setObject:@"NO" forKey:@"isSelected"];
        }
    }
    else {
        [[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] setObject:@"YES" forKey:@"isSelected"];
        for (NSMutableDictionary *country in [[infoArray objectAtIndex:1] objectForKey:@"COUNTRY"]) {
            [country setObject:@"YES" forKey:@"isSelected"];
        }
    }
    [self.locationTableView reloadData];
}

- (void)selectAllState {
    NSLog(@"%@",[[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] objectForKey:@"isSelected"]);
    if ([[[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
        
        NSLog(@"%@",[[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] objectForKey:@"isSelected"]);
        [[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
        
        for(NSInteger i = 0;i<[infoArray count];i++) {
            for (NSMutableDictionary *country in [[infoArray objectAtIndex:i] objectForKey:@"STATES"]) {
                [country setObject:@"NO" forKey:@"isSelected"];
            }
        }
    }
    else {
        [[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] setObject:@"YES" forKey:@"isSelected"];
        for(NSInteger i = 0;i<[infoArray count];i++) {
            for (NSMutableDictionary *country in [[infoArray objectAtIndex:i] objectForKey:@"STATES"]) {
                [country setObject:@"YES" forKey:@"isSelected"];
            }
        }
    }
    [self.locationTableView reloadData];
    
}

- (void)setSelectedCountry:(NSInteger)section andRow:(NSInteger)row {
    
    if ([[[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] objectForKey:@"name"] isEqualToString:@"Select all"]) {
        if ([[[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[[[infoArray objectAtIndex:0] objectForKey:@"COUNTRY"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
            [self.locationTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    if (_searchBar.text.length > 0) {
        if ([[[infoArray objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[infoArray objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
        }
        else {
            [[infoArray objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
        }
    }
    else {
        if ([[[[[infoArray objectAtIndex:section] objectForKey:@"COUNTRY"] objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
            [[[[infoArray objectAtIndex:section] objectForKey:@"COUNTRY"] objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
        }
        else {
            [[[[infoArray objectAtIndex:section] objectForKey:@"COUNTRY"] objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
        }
    }
    [self.locationTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"%@",selectedList);
}


//
//- (void)titleBtnPressed:(UIButton *)sender {
//    
//    //NSLog(@"%@",[_inforArray objectAtIndex:sender.tag]);
//    if ([_locationType isEqualToString:@"COUNTRY"]) {
//        
//        LocationTableViewCell *cell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
//        
//        if ([sender.titleLabel.text isEqualToString:@"Select all"]) {
//            if ([[[infoArray objectAtIndex:sender.tag] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[infoArray objectAtIndex:sender.tag] setObject:@"NO" forKey:@"isSelected"];
//                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//                //[selectedCountryList removeAllObjects];
//                for (NSMutableDictionary *dict in infoArray) {
//                    [dict setObject:@"NO" forKey:@"isSelected"];
//                }
//            }
//            else {
//                [[infoArray objectAtIndex:sender.tag] setObject:@"YES" forKey:@"isSelected"];
//                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//                //[selectedCountryList addObjectsFromArray:_inforArray];
//                //[selectedCountryList removeObjectAtIndex:0];
//                for (NSMutableDictionary *dict in infoArray) {
//                    [dict setObject:@"YES" forKey:@"isSelected"];
//                }
//            }
//            [self.locationTableView reloadData];
//        }
//        else if ([[[infoArray objectAtIndex:sender.tag] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//            
//            if ([[[infoArray objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[infoArray objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
//                LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//                [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            }
//            [[infoArray objectAtIndex:sender.tag] setObject:@"NO" forKey:@"isSelected"];
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            //[selectedCountryList removeObject:[_inforArray objectAtIndex:sender.tag]];
//        }
//        else {
//            if ([[[infoArray objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[infoArray objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
//                LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//                [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            }
//            [[infoArray objectAtIndex:sender.tag] setObject:@"YES" forKey:@"isSelected"];
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//            //[selectedCountryList addObject:[_inforArray objectAtIndex:sender.tag]];
//        }
//    }
//    else if ([_locationType isEqualToString:@"STATE"]) {
//        NSInteger section = sender.tag / 100;
//        NSInteger row = sender.tag % 100;
//        LocationTableViewCell *cell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:row inSection:section]];
//        
//        if (section == 0) {
//            
//            if ([[[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
//                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//                for (NSMutableDictionary *dict in infoArray) {
//                    for (NSMutableDictionary *state in [dict objectForKey:@"STATES"]) {
//                        [state setObject:@"NO" forKey:@"isSelected"];
//                    }
//                }
//            }
//            else {
//                [[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
//                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//                for (NSMutableDictionary *dict in infoArray) {
//                    for (NSMutableDictionary *state in [dict objectForKey:@"STATES"]) {
//                        [state setObject:@"YES" forKey:@"isSelected"];
//                    }
//                }
//            }
//            [self.locationTableView reloadData];
//        }
//        else if ([[[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//            
//            if ([[[[[infoArray objectAtIndex:section] objectForKey:@"STATES"]objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
//                LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//                [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            }
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            [[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
//        }
//        else {
//            if ([[[[[infoArray objectAtIndex:section] objectForKey:@"STATES"]objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[[[infoArray objectAtIndex:0] objectForKey:@"STATES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
//                LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//                [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            }
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//            [[[[infoArray objectAtIndex:section] objectForKey:@"STATES"] objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
//        }
//    }
//    else if([_locationType isEqualToString:@"CITY"]) {
//        NSInteger section = sender.tag / 100;
//        NSInteger row = sender.tag % 100;
//        LocationTableViewCell *cell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:row inSection:section]];
//        
//        if (section == 0) {
//            
//            if ([[[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                
//                [[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
//                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//                for (NSMutableDictionary *dict in infoArray) {
//                    for (NSMutableDictionary *state in [dict objectForKey:@"CITIES"]) {
//                        [state setObject:@"NO" forKey:@"isSelected"];
//                    }
//                }
//            }
//            else {
//                [[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
//                [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//                for (NSMutableDictionary *dict in infoArray) {
//                    for (NSMutableDictionary *state in [dict objectForKey:@"CITIES"]) {
//                        [state setObject:@"YES" forKey:@"isSelected"];
//                    }
//                }
//            }
//            [self.locationTableView reloadData];
//        }
//        else if ([[[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//            
//            if ([[[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"]objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
//                LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//                [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            }
//            
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            [[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] setObject:@"NO" forKey:@"isSelected"];
//        }
//        else {
//            if ([[[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"]objectAtIndex:row] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//                [[[[infoArray objectAtIndex:0] objectForKey:@"CITIES"] objectAtIndex:0] setObject:@"NO" forKey:@"isSelected"];
//                LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//                [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            }
//            
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//            [[[[infoArray objectAtIndex:section] objectForKey:@"CITIES"] objectAtIndex:row] setObject:@"YES" forKey:@"isSelected"];
//        }
//    }
//}

#pragma MARK - Search Bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)SearchBar
{
    DemographicsViewController *obj = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"DemographicsViewController"];
    NSLog(@"%ld",(long)SearchBar.tag);
    obj.currentTxtField.tag = SearchBar.tag;
    SearchBar.showsCancelButton=YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)SearchBar
{
    SearchBar.text = @"";
    //_currencyList = @[@"Afghanistan",@"Akrotiri and Dhekelia",@"Bahamas",@"Bolivia",@"Cambodia",@"Chad",@"Denmark"];
    infoArray = [[NSMutableArray alloc] initWithArray:selectedList];
    SearchBar.showsCancelButton=NO;
    [SearchBar resignFirstResponder];
    [_locationTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)SearchBar
{
    SearchBar.showsCancelButton=NO;
    [SearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 0)
    {
        [self filterContentForSearchText:searchText];
    }
    else {
        infoArray = [[NSMutableArray alloc] initWithArray:selectedList];
        searchBar.showsCancelButton = NO;;
            [searchBar resignFirstResponder];
        [_locationTableView reloadData];
    }
}


-(void) filterContentForSearchText:(NSString *)searchText
{
    NSPredicate *resultPredicate;
    if ([_locationType isEqualToString:@"COUNTRY"]) {
        resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",
                           searchText];
        infoArray = [[NSMutableArray alloc] initWithArray:[[[selectedList objectAtIndex:1] objectForKey:@"COUNTRY"] filteredArrayUsingPredicate:resultPredicate]];
    }
    else if([_locationType isEqualToString:@"STATE"]) {
        
        infoArray = [[NSMutableArray alloc] init];
        for (NSDictionary *stateDict in selectedList) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
            tempArray = [[NSMutableArray alloc] initWithArray:[[stateDict objectForKey:@"STATES"] filteredArrayUsingPredicate:resultPredicate]];
            [infoArray addObjectsFromArray:tempArray];
        }
//        resultPredicate = [NSPredicate predicateWithFormat:@"COUNTRY_NAME contains[c] %@",searchText];
//        infoArray = [[NSMutableArray alloc] initWithArray:[selectedList filteredArrayUsingPredicate:resultPredicate]];
    }
    else {
        infoArray = [[NSMutableArray alloc] init];
        for (NSDictionary *stateDict in selectedList) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@",searchText];
            tempArray = [[NSMutableArray alloc] initWithArray:[[stateDict objectForKey:@"CITIES"] filteredArrayUsingPredicate:resultPredicate]];
            [infoArray addObjectsFromArray:tempArray];
        }
//        resultPredicate = [NSPredicate predicateWithFormat:@"CITY_NAME contains[c] %@",
//                           searchText];
//         infoArray = [[NSMutableArray alloc] initWithArray:[selectedList filteredArrayUsingPredicate:resultPredicate]];
    }
    
    
    //searchresult = [_inforArray filteredArrayUsingPredicate:resultPredicate];
    NSLog(@"%@",searchresult);
    [_locationTableView reloadData];
}


//- (void)checkBoxBtnPressed:(UIButton *)sender {
//    NSLog(@"%ld",(long)sender.tag);
//
//    LocationTableViewCell *cell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
//
//    NSLog(@"%@",[infoArray objectAtIndex:sender.tag]);
//
//    if (sender.tag == 0) {
//
//        if ([[[infoArray objectAtIndex:sender.tag] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//            [[infoArray objectAtIndex:sender.tag] setObject:@"NO" forKey:@"isSelected"];
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//            for (NSMutableDictionary *dict in infoArray) {
//                [dict setObject:@"NO" forKey:@"isSelected"];
//            }
//        }
//        else {
//            [[infoArray objectAtIndex:sender.tag] setObject:@"YES" forKey:@"isSelected"];
//            [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//            for (NSMutableDictionary *dict in infoArray) {
//                [dict setObject:@"YES" forKey:@"isSelected"];
//            }
//        }
//        [self.locationTableView reloadData];
//    }
//    else if ([[[infoArray objectAtIndex:sender.tag] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//
//        if ([[[infoArray objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//            [[infoArray objectAtIndex:sender.tag] setObject:@"NO" forKey:@"isSelected"];
//            LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//            [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//        }
//        [[infoArray objectAtIndex:sender.tag] setObject:@"NO" forKey:@"isSelected"];
//        [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//    }
//    else {
//        if ([[[infoArray objectAtIndex:0] objectForKey:@"isSelected"] isEqualToString:@"YES"]) {
//            [[infoArray objectAtIndex:sender.tag] setObject:@"NO" forKey:@"isSelected"];
//            LocationTableViewCell *selectAllCell = [self.locationTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//            [selectAllCell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
//        }
//        [[infoArray objectAtIndex:sender.tag] setObject:@"YES" forKey:@"isSelected"];
//        [cell.checkBoxBtn setBackgroundImage:[UIImage imageNamed:@"checkedbox"] forState:UIControlStateNormal];
//    }
//}

@end
