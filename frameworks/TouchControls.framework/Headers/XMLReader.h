//
//  XMLReader.h
//  Sample DataGrid
//
//  Created by SmrtX on 7/25/2014.
//  Copyright (c) 2014 SmrtX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *errorPointer;
}

+ (NSDictionary *)dataToDictionary:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)XMLtoDictionary:(NSString *)string error:(NSError **)errorPointer;

@end