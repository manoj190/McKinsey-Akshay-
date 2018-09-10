//
//  MultipleSelectViewController.h
//  mckinsey
//
//  Created by Mac on 26/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationProtocol

@optional
- (void)getAllCountry:(NSArray *)countryList;
- (void)getAllState:(NSArray *)stateList;
- (void)getAllCity:(NSArray *)cityList;

@end

@interface MultipleSelectViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *infoArray;
@property (nonatomic, weak) NSString *locationType;
@property (nonatomic, weak) id <LocationProtocol> delegate;
@property (weak, nonatomic) IBOutlet UITableView *locationTableView;

@end
