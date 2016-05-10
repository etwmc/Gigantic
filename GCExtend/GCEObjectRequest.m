//
//  GCObjectRequest.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCEObjectRequest.h"

@implementation GCEObjectRequest
@synthesize creator, type, objID;

bool objectInfote(NSString *source) {
    NSArray *arr = [source componentsSeparatedByString:@", "];
    return arr.count==3;
}

- (id)initWithString:(const char *)s remain:(char **)remain {
    self = [super init];
    if (self) {
        assert(strlen(s) > 0);
        char *temp;
        creator = strtol(s, &temp, 10); temp +=2;
        objID = strtol(temp, &temp, 10); temp +=2;
        type = (phaseType)strtol(temp, remain, 10); temp +=2;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)str {
    if (objectInfote(str)) {
        self = [super init];
        if (self) {
            NSArray *array = [str componentsSeparatedByString:@", "];
            creator = atol(((NSString *)array[0]).UTF8String);
            type = atoi(((NSString *)array[1]).UTF8String);
            objID = atol(((NSString *)array[2]).UTF8String);
        }
        return self;
    } else return nil;
}
@end
