//
//  PRSocialHTTPFormDataRequest.m
//  PRSocialDemo
//
//  Created by Elethom Hunter on 5/21/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "NSString+PRSocialURLCoding.h"
#import "PRSocialHTTPFormDataRequest.h"

@implementation PRSocialHTTPFormDataRequest

+ (NSDictionary *)sendSynchronousFormDataRequestForURL:(NSURL *)url
                                               headers:(NSDictionary *)headers
                                           requestBody:(NSDictionary *)requestDictionary
                                       responseHeaders:(NSDictionary **)responseHeaders
{
    PRSocialHTTPFormDataRequest *request = [self formDataRequestForURL:url headers:headers requestBody:requestDictionary];
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"PRSocialHTTPRequest: URL connection error \n%@", error.description);
    }
    if (responseHeaders) {
        *responseHeaders = response.allHeaderFields;
    }
    NSDictionary *responseDictionary;
    if (responseData) {
        NSError *error;
        responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"PRSocialHTTPRequest: JSON parsing error \n%@", error.description);
        }
        if (!responseDictionary) {
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            responseDictionary = responseString.prs_URLDecodedDictionary;
        }
    }
    return responseDictionary;
}

+ (void)sendAsynchronousFormDataRequestForURL:(NSURL *)url
                                      headers:(NSDictionary *)headers
                                  requestBody:(NSDictionary *)requestDictionary
                                   completion:(void (^)(NSDictionary *, NSDictionary *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *responseHeaders;
        NSDictionary *responseDictionary = [self sendSynchronousFormDataRequestForURL:url
                                                                              headers:headers
                                                                          requestBody:requestDictionary
                                                                      responseHeaders:&responseHeaders];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(responseHeaders, responseDictionary);
        });
    });
}

+ (PRSocialHTTPFormDataRequest *)formDataRequestForURL:(NSURL *)requestURL headers:(NSDictionary *)headers requestBody:(NSDictionary *)requestDictionary
{
    PRSocialHTTPFormDataRequest *formDataRequest = [[PRSocialHTTPFormDataRequest alloc] initWithURL:requestURL];
    formDataRequest.HTTPMethod = HTTPMethodPOST;
    formDataRequest.allHTTPHeaderFields = headers;
    
    NSString *boundary;
    __block NSMutableData *bodyData;
    while (TRUE) {
        __block BOOL isBoundaryValid = YES;
        // Generate boundary
        NSUInteger randomStringLength = 16;
        NSMutableString *randomString = [NSMutableString stringWithCapacity:randomStringLength];
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        for (NSUInteger idx = 0; idx < randomStringLength; idx++) {
            [randomString appendString:[NSString stringWithFormat:@"%C", [letters characterAtIndex:arc4random() % letters.length]]];
        }
        boundary = [NSString stringWithFormat:@"----PRSocialHTTPFormDataBoundary%@", randomString];
        
        // Generate data
        bodyData = [NSMutableData data];
        [requestDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:[NSString class]] ||
                [key isKindOfClass:[NSNumber class]]) {
                NSMutableData *partData = [NSMutableData data];
                
                // Boundary
                [partData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                // Key
                NSString *keyString = [key prs_URLEncodedString];
                if ([obj isKindOfClass:[NSString class]] ||
                    [obj isKindOfClass:[NSNumber class]] ||
                    [obj isKindOfClass:[NSArray class]] ||
                    [obj isKindOfClass:[NSSet class]] ||
                    [obj isKindOfClass:[NSOrderedSet class]]) {
                    [partData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
                } else {
                    [partData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                // Obj
                NSData *objData;
                if ([obj isKindOfClass:[NSString class]]) {
                    objData = [obj dataUsingEncoding:NSUTF8StringEncoding];
                } else if ([obj isKindOfClass:[NSNumber class]]) {
                    objData = [[obj stringValue] dataUsingEncoding:NSUTF8StringEncoding];
                } else if ([obj isKindOfClass:[NSArray class]] ||
                           [obj isKindOfClass:[NSSet class]] ||
                           [obj isKindOfClass:[NSOrderedSet class]]) {
                    NSMutableArray *objComponents = [NSMutableArray arrayWithCapacity:[obj count]];
                    for (id objComponent in obj) {
                        NSString *objComponentString;
                        if ([objComponent isKindOfClass:[NSString class]]) {
                            objComponentString = objComponent;
                        } else if ([objComponent isKindOfClass:[NSNumber class]]) {
                            objComponentString = [objComponent stringValue];
                        }
                        if (objComponentString) {
                            [objComponents addObject:objComponentString];
                        }
                    }
                    objData = [[objComponents componentsJoinedByString:@","] dataUsingEncoding:NSUTF8StringEncoding];
                } else if ([obj isKindOfClass:[NSData class]]) {
                    objData = obj;
                    [partData appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                } else if ([obj isKindOfClass:[UIImage class]]) {
                    objData = UIImagePNGRepresentation(obj);
                    [partData appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                [partData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                if (objData && [objData rangeOfData:[boundary dataUsingEncoding:NSUTF8StringEncoding] options:0 range:NSMakeRange(0, objData.length)].location != NSNotFound) {
                    bodyData = nil;
                    isBoundaryValid = NO;
                    *stop = YES;
                } else {
                    [partData appendData:objData];
                }
                
                // End
                [partData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [bodyData appendData:partData];
            }
        }];
        
        [bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if (isBoundaryValid) {
            break;
        }
    }
    formDataRequest.HTTPBody = bodyData;
    [formDataRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [formDataRequest setValue:@(bodyData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    
    return formDataRequest;
}

@end
