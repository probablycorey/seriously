//
//  Seriously.m
//  Prototype
//
//  Created by Corey Johnson on 6/18/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import "Seriously.h"
#import "SeriouslyOperation.h"
#import "SeriouslyUtils.h"

const NSString *kSeriouslyMethod = @"kSeriouslyMethod";
const NSString *kSeriouslyTimeout = @"kSeriouslyTimeout";
const NSString *kSeriouslyHeaders = @"kSeriouslyHeaders";
const NSString *kSeriouslyBody = @"kSeriouslyBody";
const NSString *kSeriouslyProgressHandler = @"kSeriouslyProgressHandler";

@implementation Seriously

+ (SeriouslyOperation *)request:(NSMutableURLRequest *)request options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSLog(@"(%@) %@", [request HTTPMethod], [request URL]);
    
    NSMutableDictionary *options = [self options];
    [options addEntriesFromDictionary:userOptions];
    
    NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy;
    NSTimeInterval timeout = 60;    
    
    [request setCachePolicy:cachePolicy];
    [request setTimeoutInterval:timeout];
    [request setHTTPMethod:[[options objectForKey:kSeriouslyMethod] uppercaseString]];
    [request setTimeoutInterval:[[options objectForKey:kSeriouslyTimeout] doubleValue]];
    [request setAllHTTPHeaderFields:[options objectForKey:kSeriouslyHeaders]];
    
    if ([[request HTTPMethod] isEqual:@"POST"] || [[request HTTPMethod] isEqual:@"PUT"]) {
        [request setHTTPBody:[options objectForKey:kSeriouslyBody]];
    }
    
    SeriouslyProgressHandler progressHandler = [options objectForKey:kSeriouslyProgressHandler];
    
    SeriouslyOperation *operation = [SeriouslyOperation operationWithRequest:request handler:handler progressHandler:progressHandler];
    [[self operationQueue] addOperation:operation];

    return operation;
}

+ (SeriouslyOperation *)requestURL:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {    
    if ([url isKindOfClass:[NSString class]]) url = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nil];    
    if ([[request HTTPMethod] isEqual:@"POST"] || [[request HTTPMethod] isEqual:@"PUT"]) {
        url = [SeriouslyUtils url:url params:nil];
    }
    else {
        url = [SeriouslyUtils url:url params:[userOptions objectForKey:kSeriouslyBody]];
    }
    [request setURL:url];

    return [self request:request options:userOptions handler:handler];
}

+ (NSMutableDictionary *)options {
    static NSString *method = @"GET";
    static NSTimeInterval timeout = 60;
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            method, kSeriouslyMethod,
            [NSNumber numberWithInt:timeout], kSeriouslyTimeout,
            nil];
}

+ (NSOperationQueue *)operationQueue {
    static NSOperationQueue *operationQueue;
    
    if (!operationQueue) {
        operationQueue = [[NSOperationQueue alloc] init]; 
        operationQueue.maxConcurrentOperationCount = 3;
    }
    
    return operationQueue;
}


// Helper Methods
// --------------
+ (SeriouslyOperation *)get:(id)url handler:(SeriouslyHandler)handler {
    return [self get:url options:nil handler:handler];
}

+ (SeriouslyOperation *)get:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GET", kSeriouslyMethod, nil];
    [options addEntriesFromDictionary:userOptions];    
    return [self requestURL:url options:options handler:handler];
}

+ (SeriouslyOperation *)post:(id)url handler:(SeriouslyHandler)handler {
    return [self post:url options:nil handler:handler];
}

+ (SeriouslyOperation *)post:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"POST", kSeriouslyMethod, nil];
    [options addEntriesFromDictionary:userOptions];    
    return [self requestURL:url options:options handler:handler];
}

+ (SeriouslyOperation *)put:(id)url handler:(SeriouslyHandler)handler {
    return [self put:url options:nil handler:handler];
}

+ (SeriouslyOperation *)put:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"PUT", kSeriouslyMethod, nil];
    [options addEntriesFromDictionary:userOptions];    
    return [self requestURL:url options:options handler:handler];
}

+ (SeriouslyOperation *)delete:(id)url handler:(SeriouslyHandler)handler {
    return [self delete:url options:nil handler:handler];
}

+ (SeriouslyOperation *)delete:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"DELETE", kSeriouslyMethod, nil];
    [options addEntriesFromDictionary:userOptions];    
    return [self requestURL:url options:options handler:handler];
}

@end
