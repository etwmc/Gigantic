//
//  GCObject.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/19/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCObject.h"
#import <string.h>
#import "QueryContext.h"
#import "GCValue.h"

#import <objc/message.h>

#import "GCExtension.h"

#import "GCExtensionObject.h"

#import "GCDictionary.h"

#import "VIKit.h"

NSString *termString(GCObjectRequest *obj) {
    switch (obj.type) {
        case phaseType_noun:
            return @"Noun";
        case phaseType_adjective:
            return @"Adjective";
        case phaseType_verb:
            return @"Verb";
        default:
            return nil;
    }
}

static NSMutableDictionary *extensionsList = nil;

@implementation GCObject
@synthesize rootObj, uuid, outputFormat;

//Object Attribute
+ (NSUInteger)startActionPerformSession {
    static NSUInteger sessionID = 0;
    return sessionID++;;
}
- (GCObject *)performAction:(NSArray *)actions forSession:(NSUInteger)sessionID {
    if (actions.count == 0) return self;
    for (GCActionObjectRequest *request in actions) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.class getRouting:request]];
        if (request.modifierDictionary) dict[@"modifier"] = request.modifierDictionary;
        if (![self performActionDictionary:dict forSession:sessionID]) {
            return [[GCValue alloc] initNumber:[NSNumber numberWithBool:NO]];
        }
    }
    return [[GCValue alloc] initNumber:[NSNumber numberWithBool:YES]];
}
- (BOOL)performActionDictionary:(NSDictionary *)actionDictionary forSession:(NSUInteger)sessionID {
    if (actionDictionary) {
        BOOL result = true;
        SEL commandSelector = NSSelectorFromString(actionDictionary[@"Command"]);
        @try {
            [self performSelector:commandSelector];
        }
        @catch (NSException *exception) {
            result = false;
        }
        @finally {
        }
        return result;
    }
    else return false;
}
- (void)undoActionPerformSession:(NSUInteger)sessionID {
     
}
- (NSString *)finalizeActionPerformSession:(NSUInteger)sessionID {
    return @"It is done";
}

