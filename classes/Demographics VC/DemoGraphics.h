//
//  DemoGraphics.h
//  mckinsey
//
//  Created by Mac on 21/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoGraphics : NSObject

@property (nonatomic,strong) NSString *attributeNameStr;
@property (nonatomic,strong) NSString *inputType;
@property (nonatomic,strong) NSMutableArray *optionList;
@property (nonatomic,strong) NSString *controlName;
@property (nonatomic,strong) NSString *attributeType;
@property (nonatomic,strong) NSString *predefineID;


- (id)initWithAttributeName:(NSString *)AttributeName andInputTye:(NSString *)inputType andOptions:(NSMutableArray *)options andControlName:(NSString *)controlName andAttributeType:(NSString *)type andPredefineID:(NSString *)preID;

@end
