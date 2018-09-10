//
//  cardCell.h
//  mckinsey
//
//  Created by Apple on 10/8/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import <UIKit/UIKit.h>
@class cardCell;
@protocol ColectionCellDelegate
-(void)tableCellDidSelect:(UITableViewCell *)cell;
@end




@interface cardCell : UICollectionViewCell<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *cardNoLbl;
@property (strong, nonatomic) IBOutlet UITableView *optionTable;
@property(strong,nonatomic) NSMutableArray *cellData;
@property(strong,nonatomic) NSMutableArray *imageData;
@property(strong,nonatomic) id<ColectionCellDelegate> delegate;


@end