- (NSString *)name {
    return nil;
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
- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.name];
}
+ (NSString *)routingName {
    return nil;
}
+ (NSDictionary *)objectRouting {
    NSString *routingAddr = [NSString stringWithFormat:@"/vui/profile/Root/%@.plist", NSStringFromClass(self)];
    NSDictionary *routing = [NSDictionary dictionaryWithContentsOfFile:routingAddr];
    return routing;
}
- (NSArray *)evaluateValueForConf:(NSDictionary *)configuration {
    NSExpression *expression = [NSExpression expressionWithFormat:configuration[@"Expression"]];
    
    NSObject *result = [expression expressionValueWithObject:self context:nil];
    
    if ([result isKindOfClass:[NSArray class]]) {
        return result;
    }
    if (result) return @[result];
    else return @[];
}
- (NSArray *)getSubObjects:(GCObjectRequest *)objectInfo { return [[self class] getSubObjects:objectInfo fromObject:self]; }
+ (NSArray *)getSubObjects:(GCObjectRequest *)objectInfo fromObject:(GCObject *)obj {
    
    NSArray *array = @[];
    
    @try {
        
        NSString *routingType = termString(objectInfo);
        
        NSDictionary *configuration = [[self class] getRouting:objectInfo];
        
        array = [obj evaluateValueForConf:configuration];
        
        
        
        NSString *format = configuration[@"ResponseFormat"];
        
        for (GCObject *obj in array) {
            if (format) obj.outputFormat = format;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: Line %d of File %s. %@", __LINE__, __FILE__, exception);
    }
    @finally {
    }
    
    return array;
}
+ (NSDictionary *)getRouting:(GCObjectRequest *)attribute {
    NSString *routingType = termString(attribute);
    
    NSDictionary *dict = [self objectRouting];
    if (dict == nil || [dict[@"classID"] longValue] != attribute.creator) {
        if ([self class] == [GCObject class]) {
            
            //If nothing work, try extension
            GC_Extension *extension = [[QueryContext sharedQuery] classForKey:[NSNumber numberWithLong:attribute.creator]];
            
            if ([extension.class isSubclassOfClass:[GC_Extension class]])return [extension routingForRequest:attribute];
            return nil;
            
        }
        else {
            return [[self superclass] getRouting:attribute];
        }
    }
    
    return dict[routingType][attribute.objID];
}

- (NSObject *)getAttribute:(GCObjectRequest *)attribute {
    NSString *routingType = termString(attribute);
    
    NSDictionary *configuration = [[self class] getRouting:attribute];
    
    NSString *valueKey = configuration[@"value"];
    
    NSDictionary *valueConfiguration = [self.class getKeyDefinition:valueKey];
    
    if (valueConfiguration == nil) return nil;
    
    NSArray *values = [self evaluateValueForConf:valueConfiguration];
    
    if (values.count != 1) return nil;
    
    return values[0];
}

- (judgementCall)judge:(GCObjectRequest *)judgement {
    switch (judgement.type) {
        case phaseType_adjective: {
            @try {
                
                NSDictionary *configuration = [[self class] getRouting:judgement];
                
                NSObject *value = self;
                
                if (configuration == nil) return judgementCall_fail;
                
                NSPredicate *predicator = [ NSPredicate predicateWithFormat:configuration[@"judgement"]];
                
                return [predicator evaluateWithObject:value];
            }
            @catch (id dummy) {
                return judgementCall_fail;
            }
            @finally {
            }
            
        }
            break;
        case phaseType_noun: {
            @try {
                NSNumber *key = [NSNumber numberWithLong:judgement.creator];
                Class _class = [[QueryContext sharedQuery] classForKey:key];
                GCObject *obj = [_class performSelector:@selector(getInstanceFromRequest:) withObject:judgement];
                if (obj == NULL) return judgementCall_fail;
                return [self isEqual:obj];
            }
            @catch (id dummy) {
                return judgementCall_fail;
            }
            @finally {
            }
        }
            break;
        case phaseType_instance: {
            @try {
                NSNumber *key = [NSNumber numberWithLong:judgement.creator];
                Class _class = [[QueryContext sharedQuery] classForKey:key];
                GCObject *obj = [_class performSelector:@selector(getInstanceFromRequest:) withObject:judgement];
                if (obj == NULL) return judgementCall_fail;
                return [self isEqual:obj];
            }
            @catch (id dummy) {
                return judgementCall_fail;
            }
            @finally {
            }
        }
            break;
        default:
            return judgementCall_fail;
            break;
    }
    
}
- (judgementCall)judge:(GCAdjectiveRequest *)judgement fromSampleSet:(NSArray *)sampleSet {
    switch (judgement.type) {
        case phaseType_adjective: {
            @try {
                NSString *routingType = termString(judgement);
                
                Class owner = [[QueryContext sharedQuery] classForKey:[NSNumber numberWithLong:judgement.creator]];
                NSDictionary *configuration = [owner getRouting:judgement];
                
                NSObject *value = self;
#warning - Not finished yet
                
                if (configuration == nil) return judgementCall_fail;
                
                switch (judgement.mode) {
                    case GCAdjectiveRequestMode_describe: {
                        if (configuration[@"judgement"]) {
                            NSPredicate *predicator = [ NSPredicate predicateWithFormat:configuration[@"judgement"]];
                            return [predicator evaluateWithObject:value];
                            break;
                        }
                    }
                    case GCAdjectiveRequestMode_absolute: {
                        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:configuration[@"value"] ascending:((NSNumber *)configuration[@"asscending"]).boolValue];
                        NSArray *sortedList = [sampleSet sortedArrayUsingDescriptors:@[descriptor]];
                        NSUInteger index = [sortedList indexOfObject:self];
                        if (index == NSNotFound) return judgementCall_fail;
                        return (index == 0);
                    }
                    case GCAdjectiveRequestMode_compare: {
                        
                    }
                    default:
                        break;
                }
                
                
            }
            @catch (id dummy) {
                return judgementCall_fail;
            }
            @finally {
            }
            
        }
            break;
        case phaseType_noun: {
            @try {
                NSNumber *key = [NSNumber numberWithLong:judgement.creator];
                Class _class = [[QueryContext sharedQuery] classForKey:key];
                GCObject *obj = [_class performSelector:@selector(getInstanceFromRequest:) withObject:judgement];
                if (obj == NULL) return judgementCall_fail;
                return [self isEqual:obj];
            }
            @catch (id dummy) {
                return judgementCall_fail;
            }
            @finally {
            }
        }
            break;
        case phaseType_instance: {
            @try {
                NSNumber *key = [NSNumber numberWithLong:judgement.creator];
                Class _class = [[QueryContext sharedQuery] classForKey:key];
                GCObject *obj = [_class performSelector:@selector(getInstanceFromRequest:) withObject:judgement];
                if (obj == NULL) return judgementCall_fail;
                return [self isEqual:obj];
            }
            @catch (id dummy) {
                return judgementCall_fail;
            }
            @finally {
            }
        }
            break;
        default:
            return judgementCall_fail;
            break;
    }
    //Default return
    return judgementCall_true;
}


