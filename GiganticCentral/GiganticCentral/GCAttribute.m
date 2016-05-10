//
//  GCAttribute.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/6/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCAttribute.h"

@interface GCAttribute () {
    void(^_longFetchBlock)();
    void(^_completitionBlock)();
    NSString *reply;
}
@property (readonly) BOOL outputedOnce;

@end

@implementation GCAttribute
@synthesize ready, fetching;

@synthesize longFetchBlock, completitionBlock, outputedOnce;

- (id)initWithAttributeFetch:(id(^)())fetcher {
    self = [super init];
    if (self) {
        _fetcher = fetcher;
        _completitionBlock = ^{};
    }
    return self;
}

- (void)prepareAttribute {
    //Can't all repeatly
    if (ready||fetching) return;
    dispatch_async([GCAttribute dispatchQueue], ^{
        id result = _fetcher();
        [self valueChange:result];
        if (self.outputedOnce) {
            //If outputed the long fetch, wait 5 seconds before output the result
            sleep(5);
            reply = completitionBlock(result);
            [self voiceOutput:self.description];
        }
    });
    reply = longFetchBlock();
}

- (void)valueChange:(id)result {
    _completitionBlock();
}

+ (dispatch_queue_t)dispatchQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("Attribute Query Queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

- (NSString *)description { outputedOnce = true; return reply; }

@end
