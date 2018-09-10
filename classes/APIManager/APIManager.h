//
//  APIManager.h
//  mckinsey
//
//  Created by Mac on 27/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIManager : NSObject <NSURLSessionDelegate>


- (void)postRequest:(NSString *)url andParam:(NSString *)paramStr withBlock:(void(^)(id response,BOOL isSuccess))requestResponse;

- (void)postJSONRequest:(NSString *)url andParam:(NSDictionary *)paramStr withBlock:(void(^)(id response,BOOL isSuccess))requestResponse;

- (void)postJSONRequestWithJSONResponse:(NSString *)url andParam:(NSDictionary *)paramStr withBlock:(void(^)(id response,BOOL isSuccess))requestResponse;

@end
