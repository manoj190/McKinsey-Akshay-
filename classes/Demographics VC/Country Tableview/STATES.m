//
//  STATES.m
//  mckinsey
//
//  Created by Akshay Ambekar on 05/03/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "STATES.h"

@implementation STATES

- (id)init:(NSDictionary *)stateDict {
    
    if (self = [super init]) {
        
        self.countryID = [stateDict objectForKey:@"COUNTRY_ID"];
        self.countryName = [stateDict objectForKey:@"COUNTRY_NAME"];
        
        for (NSDictionary *state in [stateDict objectForKey:@"STATES"]) {
            NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
            
            if ([state objectForKey:@"STATE_ID"]) {
                [obj setObject:[state objectForKey:@"STATE_ID"] forKey:@"STATE_ID"];
            }
            
            [obj setObject:[state objectForKey:@"STATE_NAME"] forKey:@"STATE_NAME"];
            [obj setObject:[state objectForKey:@"isSelected"] forKey:@"isSelected"];
            [self.statesList addObject:state];
        }        
    }
    return self;
}

@end
