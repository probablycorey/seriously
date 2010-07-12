//
//  SeriouslyJSON.m
//  Test
//
//  Created by Corey Johnson on 6/25/10.
//  Copyright 2010 Probably Interactive. All rights reserved.
//

#import "SeriouslyJSON.h"
#include <string.h>
#include "yajl_parse.h"
#include "yajl_lex.h"
#include "yajl_parser.h"
#include "yajl_bytestack.h"
#include "yajl_gen.h"

static yajl_handle hand;
static yajl_bytestack state;

enum {
    state_begin,
    state_array,
    state_hash
};

@interface SeriouslyJSON (Private)

- (id)parse:(NSString *)string;
- (void)pushDictionary;
- (void)pushDictionaryKey:(NSString *)key;
- (void)pushArray;
- (void)pop;
- (void)addDictionaryObject:(id)object;
- (void)addArrayObject:(id)object;

@end

static NSString *stringFromNonNullTerminatedString(const unsigned char *cstring, int len) {
    char *nullTerminatedString = calloc(len + 1, sizeof(unsigned char *));
    memcpy(nullTerminatedString, cstring, len);
    NSString *string = [NSString stringWithCString:nullTerminatedString encoding:NSUTF8StringEncoding];
    free(nullTerminatedString);
    return string;    
}

static int push_hash_or_array(id self, id value) {
    switch (yajl_bs_current(state)) {
        case state_hash:
            [self addDictionaryObject:value];
            break;
        case state_array:
            [self addArrayObject:value];
            break;
    }
    
    return 1;
}

static int push_null(void *self) {
    return push_hash_or_array(self, nil);
}

static int push_boolean(void *self, int boolean) {
    return push_hash_or_array(self, [NSNumber numberWithBool:boolean]);
}

static int push_number(void *self, const char *numberVal, unsigned int numberLen) {
    NSString *numberString = stringFromNonNullTerminatedString((const unsigned char *)numberVal, numberLen);
    return push_hash_or_array(self, [NSNumber numberWithDouble:[numberString doubleValue]]);
}

static int push_string(void *self, const unsigned char *string, unsigned int len) {    
    return push_hash_or_array(self, stringFromNonNullTerminatedString(string, len));
}

static int push_start_map(void *self) {
    yajl_bs_push(state, state_hash);
    [(id)self pushDictionary];
    return 1;
}

static int push_map_key(void *self, const unsigned char *string, unsigned int len) {
    [(id)self pushDictionaryKey:stringFromNonNullTerminatedString(string, len)];
    return 1;
}

static int push_end_map(void *self) {
    yajl_bs_pop(state);
    [(id)self pop];
    return 1;    
}

static int push_start_array(void *self) {
    yajl_bs_push(state, state_array);
    [(id)self pushArray];
    return 1;
}

static int push_end_array(void *self) {
    yajl_bs_pop(state);
   [(id)self pop];
    return 1;
}

static yajl_callbacks callbacks = {
    push_null,
    push_boolean,
    nil,
    nil,
    push_number,
    push_string,
    push_start_map,
    push_map_key,
    push_end_map,
    push_start_array,
    push_end_array
};

@implementation SeriouslyJSON

- (void)dealloc {
    [_currentObject release];
    [_stack release];
    [_keys release];
    [super dealloc];
}

+ (id)parse:(NSString *)string {
    id parser = [[[self alloc] init] autorelease];
    return [parser parse:string];
}

- (id)init {
    self = [super init];
    _stack = [[NSMutableArray alloc] init];
    _keys = [[NSMutableArray alloc] init];    
    return self;
}

- (id)parse:(NSString *)string {
    yajl_parser_config cfg = { .allowComments = 1, .checkUTF8 = 0 };
    yajl_status stat;
    unsigned char* error = NULL;
    char buffer[1024];
    
    hand = yajl_alloc(&callbacks, &cfg, NULL, self);
    yajl_bs_init(state, &(hand->alloc));
    yajl_bs_push(state, state_begin);
    NSLog(@"%d", yajl_bs_current(state));

    unsigned char *input = (unsigned char *)[string UTF8String];
    unsigned int length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    stat = yajl_parse(hand, input, length);
    if (stat == yajl_status_ok || stat == yajl_status_insufficient_data) {
        stat = yajl_parse_complete(hand);
    }
    
    if (stat != yajl_status_ok) {
        error = yajl_get_error(hand, 1, input, length);
        strncpy(buffer, (const char *)error, 1024);
        yajl_free_error(hand, error);
        yajl_bs_free(state);
        yajl_free(hand);
        [NSException raise:@"Seriously Error" format:@"Problem parsing JSON data %s", error];
    }
    else {
        yajl_bs_free(state);
        yajl_free(hand);
    }
    
    return _currentObject;
}

- (void)pushDictionary {
    [_stack addObject:[NSMutableDictionary dictionary]];
}

- (void)pushDictionaryKey:(NSString *)key {
    [_keys addObject:key];
}

- (void)pushArray {
    [_stack addObject:[NSMutableArray array]];
}

- (void)pop {
    [_currentObject release];
    _currentObject = [[_stack lastObject] retain];
    [_stack removeLastObject];
    
    if (_stack.count > 0) push_hash_or_array(self, _currentObject);
}

- (void)addDictionaryObject:(id)object {
    if (object) [(NSMutableDictionary *)[_stack lastObject] setObject:object forKey:[_keys lastObject]];
    [_keys removeLastObject];
}

- (void)addArrayObject:(id)object {
    if (!object) object = [NSNull null];
    [[_stack lastObject] addObject:object];
}

@end
