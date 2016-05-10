//
//  PhaseConstruct.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 10/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <vector>
#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>
#import "HypothesesTester.h"
using namespace std;

extern dispatch_queue_t phaseQueue;

@interface phaseConstructor : NSObject {
    NSMutableArray *phasesBuffer;
    NSTimer *timer;
    
    HypothesesTester tester;
}
- (void)addNewPhases:(NSArray *)newPhases;
- (NSArray *)constructFromBufferToLayer:(NSUInteger)layer;
- (void)flushBuffer;
+ (instancetype)shareConstructor;
@property (readwrite) void *_delegate;
@end

extern phaseConstructor *pcInstance;