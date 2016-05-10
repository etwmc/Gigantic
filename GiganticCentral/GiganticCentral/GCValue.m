//
//  GCValue.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/24/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCValue.h"

@implementation GCValue
@synthesize value;

+ (void)load {
    [self initialDict];
}

- (id)initNumber:(NSNumber *)number {
    self = [super init];
    if (self) {
        value = number;
    }
    return self;
}

- (NSString *)description {
    return value.description;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [value valueForKey:key];
}

@end

@implementation GCActionResultValue
@synthesize actionResult;

@end