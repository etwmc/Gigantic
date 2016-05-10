//
//  QueryContext.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 10/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "QueryContext.h"
#import "ObjectTrace.h"
#import "GCPerson.h"
#import "GCQuery.h"
#import "GCQuerySolution.h"

#import "GCContext.h"

#define printTraceResult 0
#define printTraceError 0

@interface QueryContext () {
    NSMutableDictionary *coreDataType;
}
@end

@implementation QueryContext
@synthesize userObj, deviceObj, lastObjs;

//Context.lastObjs filters
- (NSArray *)lastObject {
    __block NSArray *_result = @[];
    [lastObjs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:GCPerson.class]) {
            //*stop = YES;
            _result = @[obj];
        }
    }];
    return _result;
}

- (NSArray *)lastPersonWithSex:(GCPersonGender)gender {
    __block NSArray *_result = @[];
    [lastObjs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:GCPerson.class] && (((GCPerson *)obj).gender == gender||((GCPerson *)obj).gender == GCPersonGender_noGender)) {
            *stop = YES;
            _result = @[obj];
        }
    }];
    return _result;
}

- (id)init {
    self = [super init];
    if (self) {
        userObj = [GCPerson user];
        deviceObj = [GCPerson server];
        lastObjs = @[];
        coreDataType = [NSMutableDictionary dictionary];
    }
    return self;
}

- (bool)startQuery:(Query *)query withPartition:(int)partition {
    bool result = [query applyConstraints];
    result &= [query applyAction];
    result &= [query analyze];
    result &= [query formAnswer];
    return result;
}

- (void)preserveQueryResult:(Query *)query {
    //Add the objects reference by the user and query
    NSArray *result = [query.solution.constraintsResult arrayByAddingObjectsFromArray:query.solution.resultObjs];
    
    NSArray *nonContextBasedObj = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GCObject *evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject.class isSubclassOfClass:[GCContext class]]) return false;
        if (![evaluatedObject.class isSubclassOfClass:[GCObject class]]) return false;
        return ![evaluatedObject.rootObj.class isSubclassOfClass:[GCContext class]];
    }]];
    
    lastObjs = [lastObjs arrayByAddingObjectsFromArray:nonContextBasedObj];
}

+ (QueryContext *)sharedQuery {
    static QueryContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [QueryContext new];
    });
    return context;
}

