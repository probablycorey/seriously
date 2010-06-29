//
//  SeriouslyOperation.m
//  Prototype
//
//  Created by Corey Johnson on 6/18/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import "SeriouslyOperation.h"
#import "SeriouslyJSON.h"
#import "SeriouslyResponse.h"

@interface SeriouslyOperation (Private)

- (id)initWithRequest:(NSURLRequest *)urlRequest handler:(SeriouslyHandler)handler progressHandler:(SeriouslyProgressHandler)progressHandler;
- (id)parsedData;

@end


@implementation SeriouslyOperation

- (void)dealloc {
    [_connection release];
    [_handler release];
    [_progressHandler release];
    [_response release];
    [_data release];
    [_error release];
    
    [super dealloc];
}

+ (id)operationWithRequest:(NSURLRequest *)urlRequest handler:(SeriouslyHandler)handler progressHandler:(SeriouslyProgressHandler)progressHandler {
    return [[self alloc] initWithRequest:urlRequest handler:handler progressHandler:progressHandler];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest handler:(SeriouslyHandler)handler progressHandler:(SeriouslyProgressHandler)progressHandler {
    self = [super init];
    //_connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    _handler = [handler copy];
    _progressHandler = [progressHandler copy];
    _data = [[NSMutableData alloc] init];
    
    _finished = NO;
    _canceled = NO;
    _executing = NO;
    
    _urlRequest = [urlRequest retain];
    
    return self;
}

- (void)start {
    if (self.isCanceled || self.isFinished) return;

    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    self.executing = YES;    
    _connection = [[NSURLConnection alloc] initWithRequest:_urlRequest delegate:self];
    [_connection start];

}

- (void)cancel {
    self.canceled = YES;
    [_connection cancel];
    
    self.finished = YES;
    self.executing = NO;
    [super cancel];
    [self autorelease];
}

- (void)sendHandler:(NSURLConnection *)connection {
    if (self.isCanceled) [NSException raise:@"Seriously error" format:@"OH NO, THE URL CONNECTION WAS CANCELED BUT NOT CAUGHT"];
    
    SeriouslyResponse *response = [[SeriouslyResponse alloc] initWithResponse:_response];
    response.rawBody = _data;
    response.body = [self parsedData];

    _handler(response, _error);
    
    self.finished = YES;
    self.executing = NO;
    [self autorelease];
}

- (id)parsedData {
    NSString *contentType = [[_response allHeaderFields] objectForKey:@"Content-Type"];

    if ([contentType hasPrefix:@"application/json"] ||
        [contentType hasPrefix:@"text/json"] ||
        [contentType hasPrefix:@"application/javascript"] ||
        [contentType hasPrefix:@"text/javascript"]) {
        
        NSString *text = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        id result = [SeriouslyJSON parse:text];
        [text release];
     
        return result;
    }
    else if ([contentType hasPrefix:@"image/"] ||
                 [contentType hasPrefix:@"audio/"] ||
                 [contentType hasPrefix:@"application/octet-stream"]) {

        return _data;
    }
    else {
        NSString *text = [[[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding] autorelease];
        return text;
    }

        
}

// NSURLConnection Delegate
// ------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (response != _response) {
        [_response release];
        _response = [response retain];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    // Not implemented yet.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
    
    if (_progressHandler) {
        float percentComplete = _data.length / [[[_response allHeaderFields] objectForKey:@"Content-Length"] floatValue];
        _progressHandler(percentComplete, _data);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (!self.isCanceled) {
        _error = [error retain];
        [_data release];
        _data = nil;
        [self sendHandler:connection];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {    
    if (!self.isCanceled) [self sendHandler:connection];
}

- (BOOL)isCanceled { return _canceled; }
- (void)setCanceled:(BOOL)value { _canceled = value; }

- (BOOL)isExecuting { return _executing; }
- (void)setExecuting:(BOOL)value { NSLog(@"NO"); _executing = value; }

- (BOOL)isFinished { return _finished; }
- (void)setFinished:(BOOL)value { _finished = value; }

@end