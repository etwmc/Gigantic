//
//  GCObjectRequest.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCObjectRequest.h"

#import "QueryContext.h"

#import "GCExtensionCentral.h"

#import "GCExtensionObject.h"

bool objectInfote(NSString *source) {
    NSArray *arr = [source componentsSeparatedByString:@", "];
    return arr.count==3;
}

@implementation GCObjectRequest
@synthesize creator, type, objID;

- (id)initWithString:(const char *)s remain:(char **)remain {
    self = [super init];
    if (self) {
        assert(strlen(s) > 0);
        char *temp;
        creator = strtol(s, &temp, 10); temp +=2;
        objID = strtol(temp, &temp, 10); temp +=2;
        type = (phaseType)strtol(temp, remain, 10); temp +=2;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)str {
    if (objectInfote(str)) {
        self = [super init];
        if (self) {
            NSArray *array = [str componentsSeparatedByString:@", "];
            creator = atol(((NSString *)array[0]).UTF8String);
            type = atoi(((NSString *)array[1]).UTF8String);
            objID = atol(((NSString *)array[2]).UTF8String);
        }
        return self;
    } else return nil;
}

- (NSString *)requestString {
    return [NSString stringWithFormat:@"%ld, %u, %ld", creator, type, objID];
}

@end

@implementation GCActionObjectRequest
@synthesize modifierDictionary;
- (id)initWithString:(const char *)s remain:(char **)remain {
    self = [super initWithString:s remain:remain];
    if (self) {
        modifierDictionary = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)str {
    NSArray *array = [str componentsSeparatedByString:@"/"];
    self = [super initWithString:array[0]];
    if (self) {
        modifierDictionary = [NSMutableDictionary new];
        QueryContext *context = [QueryContext sharedQuery];
        for (int i = 1; i < array.count; i++) {
            NSArray *_array = [array[i] componentsSeparatedByString:@"_"];
            NSArray *objects = [context traceObject:_array[1]];
            //Exposed the object to the extension central
            NSMutableArray *objectsUUID = [NSMutableArray new];
            for (GCObject *obj in objects) {
                if ([obj isKindOfClass:[GC_ExtensionObject class]]) {
                    GC_ExtensionObject *eObj = obj;
                    [objectsUUID addObject:eObj.uuid.UUIDString];
                } else {
                    NSUUID *uuid = [NSUUID UUID];
                    [objectsUUID addObject:uuid.UUIDString];
                    [GCExtensionCentral registerUUID:uuid.UUIDString forLocalObject:obj];
                }
            }
            modifierDictionary[_array[0]] = objectsUUID;
        }
    }
    return self;
}

@end

@implementation GCAdjectiveRequest

@synthesize mode;
- (instancetype)initWithString:(NSString *)str {
    self = [super initWithString:str];
    if (self) {
        mode = self.objID%3;
        self.objID = self.objID/3;
        QueryContext *context = [QueryContext sharedQuery];
    }
    return self;
}

@end