- (NSArray *)traceObject:(NSString *)objectStr {
    NSArray *srcArray = separateElemet(objectStr);
    NSArray *objects = @[];
    
    if (srcArray.count == 0) return @[];
    
    //Get root
    NSString *rootStr = srcArray[0];
    if ([rootStr isEqualToString:@"i"] || [rootStr isEqualToString:@"me"] || [rootStr isEqualToString:@"my"] || [rootStr isEqualToString:@"mine"]) {
        objects = @[userObj];
    } else if ([rootStr isEqualToString:@"you"] || [rootStr isEqualToString:@"your"] || [rootStr isEqualToString:@"yours"]) {
        objects = @[deviceObj];
    } else if ([rootStr isEqualToString:@"this"] || [rootStr isEqualToString:@"that"]) {
        if (lastObjs.count) objects = @[lastObjs.lastObject];
#if printTraceResult
        else NSLog(@"I don't know what %@ is", rootStr);
#endif
    } else if ([rootStr isEqualToString:@"it"] || [rootStr isEqualToString:@"its"]) {
        //Example: What time is it
        objects = [objects arrayByAddingObject:[GCContext currentContext]];
        //Example: Who is it
        objects = [objects arrayByAddingObjectsFromArray:[QueryContext.sharedQuery lastPersonWithSex:GCPersonGender_noGender]];
        //Example: What is the its lyric
        objects = [objects arrayByAddingObjectsFromArray:[QueryContext.sharedQuery lastObject]];
    } else if ([rootStr isEqualToString:@"he"]||[rootStr isEqualToString:@"his"]||[rootStr isEqualToString:@"him"]) {
        objects = [objects arrayByAddingObjectsFromArray:[QueryContext.sharedQuery lastPersonWithSex:GCPersonGender_male]];
    } else if ([rootStr isEqualToString:@"she"]||[rootStr isEqualToString:@"her"]||[rootStr isEqualToString:@"her1"]) {
        objects = [objects arrayByAddingObjectsFromArray:[QueryContext.sharedQuery lastPersonWithSex:GCPersonGender_female]];
    } else {
        NSArray *twoLayer = [rootStr componentsSeparatedByString:@"|"];
        GCObjectRequest *fobj = [[GCObjectRequest alloc] initWithString:twoLayer[0]];
        
        NSNumber *key = [NSNumber numberWithLong:fobj.creator];
        Class _class = [coreDataType objectForKey:key];
        if (fobj.type == phaseType_instance) {
            GCObject *instance = [_class performSelector:@selector(getInstanceFromRequest:) withObject:fobj];
            if (instance) objects = [objects arrayByAddingObject:instance];
        }
        else if (fobj.type == phaseType_noun)
            objects = [_class performSelector:@selector(getObjectsFromRequest:) withObject:fobj];
        //Only multiple objects should be filter
        if (twoLayer.count > 1) {
            GCAdjectiveRequest *filter = [[GCAdjectiveRequest alloc] initWithString:twoLayer[1]];
            NSMutableArray *temp = [NSMutableArray arrayWithArray:objects];
            [temp filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GCObject *evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject judge:filter fromSampleSet:objects] == judgementCall_true;
            }]];
            objects = [NSArray arrayWithArray:temp];
        }
    }
    
    @try {
        NSArray *newArray = [srcArray subarrayWithRange:NSMakeRange(1, srcArray.count-1)];
        NSArray *responseFormat = @[];
        
        for (NSString *requestStr in newArray) {
            NSMutableArray *nextLevel = [NSMutableArray new];
            NSArray *twoLayer = [requestStr componentsSeparatedByString:@"|"];
            GCObjectRequest *request = [[GCObjectRequest alloc] initWithString:twoLayer[0]];
            
            for (GCObject *obj in objects) {
                NSArray *results;
                if (request) results = [obj getSubObjects:request];
                else {
                    NSObject *_obj = [obj valueForKey:twoLayer[0]];
                    if (_obj) results = @[_obj];
                }
                for (GCObject *subObj in results) {
                    subObj.rootObj = obj;
                }
                if (results) [nextLevel addObjectsFromArray:results];
            }
            
            //Only multiple objects should be filter
            if (twoLayer.count > 1) {
                GCAdjectiveRequest *filter = [[GCAdjectiveRequest alloc] initWithString:twoLayer[1]];
                [nextLevel filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GCObject *evaluatedObject, NSDictionary *bindings) {
                    return [evaluatedObject judge:filter fromSampleSet:nextLevel] == judgementCall_true;
                }]];
            }
            
            objects = [NSArray arrayWithArray:nextLevel];
        }
        
    }
    @catch (NSException *exception) {
#if printTraceError
        NSLog(@"%@", exception);
#endif
        return @[];
    }
    @finally {
        //<#Code that gets executed whether or not an exception is thrown#>
    }

#if printTraceResult
    NSLog(@"Object Trace: %@\nResult: %@", objectStr, objects);
#endif
    
    //Remove context: no one would directly reference to the context
    objects = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSObject *evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject class]!=[GCContext class];
    }]];
    
    return objects;
}

- (BOOL)objectCanBeTrace:(NSString *)objectStr { return [self traceObject:objectStr].count; }

- (void)registerObjectType:(id)type withID:(NSNumber *)objTypeID {
    [coreDataType setObject:type forKey:objTypeID];
}

- (Class)classForKey:(NSNumber *)key {
    return coreDataType[key];
}

@end