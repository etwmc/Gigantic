//
//  GCEObject.m
//  GCExtend
//
//  Created by Wai Man Chan on 10/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCEObject.h"

NSString *termString(GCEObjectRequest *obj) {
    switch (obj.type) {
        case phaseType_noun:
            return @"Noun";
        case phaseType_adjective:
            return @"Adjective";
        default:
            return nil;
    }
}

static NSMutableDictionary *extensionsList = nil;

@implementation GCEObject
@synthesize type, rootObj, uuid, name;

- (NSString *)description
{
    return self.name;
}

//Object Attribute
- (GCEObject *)performAction:(NSArray *)actions {
    return self;
}
- (NSString *)pronoun {
    return @"it";
}
- (NSString *)possessiveDeterminer {
    return @"its";
}
- (NSString *)variationOfBe {
    return @"is";
}
+ (NSString *)routingName {
    return nil;
}
+ (NSDictionary *)objectRouting {
    NSString *routingAddr = [NSString stringWithFormat:@"/vui/profile/Root/%@.plist", NSStringFromClass(self)];
    return [NSDictionary dictionaryWithContentsOfFile:routingAddr];
}
- (NSArray *)evaluateValueForConf:(NSDictionary *)configuration {
    NSExpression *expression = [NSExpression expressionWithFormat:configuration[@"Expression"]];
    
    NSObject *result = [expression expressionValueWithObject:self context:nil];
    
    if (result) return @[result];
    else return nil;
}


+ (NSArray *)getSubObjects:(GCEObjectRequest *)objectInfo fromObject:(GCEObject *)obj {
    NSString *routingType = termString(objectInfo);
    
    NSDictionary *dict = [[self class] getRouting:objectInfo];
    if (dict == nil || [dict[@"classID"] longValue] != objectInfo.creator) {
        if ([self class] == [GCEObject class]) { return @[]; }
        else {
            return [[self superclass] getSubObjects:objectInfo fromObject:obj];
        }
    }
    
    NSDictionary *configuration = dict[routingType][((NSDictionary *)dict[routingType]).allKeys[objectInfo.objID]];
    
    return [obj evaluateValueForConf:configuration];
}

- (NSArray *)getSubObjects:(GCEObjectRequest *)objectInfo { return [[self class] getSubObjects:objectInfo fromObject:self]; }


+ (NSDictionary *)getRouting:(GCEObjectRequest *)attribute {
    NSString *routingType = termString(attribute);
    
    NSDictionary *dict = [self objectRouting];
    if (dict == nil || [dict[@"classID"] longValue] != attribute.creator) {
        if ([self class] == [GCEObject class]) { return @{}; }
        else {
            return [[self superclass] getRouting:attribute];
        }
    }
    
    return dict;
}
- (NSObject *)getAttribute:(GCEObjectRequest *)attribute {
    NSString *routingType = termString(attribute);
    
    NSDictionary *dict = [[self class] getRouting:attribute];
    if (dict == nil) return nil;
    
    NSDictionary *configuration = dict[routingType][((NSDictionary *)dict[routingType]).allKeys[attribute.objID]];
    
    NSString *valueKey = configuration[@"value"];
    
    NSDictionary *valueConfiguration = dict[@"Noun"][valueKey];
    
    if (valueConfiguration == nil) return nil;
    
    NSArray *values = [self evaluateValueForConf:valueConfiguration];
    
    if (values.count != 1) return nil;
    
    return values[0];
}
#warning - Cross plugin is not supported yet
- (judgementCall)judge:(GCEObjectRequest *)judgement {
    return -1;
}
- (NSString *)subObjectNameForType:(GCEObjectRequest *)attribute {
    NSString *routingType = termString(attribute);
    
    NSDictionary *dict = [[self class] getRouting:attribute];
    if (dict == nil) return nil;
    NSDictionary *configuration = dict[routingType][((NSDictionary *)dict[routingType]).allKeys[attribute.objID]];
    return configuration[@"name"];
}
+ (NSDictionary *)getKeyDefinition:(NSString *)key {
    NSDictionary *dict = [[self class] objectRouting];
    if (dict == nil) return [super valueForUndefinedKey:key];
    NSDictionary *analyzeTree = dict[@"Noun"][key];
    if (analyzeTree) return analyzeTree;
    else if (self != [GCEObject class]) return [[self superclass] getKeyDefinition:key];
    else return nil;
}
- (id)valueForUndefinedKey:(NSString *)key {
    NSDictionary *dict = [[self class] getKeyDefinition:key];
    if (dict)
        return [self evaluateValueForConf:dict];
    else
        return [super valueForUndefinedKey:key];
}
+ (instancetype)getInstanceFromRequest:(GCEObjectRequest *)request {
    NSDictionary *dictionary = [self objectRouting];
    NSDictionary *instanceList = dictionary[@"Instance"];
    NSString *key = instanceList.allKeys[request.objID];
    NSString *addr = instanceList[key];
    addr = addr.stringByExpandingTildeInPath;
    return [NSKeyedUnarchiver unarchiveObjectWithFile:addr];
}
- (NSArray *)keys {
    return @[@"uuid"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *keys = [self keys];
    for (NSString *key in keys) {
        NSObject *value = [self valueForKeyPath:key];
        [aCoder encodeObject:value forKey:key];
    }
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        NSArray *keys = [self keys];
        for (NSString *key in keys) {
            if ([aDecoder containsValueForKey:key]){
                NSObject *value = [aDecoder decodeObjectForKey:key];
                [self setValue:value forKeyPath:key];
            }
        }
    }
    return self;
}

- (NSUInteger)hash { return uuid.hash; }
- (instancetype)init {
    self = [super init];
    if (self) {
        uuid = [NSUUID UUID];
    }
    return self;
}

//Register Function
//+ (void)initialDict {
//    NSLog(@"Load: %@", NSStringFromClass(self));
//    NSDictionary *routingScheme = [self objectRouting];
//    if (routingScheme) {
//        NSNumber *typeID = routingScheme[@"classID"];
//        if (typeID) {
//            [[QueryContext sharedQuery] registerObjectType:self withID:typeID];
//            /*
//             * Add the list into voice recogitor
//             */
//            //[[GCVoiceInputManager sharedManager] addNewWords:routingScheme withName:NSStringFromClass(self)];
//        }
//    }
//}
//+ (void)load {
//    [self initialDict];
//}

@end
