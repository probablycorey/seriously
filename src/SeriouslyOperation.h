//
//  SeriouslyOperation.h
//  Prototype
//
//  Created by Corey Johnson on 6/18/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SeriouslyConstants.h"

@interface SeriouslyOperation : NSOperation {
    NSURLConnection *_connection;
    SeriouslyHandler _handler;
    SeriouslyProgressHandler _progressHandler;
    NSMutableData *_data;
    NSHTTPURLResponse *_response;
    NSError *_error;
    
    NSURLRequest *_urlRequest;
    
    BOOL _isFinished;
    BOOL _isExecuting;
    BOOL _isCancelled;
}

@property () BOOL isFinished;
@property () BOOL isExecuting;
@property () BOOL isCancelled;

+ (id)operationWithRequest:(NSURLRequest *)urlRequest handler:(SeriouslyHandler)handler progressHandler:(SeriouslyProgressHandler)progressHandler;

@end
