//
//  SeriouslyUtils.h
//  Seriously
//
//  Created by Corey Johnson on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SeriouslyUtils : NSObject {}

+ (NSURL *)url:(id)url params:(id)params;
+ (NSString *)formatQueryParams:(id)params;
+ (NSString *)escapeQueryParam:(NSString *)string;

@end
