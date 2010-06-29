//
//  SeriouslyJSON.h
//  Test
//
//  Created by Corey Johnson on 6/25/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SeriouslyJSON : NSObject {
    id _root;
    NSMutableArray *_stack;
    NSString *_key;
}

+ (id)parse:(NSString *)string;

@end
