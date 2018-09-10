//
//  CurrencyViewController.m
//  mckinsey
//
//  Created by Mac on 20/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "CurrencyViewController.h"
#import "CurrencyTableViewCell.h"

@interface CurrencyViewController () <UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate>
{
    //NSArray *currencyList;
    NSArray *searchresult;
    NSArray *currencyList;
    BOOL isSearch;
}

@property (weak, nonatomic) IBOutlet UITableView *currencyTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation CurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //currencyList = @[@"Afghanistan",@"Akrotiri and Dhekelia",@"Bahamas",@"Bolivia",@"Cambodia",@"Chad",@"Denmark"];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Currency" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    currencyList = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    
    //[_currencyList removeObjectAtIndex:0];
    isSearch = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview Datasource, Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_searchBar.text.length > 0) {
        return 1;
    }
    return [currencyList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchBar.text.length > 0) {
        return [searchresult count];
    }
    return [[[currencyList objectAtIndex:section] objectForKey:@"CURRENCY"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CurrencyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CurrencyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if(_searchBar.text.length > 0) {
        cell.currencyName.text = [NSString stringWithFormat:@"%@ - %@",[[searchresult objectAtIndex:indexPath.row] objectForKey:@"currency_code"],[[searchresult objectAtIndex:indexPath.row] objectForKey:@"currency_name"]];
    }
    else {
        cell.currencyName.text = [NSString stringWithFormat:@"%@ - %@",[[[[currencyList objectAtIndex:indexPath.section] objectForKey:@"CURRENCY"] objectAtIndex:indexPath.row] objectForKey:@"currency_code"],[[[[currencyList objectAtIndex:indexPath.section] objectForKey:@"CURRENCY"] objectAtIndex:indexPath.row] objectForKey:@"currency_name"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchBar.text.length > 0) {
        [_delegate setCurrency:searchresult[indexPath.row]];
    }
    else {
        [_delegate setCurrency:[[[currencyList objectAtIndex:indexPath.section] objectForKey:@"CURRENCY"] objectAtIndex:indexPath.row]];
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string;
    if (section == 0) {
        string = @"MOSTLY USED";
    }
    else {
        string = @"ALL";
    }
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}


#pragma MARK - Search Bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)SearchBar
{
    SearchBar.showsCancelButton=YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)SearchBar
{
    SearchBar.text = @"";
    SearchBar.showsCancelButton=NO;
    [SearchBar resignFirstResponder];
    [_currencyTable reloadData];
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
        [_currencyTable reloadData];
    }
}


-(void) filterContentForSearchText:(NSString *)searchText
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"(currency_name contains[c] %@) OR (currency_code contains[c] %@)",
                                    searchText,searchText];
    searchresult = [[[currencyList objectAtIndex:1] objectForKey:@"CURRENCY"] filteredArrayUsingPredicate:resultPredicate];
    NSLog(@"%@",searchresult);
    [_currencyTable reloadData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