- (NSString *)subObjectNameForType:(GCObjectRequest *)attribute {
    NSString *routingType = termString(attribute);
    
    NSDictionary *dict = [[self class] getRouting:attribute];
    if (dict == nil) return nil;
    NSDictionary *configuration = dict[routingType][attribute.objID];
    return configuration[@"name"];
}
+ (NSDictionary *)getKeyDefinition:(NSString *)key {
    NSDictionary *dict = [[self class] objectRouting];
    if (dict == nil) {
        if (self == [GCObject class]) return nil;
        return [super valueForUndefinedKey:key];
    }
    
    //Trace the index
    NSArray *tree = dict[@"routingReference_noun"];
    NSUInteger index = [tree indexOfObject:key];
    
    if (index != NSNotFound) {
        NSDictionary *analyzeTree = dict[@"Noun"][index];
        if (analyzeTree) return analyzeTree;
    }
    
    
    if (self != [GCObject class]) return [[self superclass] getKeyDefinition:key];
    else return nil;
}
- (id)valueForUndefinedKey:(NSString *)key {
    NSDictionary *dict = [[self class] getKeyDefinition:key];
    if (dict)
        return [self evaluateValueForConf:dict];
    else
        return [super valueForUndefinedKey:key];
}
+ (instancetype)getInstanceFromRequest:(GCObjectRequest *)request {
    NSDictionary *dictionary = [self objectRouting];
    NSArray *instanceList = dictionary[@"Instance"];
    NSString *addr = instanceList[request.objID];
    addr = addr.stringByExpandingTildeInPath;
    return [NSKeyedUnarchiver unarchiveObjectWithFile:addr];
}
- (NSArray *)keys {
    return @[@"uuid"];
}

- (NSString *)responseForRequest:(GCObjectRequest *)request {
    return [[self class] getRouting:request][@"ResponseFormat"];
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
+ (void)initialDict {
    NSLog(@"Load: %@", NSStringFromClass(self));
    NSDictionary *routingScheme = [self objectRouting];
    if (routingScheme) {
        NSNumber *typeID = routingScheme[@"classID"];
        if (typeID) {
            [[QueryContext sharedQuery] registerObjectType:self withID:typeID];
            /*
             * Add the list into voice recogitor
             */
            //[[GCVoiceInputManager sharedManager] addNewWords:routingScheme withName:NSStringFromClass(self)];
            GCObject *dummy = [self new];
            [[GCDictionary sharedDictionary] attachToDictionary:dummy typeID:typeID];
        }
    }
}
+ (void)load {
    [self initialDict];
}

//Action extension
+ (NSMutableArray *)extensions {
    
    static NSMutableArray *extension = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        extension = [NSMutableArray array];
    });
    return extension;
}
+ (void)addSupportExtension:(NSObject *)extension withName:(NSNumber *)name {
    if (extensionsList == nil) extensionsList = [NSMutableDictionary new];
    
    NSMutableArray *extensions = extensionsList[name];
    
    if (extensions == nil) extensions = [NSMutableArray new];
    
    [extensions addObject:extension];
    
    [extensionsList setObject:extensions forKey:name];
    
}
+ (void)removeSupportExtension:(NSObject *)extension withName:(NSNumber *)name {
    if (extensionsList == nil) extensionsList = [NSMutableDictionary new];
    
    NSMutableArray *extensions = extensionsList[name];
    
    if (extensions == nil) extensions = [NSMutableArray new];
    
    [extensions removeObject:extension];
    
    [extensionsList setObject:extensions forKey:name];
    
}

+ (NSArray *)vocabulatory:(phaseType)type {
    NSString *typeStr;
    switch (type) {
        case phaseType_adjective:
            typeStr = @"adjective";
            break;
        case phaseType_adverb:
            typeStr = @"adverb";
            break;
        case phaseType_instance:
            typeStr = @"instance";
            break;
        case phaseType_noun:
            typeStr = @"noun";
            break;
        case phaseType_verb:
            typeStr = @"verb";
            break;
        default:
            typeStr = nil;
            break;
    }
    NSString *key = [NSString stringWithFormat:@"routingReference_%@", typeStr];
    
    NSDictionary *configuration = [self objectRouting];
    return configuration[key];
}

- (void)voiceOutput:(NSString *)outputDialogue {
    VIpresentDialog(outputDialogue.UTF8String, NO);
}

@end

@implementation _obj
@end