//
//  GCTextParser.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/3/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCTextParser.h"
#import <stdio.h>

#import "GCDictionary.h"

#import "PhaseConstruct.h"

@implementation GCTextParser

+ (void)parseIncoming {
    
    dispatch_semaphore_t sem = [self outputSemaphore];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    printf("Please input: ");
    char tmp[1024];
    fgets(tmp, 1024, stdin);
    
    tmp[strlen(tmp)-1] = 0;
    
    GCDictionary *dictionary = [GCDictionary sharedDictionary];
    NSString *rawInput = [NSString stringWithUTF8String:tmp];
    
    rawInput = [rawInput lowercaseString];
    
    NSArray *rawWords = [rawInput componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:rawWords.count];
    [rawWords enumerateObjectsWithOptions:0 usingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
        NSArray *token = [dictionary tokensForWord:word];
        if (token) tokens[idx] = token;
        else tokens[idx] = @[];
    }];
    
    NSArray *hypothesis = [GCTextParser constructHyphtosisFromTokens:tokens];
    
    HypothesesTester *ht = new HypothesesTester;
    
    [[phaseConstructor shareConstructor] addNewPhases:hypothesis];
}

//Span the tokens
+ (NSArray *)constructHyphtosisFromTokens:(NSArray *)tokens {
    NSArray *resultingList = nil;
    for (NSArray *layer in tokens) {
        if (resultingList == nil) {
            resultingList = layer;
        } else {
            NSMutableArray *newResult = [NSMutableArray array];
            for (NSString *token in layer) {
                for (NSString *root in resultingList) {
                    [newResult addObject:[@[root, token] componentsJoinedByString:@" "]];
                }
            }
            resultingList = newResult;
        }
    }
    return [NSArray arrayWithArray:resultingList];
}

+ (dispatch_semaphore_t)outputSemaphore {
    static dispatch_semaphore_t sem;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sem = dispatch_semaphore_create(1);
    });
    return sem;
}

@end
