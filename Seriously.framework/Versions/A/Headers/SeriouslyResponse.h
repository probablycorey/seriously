//
//  SeriouslyResponse.h
//  Seriously
//
//  Created by Corey Johnson on 6/28/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SeriouslyResponse : NSObject {
    NSHTTPURLResponse *_response;
    NSData *_rawBody;
    id _body;    
}

@property (nonatomic, retain) NSData *rawBody;
@property (nonatomic, retain) id body;

- (id)initWithResponse:(NSHTTPURLResponse *)response;

@end
