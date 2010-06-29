//
//  Seriously.h
//  Prototype
//
//  Created by Corey Johnson on 6/18/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SeriouslyOperation;
@class SeriouslyResponse;

typedef void(^SeriouslyHandler)(SeriouslyResponse *response, NSError *error);
typedef void(^SeriouslyProgressHandler)(float progress, NSData *data);

extern const NSString *kSeriouslyMethod;
extern const NSString *kSeriouslyTimeout;
extern const NSString *kSeriouslyHeaders;
extern const NSString *kSeriouslyBody;
extern const NSString *kSeriouslyProgressHandler;

@interface Seriously : NSObject {
}

+ (SeriouslyOperation *)request:(id)url options:(NSDictionary *)options handler:(SeriouslyHandler)handler;
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

@end