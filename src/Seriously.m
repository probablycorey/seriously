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

+ (SeriouslyOperation *)request:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [self options];
    [options addEntriesFromDictionary:userOptions];
    
    NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy;
    NSTimeInterval timeout = 60;    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:nil cachePolicy:cachePolicy timeoutInterval:timeout];    
    
    [urlRequest setHTTPMethod:[[options objectForKey:kSeriouslyMethod] uppercaseString]];
    [urlRequest setTimeoutInterval:[[options objectForKey:kSeriouslyTimeout] doubleValue]];
    [urlRequest setAllHTTPHeaderFields:[options objectForKey:kSeriouslyHeaders]];

    if ([[urlRequest HTTPMethod] isEqual:@"POST"] || [[urlRequest HTTPMethod] isEqual:@"PUT"]) {
        url = [SeriouslyUtils url:url params:nil];
        [urlRequest setHTTPBody:[options objectForKey:kSeriouslyBody]];
    }
    else {
        url = [SeriouslyUtils url:url params:[options objectForKey:kSeriouslyBody]];
    }
    
    [urlRequest setURL:url];

    SeriouslyProgressHandler progressHandler = [options objectForKey:kSeriouslyProgressHandler];
    
    SeriouslyOperation *operation = [SeriouslyOperation operationWithRequest:urlRequest handler:handler progressHandler:progressHandler];
    [[self operationQueue] addOperation:operation];
    return operation;
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
    return [self request:url options:options handler:handler];
}

+ (SeriouslyOperation *)post:(id)url handler:(SeriouslyHandler)handler {
    return [self post:url options:nil handler:handler];
}

+ (SeriouslyOperation *)post:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"POST", kSeriouslyMethod, nil];
    [options addEntriesFromDictionary:userOptions];    
    return [self request:url options:options handler:handler];
}

+ (SeriouslyOperation *)put:(id)url handler:(SeriouslyHandler)handler {
    return [self put:url options:nil handler:handler];
}

+ (SeriouslyOperation *)put:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"PUT", kSeriouslyMethod, nil];
    [options addEntriesFromDictionary:userOptions];    
    return [self request:url options:options handler:handler];
}

+ (SeriouslyOperation *)delete:(id)url handler:(SeriouslyHandler)handler {
    return [self delete:url options:nil handler:handler];
}

+ (SeriouslyOperation *)delete:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"DELETE", kSeriouslyMethod, nil];
    [options addEntriesFromDictionary:userOptions];    
    return [self request:url options:options handler:handler];
}

@end
