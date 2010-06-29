//
//  SeriouslyOperation.h
//  Prototype
//
//  Created by Corey Johnson on 6/18/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Seriously.h"

@interface SeriouslyOperation : NSOperation {
    NSURLConnection *_connection;
    SeriouslyHandler _handler;
    SeriouslyProgressHandler _progressHandler;
    NSMutableData *_data;
    NSHTTPURLResponse *_response;
    NSError *_error;
    
    NSURLRequest *_urlRequest;
    
    BOOL _finished;
    BOOL _executing;
    BOOL _canceled;    
}

@property (getter=isFinished) BOOL finished;
@property (getter=isExecuting) BOOL executing;
@property (getter=isCanceled) BOOL canceled;

+ (id)operationWithRequest:(NSURLRequest *)urlRequest handler:(SeriouslyHandler)handler progressHandler:(SeriouslyProgressHandler)progressHandler;

- (BOOL)isCanceled;
- (void)setCanceled:(BOOL)value;
- (BOOL)isExecuting;
- (void)setExecuting:(BOOL)value;
- (BOOL)isFinished;
- (void)setFinished:(BOOL)value;


@end
