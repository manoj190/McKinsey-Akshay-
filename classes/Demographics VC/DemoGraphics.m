//
//  DemoGraphics.m
//  mckinsey
//
//  Created by Mac on 21/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "DemoGraphics.h"

@implementation DemoGraphics

- (id)initWithAttributeName:(NSString *)AttributeName andInputTye:(NSString *)inputType andOptions:(NSMutableArray *)options andControlName:(NSString *)controlName andAttributeType:(NSString *)type andPredefineID:(NSString *)preID {
    self = [super init];
    if (self) {
        self.attributeNameStr = AttributeName;
        self.inputType = inputType;
        self.optionList = options;
        self.controlName = controlName;
        self.attributeType = type;
        self.predefineID = preID;
    }
    return self;
}

@end
