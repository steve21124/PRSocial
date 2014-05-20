//
//  PRSocialHTTPRequest.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/20/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSString+PRSocialURLCoding.h"
#import "PRSocialHTTPRequest.h"

@implementation PRSocialHTTPRequest

NSString * const HTTPMethodGET = @"GET";
NSString * const HTTPMethodPOST = @"POST";
NSString * const HTTPMethodPUT = @"PUT";
NSString * const HTTPMethodHEAD = @"HEAD";
NSString * const HTTPMethodDELETE = @"DELETE";

+ (NSDictionary *)sendSynchronousRequestForURL:(NSURL *)url
                                        method:(NSString *)method
                                       headers:(NSDictionary *)headers
                                   requestBody:(NSDictionary *)requestDictionary
                               responseHeaders:(NSDictionary **)responseHeaders
{
    PRSocialHTTPRequest *request = [self requestForURL:url method:method headers:headers requestBody:requestDictionary];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"%s URL connection error \n%@", __PRETTY_FUNCTION__, error.description);
    }
    if (responseHeaders) {
        *responseHeaders = response.allHeaderFields;
    }
    NSDictionary *responseDictionary = nil;
    if (responseData) {
        NSError *error = nil;
        responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"%s JSON parsing error \n%@", __PRETTY_FUNCTION__, error.description);
        }
        if (!responseDictionary) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            responseDictionary = responseString.prs_URLDecodedDictionary;
        }
    }
    return responseDictionary;
}

+ (void)sendAsynchronousRequestForURL:(NSURL *)url
                               method:(NSString *)method
                              headers:(NSDictionary *)headers
                          requestBody:(NSDictionary *)requestDictionary
                           completion:(void (^)(NSDictionary *responseHeaders, NSDictionary *responseDictionary))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [self sendSynchronousRequestForURL:url
                                                                       method:method
                                                                      headers:headers
                                                                  requestBody:requestDictionary
                                                              responseHeaders:&responseHeaders];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(responseHeaders, responseDictionary);
        });
    });
}

#pragma mark - Life cycle

+ (PRSocialHTTPRequest *)requestForURL:(NSURL *)requestURL
                                method:(NSString *)method
                               headers:(NSDictionary *)headers
                           requestBody:(NSDictionary *)requestDictionary
{
    BOOL isGetMethod = [method isEqualToString:HTTPMethodGET];
    if (isGetMethod) {
        NSString *query = [NSString prs_stringWithURLEncodedDictionary:requestDictionary];
        requestURL = [NSURL URLWithString:[@[requestURL.absoluteString, query] componentsJoinedByString:@"?"]];
    }
    PRSocialHTTPRequest *request = [PRSocialHTTPRequest requestWithURL:requestURL];
    request.HTTPMethod = method;
    request.allHTTPHeaderFields = headers;
    if (!isGetMethod) {
        request.HTTPBody = [[NSString prs_stringWithURLEncodedDictionary:requestDictionary] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return request;
}

@end
