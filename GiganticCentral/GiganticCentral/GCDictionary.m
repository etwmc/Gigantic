//
//  GCDictionary.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/1/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCDictionary.h"

#import "GCObject.h"

#import "GCExtensionObject.h"

@interface GCDictionary () {
    NSMutableSet *registedID;
    
}
@end

@implementation GCDictionary
@synthesize dictionary;

+ (instancetype)sharedDictionary {
    static GCDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [GCDictionary new];
    });
    return dict;
}

- (id)init {
    self = [super init];
    if (self) {
        registedID = [NSMutableSet new];
        dictionary = [NSMutableDictionary new];
        
        [self setupConstant];
    }
    return self;
}

- (void)setupConstant {
    [self constants:@[@"he", @"she", @"it", @"you", @"i", @"they", @"we", @"that", @"this"]];
    [self constants:@[@"him", @"its", @"your", @"me", @"them", @"us"]];
    [self constants:@[@"his", @"her", @"its", @"their", @"our", @"my", @"your"]];
    [self constants:@[@"do", @"does", @"did", @"done"]];
    [self constants:@[@"good", @"thank", @"thanks"]];
    [self constants:@[@"what", @"when", @"where", @"who", @"whose", @"how", @"when", @"which"]];
    [self constants:@[@"is", @"am", @"are", @"was", @"were", @"been"]];
    [self constants:@[@"is", @"am", @"are", @"was", @"were", @"been"]];
    
    [self constants:@[@"on", @"in", @"to", @"by", @"for", @"with", @"at", @"of", @"from"]];
    
    [self constants:@[@"morning", @"afternoon", @"evening", @"hello"]];
    
    [self blands:@[@"a", @"an", @"the"]];
    
    [self registerKey:@"her" withValue:@"her1"];
}

- (void)blands:(NSArray *)words {
    for (NSString *word in words) {
        [self bland:word];
    }
}

- (void)bland:(NSString *)word {
    dictionary[word] = @"";
}

- (void)constants:(NSArray *)words {
    for (NSString *word in words) {
        [self constant:word];
    }
}

- (void)constant:(NSString *)word {
    dictionary[word] = word;
}

char phaseTypeSymbol(phaseType type) {
    switch (type) {
        case phaseType_adjective:
            return 'a';
        case phaseType_instance:
            return 'i';
        case phaseType_verb:
            return 'v';
        case phaseType_noun:
            return 'n';
        default:
            return 0;
    }
}

- (void)registerKey:(NSString *)key withValue:(NSString *)value {
    NSString *currentValue = dictionary[key];
    if (currentValue) {
        dictionary[key] = [NSString stringWithFormat:@"%@|%@", currentValue, value];
    } else {
        [dictionary setObject:value forKey:key];
    }
}

- (void)pollAtObject:(GCObject *)sender typeID:(NSNumber *)typeID phaseType:(phaseType)type {
    NSArray *list;
    if ([sender isKindOfClass:[GC_Extension class]])
        list = [(GC_Extension *)sender vocabulatory:type];
    else
        list = [sender.class vocabulatory:type];
    //if (list && list.count) NSLog(@"%@", list);
    NSMutableDictionary *actualDict = [NSMutableDictionary new];
    [list enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *tag = [NSString stringWithFormat:@"%@_%c%lu", typeID, phaseTypeSymbol(type), (unsigned long)idx];
        if ([obj containsString:@" "]) {
            //Cut the string into separate components, and register as a fragement
            NSArray *fragments = [obj componentsSeparatedByString:@" "];
            [fragments enumerateObjectsUsingBlock:^(NSString *fragment, NSUInteger idx, BOOL *stop) {
                NSString *fragmentTag = [NSString stringWithFormat:@"%@.%lu_%lu", tag, (unsigned long)idx, (unsigned long)fragments.count];
                [self registerKey:fragment withValue:fragmentTag];
            }];
        } else {
            if (tag) [self registerKey:obj withValue:tag];
        }
    }];
    [dictionary addEntriesFromDictionary:actualDict];
}

+ (dispatch_semaphore_t)dictionaryChangeSem {
    static dispatch_semaphore_t sem;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sem = dispatch_semaphore_create(1);
    });
    return sem;
}

- (void)attachToDictionary:(GCObject *)sender typeID:(NSNumber *)typeID {
    dispatch_semaphore_t sem = [GCDictionary dictionaryChangeSem];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    if (![registedID containsObject:typeID]) {
        [self pollAtObject:sender typeID:typeID phaseType:phaseType_adjective];
        [self pollAtObject:sender typeID:typeID phaseType:phaseType_instance];
        [self pollAtObject:sender typeID:typeID phaseType:phaseType_noun];
        [self pollAtObject:sender typeID:typeID phaseType:phaseType_verb];
    }
    [registedID addObject:typeID];
    dispatch_semaphore_signal(sem);
}

- (NSArray *)tokensForWord:(NSString *)word {
    NSString *value = dictionary[word];
    return [value componentsSeparatedByString:@"|"];
}

@end
