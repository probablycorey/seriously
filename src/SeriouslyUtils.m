//
//  SeriouslyUtils.m
//  Seriously
//
//  Created by Corey Johnson on 6/29/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import "SeriouslyUtils.h"


@implementation SeriouslyUtils

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
        id value = [params objectForKey:key];
        
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

+ (NSString *)escapeQueryParam:(NSString *)string {
	CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault,
        (CFStringRef)string,
        NULL,
        (CFStringRef)@":/?=,!$&'()*+;[]@#",
        CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

    return [(NSString *)escaped autorelease];
}

@end
