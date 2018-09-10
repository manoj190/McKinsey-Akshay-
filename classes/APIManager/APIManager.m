//
//  APIManager.m
//  mckinsey
//
//  Created by Mac on 27/02/18.
//  Copyright © 2018 Hardcastle. All rights reserved.
//

#import "APIManager.h"

static NSString *baseUrl = @"http://103.224.247.79/";

@implementation APIManager


- (void)postRequest:(NSString *)url andParam:(NSString *)paramStr withBlock:(void(^)(id response,BOOL isSuccess))requestResponse {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,url]]];
                       
                       //create the Method "GET" or "POST"
                       [request setHTTPMethod:@"POST"];
                       NSString *userUpdate;
                       
                       userUpdate = paramStr;
                       
                       //Convert the String to Data
                       NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
                       
                       //Apply the data to the body
                       [request setHTTPBody:data1];
                       
                       NSURLSession *session = [NSURLSession sharedSession];
                       [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                 NSURLResponse *response,
                                                                                 NSError *error) {
                           if (data == nil)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                   requestResponse(error,false);
                                              });
                           }
                           else
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
                                                  infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                  
                                                  requestResponse([infoDictionary objectForKey:@"DATA"],true);
                                                  
                                              });
                               //[self waterFallGraphDataWebserviceResponseResult:infoArray];
                           }
                       }] resume];
                   });
}

- (void)postJSONRequest:(NSString *)urlStr andParam:(NSDictionary *)param withBlock:(void(^)(id response,BOOL isSuccess))requestResponse {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSError *error;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,urlStr]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
        
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [request setHTTPMethod:@"POST"];
       
        NSData *postData = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
        [request setHTTPBody:postData];
        
        NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (data == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   requestResponse(error,false);
                                   NSLog(@"error with rquest : %@",error.localizedDescription);
                               });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
                                   infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   
                                   requestResponse([infoDictionary objectForKey:@"DATA"],true);
                                   
                               });
                //[self waterFallGraphDataWebserviceResponseResult:infoArray];
            }
        }];
        
        [postDataTask resume];
    });
}


- (void)postJSONRequestWithJSONResponse:(NSString *)urlStr andParam:(NSDictionary *)param withBlock:(void(^)(id response,BOOL isSuccess))requestResponse {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSError *error;
                       
                       NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                       NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
                       NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,urlStr]];
                       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
                       
                       [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                       [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                       
                       [request setHTTPMethod:@"POST"];
                       
                       NSData *postData = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
                       [request setHTTPBody:postData];
                       
                       NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                           
                           if (data == nil)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  requestResponse(error,false);
                                                  NSLog(@"error with rquest : %@",error.localizedDescription);
                                              });
                           }
                           else
                           {
                               dispatch_async(dispatch_get_main_queue(), ^
                                              {
                                                  NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
                                                  infoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                  
                                                  requestResponse(infoDictionary,true);
                                                  
                                              });
                               //[self waterFallGraphDataWebserviceResponseResult:infoArray];
                           }
                       }];
                       
                       [postDataTask resume];
                   });
}

@end

