//
//  cardCell.m
//  mckinsey
//
//  Created by Apple on 10/8/16.
//  Copyright © 2016 Hardcastle. All rights reserved.
//

#import "cardCell.h"
#import "surveyCell.h"

@implementation cardCell
@synthesize cardNoLbl;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cellData = [[NSMutableArray alloc] init];
        self.imageData = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void) awakeFromNib{
    self.imageData = [[NSMutableArray alloc] init];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cellData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *TableIdentifier = @"surveyCell";
    surveyCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    
    if (cell == nil)
    {
        NSArray *obj ;
        {
            obj= [[NSBundle mainBundle] loadNibNamed:@"surveyCell" owner:self options:nil];
            
        }
        cell = [obj objectAtIndex:0];
    }
//    NSLog(@"Table index: %d",tableIndex);
    
    cell.levelLbl.text=[self.cellData objectAtIndex:indexPath.row];
    cell.levelImg.image = [UIImage imageWithData:[self.imageData objectAtIndex:indexPath.row]];
    // tableIndex++;
    //    [cell.levelImg setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imageUrlStr,[[levelSetArr objectAtIndex:indexPath.row] valueForKey:@"LEVEL_IMAGE_LINK"]]] placeholderImage:[UIImage imageNamed:@""]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[self delegate] tableCellDidSelect:cell];
}


@end
