//
//  GCVoiceParser.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 5/2/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCVoiceParser.h"

#import "GCDictionary.h"

#import "PhaseConstruct.h"

#import <AppKit/AppKit.h>

@interface GCVoiceParser () <NSSpeechRecognizerDelegate> {
    NSTimer *timer;
    NSString *rawInput;
    NSSpeechRecognizer *recoginzer;
}
@end

@implementation GCVoiceParser

- (id)init{
    self = [super init];
    return self;
}

- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)command {
    
    if (rawInput)
        rawInput = [rawInput stringByAppendingFormat:@" %@", command];
    else
        rawInput = command;
    
    if (timer) {
        [timer invalidate];
    }
    
    timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(handle) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)handle {
    
    [recoginzer stopListening];
    
    GCDictionary *dictionary = [GCDictionary sharedDictionary];
    
    rawInput = [rawInput lowercaseString];
    
    NSArray *rawWords = [rawInput componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    rawInput = nil;
    
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

+ (instancetype)sharedParser {
    static GCVoiceParser *parser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [GCVoiceParser new];
    });
    return parser;
}

- (void)launch {
    GCDictionary *dictionary = [GCDictionary sharedDictionary];
    
    recoginzer = [NSSpeechRecognizer new];
    
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:dictionary.dictionary];
    recoginzer.commands = [dict.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.length;
    }]];
    
    recoginzer.delegate = self;
    
    printf("Please press enter");
    char tmp[1024];
    fgets(tmp, 1024, stdin);
    
    [recoginzer startListening];
}

+ (void)parseIncoming {
    
    dispatch_semaphore_t sem = [self outputSemaphore];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    static GCVoiceParser *parser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [GCVoiceParser new];
    });
    
    sleep(1);
    
    [parser launch];
    
}

@end
