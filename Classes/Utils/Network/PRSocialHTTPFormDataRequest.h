//
//  PRSocialHTTPFormDataRequest.h
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/21/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRSocialHTTPRequest.h"

@interface PRSocialHTTPFormDataRequest : PRSocialHTTPRequest

+ (NSDictionary *)sendSynchronousFormDataRequestForURL:(NSURL *)url
                                               headers:(NSDictionary *)headers
                                           requestBody:(NSDictionary *)requestDictionary
                                       responseHeaders:(NSDictionary **)responseHeaders;
+ (void)sendAsynchronousFormDataRequestForURL:(NSURL *)url
                                      headers:(NSDictionary *)headers
                                  requestBody:(NSDictionary *)requestDictionary
                                   completion:(void (^)(NSDictionary *responseHeaders, NSDictionary *responseDictionary))completion;

+ (PRSocialHTTPFormDataRequest *)formDataRequestForURL:(NSURL *)requestURL
                                               headers:(NSDictionary *)headers
                                           requestBody:(NSDictionary *)requestDictionary;

@end
