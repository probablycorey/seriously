//
//  SeriouslyResponse.m
//  Seriously
//
//  Created by Corey Johnson on 6/28/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import "SeriouslyResponse.h"


@implementation SeriouslyResponse

@synthesize rawBody = _rawBody;
@synthesize body = _body;

- (void)dealloc {
    [_response release];
    [_rawBody release];
    [_body release];
    [super dealloc];
}

- (id)initWithResponse:(NSHTTPURLResponse *)response {
    self = [super init];
    _response = [response retain];
    
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];    
    if (signature) return signature;
    
    return [_response methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:_response];
}

@end
