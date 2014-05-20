//
//  PRSocialHTTPRequest.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRSocialHTTPRequest : NSMutableURLRequest

extern NSString * const HTTPMethodGET;
extern NSString * const HTTPMethodPOST;
extern NSString * const HTTPMethodPUT;
extern NSString * const HTTPMethodHEAD;
extern NSString * const HTTPMethodDELETE;

+ (NSDictionary *)sendSynchronousRequestForURL:(NSURL *)url
                                        method:(NSString *)method
                                       headers:(NSDictionary *)headers
                                   requestBody:(NSDictionary *)requestDictionary
                               responseHeaders:(NSDictionary **)responseHeaders;
+ (void)sendAsynchronousRequestForURL:(NSURL *)url
                               method:(NSString *)method
                              headers:(NSDictionary *)headers
                          requestBody:(NSDictionary *)requestDictionary
                           completion:(void (^)(NSDictionary *responseHeaders, NSDictionary *responseDictionary))completion;

+ (PRSocialHTTPRequest *)requestForURL:(NSURL *)requestURL
                                method:(NSString *)method
                               headers:(NSDictionary *)headers
                           requestBody:(NSDictionary *)requestDictionary;

@end
