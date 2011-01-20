/*
 *  SeriouslyConstants.h
 *  Seriously
 *
 *  Created by Corey Johnson on 7/6/10.
 *  Copyright 2010 Probably Interactive. All rights reserved.
 *
 */

@class SeriouslyOperation;
@class SeriouslyOAuthOperation;

typedef void(^SeriouslyHandler)(id data, NSHTTPURLResponse *response, NSError *error);
typedef void(^SeriouslyProgressHandler)(float progress, NSData *data);

extern const NSString *kSeriouslyMethod;
extern const NSString *kSeriouslyTimeout;
extern const NSString *kSeriouslyHeaders;
extern const NSString *kSeriouslyBody;
extern const NSString *kSeriouslyProgressHandler;