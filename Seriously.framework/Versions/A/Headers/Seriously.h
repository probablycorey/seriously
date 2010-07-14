//
//  Seriously.h
//  Prototype
//
//  Created by Corey Johnson on 6/18/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SeriouslyConstants.h"

@interface Seriously : NSObject {
}

+ (SeriouslyOperation *)request:(NSMutableURLRequest *)request options:(NSDictionary *)options handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)requestURL:(id)url options:(NSDictionary *)options handler:(SeriouslyHandler)handler;
+ (NSMutableDictionary *)options;
+ (NSOperationQueue *)operationQueue;

+ (SeriouslyOperation *)get:(id)url handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)get:(id)url options:(NSDictionary *)options handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)post:(id)url handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)post:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)put:(id)url handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)put:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)delete:(id)url handler:(SeriouslyHandler)handler;
+ (SeriouslyOperation *)delete:(id)url options:(NSDictionary *)userOptions handler:(SeriouslyHandler)handler;

// Utility Methods
// ---------------
+ (NSURL *)url:(id)url params:(id)params;
+ (NSString *)formatQueryParams:(id)params;
+ (NSString *)escapeQueryParam:(id)param;

@end