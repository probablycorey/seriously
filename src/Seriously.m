//
//  Seriously.m
//  Prototype
//
//  Created by Corey Johnson on 6/18/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import "Seriously.h"
#import "SeriouslyOperation.h"

const NSString *kSeriouslyMethod = @"kSeriouslyMethod";
const NSString *kSeriouslyTimeout = @"kSeriouslyTimeout";
const NSString *kSeriouslyHeaders = @"kSeriouslyHeaders";
const NSString *kSeriouslyBody = @"kSeriouslyBody";
const NSString *kSeriouslyProgressHandler = @"kSeriouslyProgressHandler";
const NSString *kSeriouslyPostDictionary = @"kSeriouslyPostDictionary";

@implementation Seriously

+ (SeriouslyOperation *)request:(NSMutableURLRequest *)request options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {
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
		if([options objectForKey:kSeriouslyPostDictionary]){
			NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
			[request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
			[request setHTTPBody:[self buildURLEncodedPostBodyWithKeys:[options objectForKey:kSeriouslyPostDictionary]]];
		} else {
			[request setHTTPBody:[options objectForKey:kSeriouslyBody]];
		}
    }

    NSLog(@"(%@) %@", [request HTTPMethod], [request URL]);
    
    SeriouslyProgressHandler progressHandler = [options objectForKey:kSeriouslyProgressHandler];
    
    SeriouslyOperation *operation = [SeriouslyOperation operationWithRequest:request handler:handler progressHandler:progressHandler];
    [[self operationQueue] addOperation:operation];

    return operation;
}

+ (SeriouslyOperation *)requestURL:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler {    
    if ([url isKindOfClass:[NSString class]]) url = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nil];  
    NSString *method = [[userOptions objectForKey:kSeriouslyMethod] uppercaseString];
    if ([method isEqual:@"POST"] || [method isEqual:@"PUT"]) {
        url = [self url:url params:nil];
    }
    else {
        url = [self url:url params:[userOptions objectForKey:kSeriouslyBody]];
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

// Utility Methods
// ---------------
+ (NSURL *)url:(id)url params:(id)params {
    if (!params) {
        return [url isKindOfClass:[NSString string]] ? [NSURL URLWithString:url] : url;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", url, [self formatQueryParams:params]];    
    
    NSLog(@"GOT IT %@", urlString);
    return [NSURL URLWithString:urlString];    
}

+ (NSString *)formatQueryParams:(id)params {
    if (![params isKindOfClass:[NSDictionary class]]) return params;
    
    NSMutableArray *pairs = [NSMutableArray array];
    for (id key in params) {
        id value = [(NSDictionary *)params objectForKey:key];
        
        if ([value isKindOfClass:[NSArray class]]) { 
            for (id v in value) { 
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, [self escapeQueryParam:v]]];
            } 
        } 
        else { 
            [pairs addObject:[NSString stringWithFormat:@"%@=%@",key, [self escapeQueryParam:value]]]; 
        }         
    }
    
    return [pairs componentsJoinedByString:@"&"]; 
}

+ (NSString *)escapeQueryParam:(id)param {
    if (![param isKindOfClass:[NSString class]]) param = [NSString stringWithFormat:@"%@", param];
    
	CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(
                                                                  kCFAllocatorDefault,
                                                                  (CFStringRef)param,
                                                                  NULL,
                                                                  (CFStringRef)@":/?=,!$&'()*+;[]@#",
                                                                  CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    return [(NSString *)escaped autorelease];
}

+ (NSData *)buildURLEncodedPostBodyWithKeys:(NSDictionary *)keys {
	NSMutableData *postBody = [NSMutableData data];
	
	__block NSUInteger i = 0;
	NSUInteger count = [keys count] - 1;
	[keys enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		NSString *data = [NSString stringWithFormat:@"%@=%@%@", [self escapeQueryParam:key], [self escapeQueryParam:obj], (i < count) ?  @"&" : @""];
		[postBody appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
		i++;
	}];
	
	NSLog(@"Generated POST Body: %@", [[[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding] autorelease]);
	
	return [NSData dataWithData:postBody];
}

@end
