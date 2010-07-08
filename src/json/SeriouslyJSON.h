//
//  SeriouslyJSON.h
//  Test
//
//  Created by Corey Johnson on 6/25/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SeriouslyJSON : NSObject {
    id _currentObject;
    NSMutableArray *_stack;
    NSMutableArray *_keys;
}

+ (id)parse:(NSString *)string;

@end
