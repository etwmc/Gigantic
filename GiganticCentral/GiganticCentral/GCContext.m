//
//  GCContext.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 12/15/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCContext.h"

@implementation GCContext

- (GCTime *)currentTimeWithMask:(NSNumber *)mask {
    return [[GCTime alloc] initWithDate:[NSDate date] withResolution:mask.shortValue];
}

+ (NSString *)routingName {
    return @"Context";
}

+ (GCContext *)currentContext {
    static GCContext *obj = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [GCContext new];
    });
    return obj;
}

+ (void)load {
    [self initialDict];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [[self currentTimeWithMask:@4] valueForKey:key];
}

@end
