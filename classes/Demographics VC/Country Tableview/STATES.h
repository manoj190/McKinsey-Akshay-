//
//  STATES.h
//  mckinsey
//
//  Created by Akshay Ambekar on 05/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STATES : NSObject

@property (nonatomic,strong)  NSString *countryName;
@property (nonatomic,strong)  NSString *countryID;
@property (nonatomic,strong)  NSMutableArray *statesList;
@property (nonatomic,strong)  NSString *stateID;
@property (nonatomic,strong)  NSString *stateName;
@property (nonatomic,strong)  NSString *isSelected;

- (id)init:(NSDictionary *)stateDict;
@end
