//
//  PhaseConstruct.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 10/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "PhaseConstruct.h"

#import "GCTextParser.h"

dispatch_queue_t phaseQueue = dispatch_queue_create("Phase Queue", DISPATCH_QUEUE_CONCURRENT);

#define phase_phase_gap 0.5

#define printAllPossibleSentence 0

@implementation phaseConstructor

+ (instancetype)shareConstructor {
    static phaseConstructor *ptr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ptr = [phaseConstructor new];
    });
    return ptr;
}

- (id)init {
    self = [super init];
    if (self) {
        phasesBuffer = [NSMutableArray array];
    }
    return self;
}

#define phaseConstructFailCheck if (!isMultiStagePhase) { result = @""; prefix = nil; numberOfWordForPhase = NSUIntegerMax; indexOfWordForPhase = NSUIntegerMax; break; }

- (void)construct {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Phase Construct Start" object:self];
    NSArray *array = [self constructFromBufferToLayer:phasesBuffer.count-1];
#if printAllPossibleSentence
    NSLog(@"%@", array);
#endif
    for (NSString *input in array) {
        NSString *result;
        NSArray *inputPhases = [input componentsSeparatedByString:@" "];
        NSString *prefix = nil;
        NSUInteger numberOfWordForPhase = NSUIntegerMax, indexOfWordForPhase = NSUIntegerMax;
        for (NSString *inputPhase in inputPhases) {
            NSArray *temp = [inputPhase componentsSeparatedByString:@"."];
            //Check if word is splitable
            BOOL isMultiStagePhase = temp.count > 1;
            if (isMultiStagePhase) {
                
                //Check if word is properly splited
                NSArray *temp1 = [temp[1] componentsSeparatedByString:@"_"];
                isMultiStagePhase = temp1.count > 1;
                phaseConstructFailCheck
                //Check if the word is fit the current profile
                //1. Prefix is equal
                isMultiStagePhase = (prefix == nil || [temp[0] isEqualTo:prefix]);
                phaseConstructFailCheck
                //2. Check if the state is correct
                if (prefix == nil) {
                    //Set the state if the state does not exist
                    isMultiStagePhase = ((NSString *)temp1[0]).integerValue == 0;
                    indexOfWordForPhase = 0;
                    numberOfWordForPhase = ((NSString *)temp1[1]).integerValue;
                    prefix = temp[0];
                } else {
                    //Set the state if the state does not exist
                    isMultiStagePhase = (++indexOfWordForPhase == ((NSString *)temp1[0]).integerValue);
                    isMultiStagePhase = (numberOfWordForPhase == ((NSString *)temp1[1]).integerValue);
                }
                phaseConstructFailCheck
                
                //If it's the last component, add it to the pending list and reset state
                if (numberOfWordForPhase-indexOfWordForPhase == 1)
                    if (result.length) {
                        result = [result stringByAppendingFormat:@" %@", prefix];
                    } else { result = prefix; }
                
            } else {
                if (result.length) {
                    result = [result stringByAppendingFormat:@" %@", inputPhase];
                } else result = inputPhase;
            }
        }
        
        if (tester.testHypotheses(result.UTF8String)) {
            [phasesBuffer removeAllObjects];
        }
    }
    [phasesBuffer removeAllObjects];
    dispatch_semaphore_signal([GCTextParser outputSemaphore]);
}

- (void)addNewPhases:(NSArray *)newPhases {
    [phasesBuffer addObject:newPhases];
    if (timer)
        [timer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self construct];
    });
}

/*
 * ConstructFromBufferToLayer:
 * A recursive function, start from the last frame, to the front
 * Goal: Generate all possible outcome
 */

- (NSArray *)constructFromBufferToLayer:(NSUInteger)layer {
    NSArray *endingPhase = [phasesBuffer objectAtIndex:layer];
    if (layer == 0) return endingPhase;
    NSArray *upperPart = [self constructFromBufferToLayer:layer-1];
    NSMutableArray *temp = [NSMutableArray array];
    [endingPhase enumerateObjectsWithOptions:0 usingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *temp1 = [NSMutableArray new];
        for (NSString *header in upperPart) {
            [temp1 addObject:[NSString stringWithFormat:@"%@ %@", header, obj]];
        }
        [temp addObjectsFromArray:temp1];
    }];
    return [NSArray arrayWithArray:temp];
}

- (void)flushBuffer {
    [phasesBuffer removeAllObjects];
}

@end