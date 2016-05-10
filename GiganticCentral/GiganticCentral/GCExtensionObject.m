//-0
//  GCExtensionObject.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 1/27/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCExtensionObject.h"
#import "QueryContext.h"

#import "GCExtensionCentral.h"

@implementation GC_ExtensionObject
@synthesize extension, uuid;
- (NSArray *)getSubObjects:(GCObjectRequest *)objectInfo {
    //All the UUID of the extension object
    NSDictionary *request = @{@"Request": objectInfo.requestString, @"UUID": uuid.UUIDString};
    
    GC_Extension *targetExt;
    if (extension.extensionID == objectInfo.creator)
        targetExt = extension;
    else
        targetExt = [GCExtensionCentral extensionForID:objectInfo.creator];
    
    NSDictionary *msg = [targetExt sendCommand:@"Sub object" withParameters:request];
    NSArray *uuids = msg[@"UUIDs"];
    NSMutableArray *objs = [NSMutableArray new];
    for (NSString *_uuid in uuids) {
        GC_ExtensionObject *obj = [GC_ExtensionObject new];
        obj.uuid = [[NSUUID alloc] initWithUUIDString:_uuid];
        obj.rootObj = self;
        obj.extension = targetExt;
        [objs addObject:obj];
        [GCExtensionCentral registerUUID:obj.uuid.UUIDString fromExtension:self.extension];
    }
    return [NSArray arrayWithArray:objs];
}

- (NSObject *)getAttribute:(GCObjectRequest *)attribute {
    return nil;
}

- (BOOL)performActionDictionary:(NSDictionary *)actionDictionary forSession:(NSUInteger)sessionID{
    //All the UUID of the extension object
    NSDictionary *request = @{@"Objs": @[uuid.UUIDString], @"Action": actionDictionary};
    NSDictionary *msg = [extension sendCommand:@"Perform Action" withParameters:request];
    return [msg[@"Result"] isEqualToString:@"Success"];
}

- (NSString *)finalizeActionPerformSession:(NSUInteger)sessionID {
    NSDictionary *request = @{@"Session ID": [NSNumber numberWithUnsignedInteger:sessionID]};
    NSDictionary *msg = [extension sendCommand:@"Finalize" withParameters:request];
    return msg[@"Msg"];
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSDictionary *request = @{@"key": key, @"UUID": uuid.UUIDString};
    NSDictionary *msg = [extension sendCommand:@"raw_attribute" withParameters:request];
    if (msg[@"Result"]) {
        return msg[@"Result"];
    }
    msg = [extension sendCommand:@"attribute" withParameters:request];
    if (msg[@"Result"]) {
        GC_ExtensionObject *obj = [GC_ExtensionObject new];
        obj.uuid = [[NSUUID alloc] initWithUUIDString:msg[@"Result"]];
        obj.rootObj = self;
        obj.extension = self.extension;
        [GCExtensionCentral registerUUID:msg[@"Result"] fromExtension:self.extension];
        return obj;
    }
    return [super valueForUndefinedKey:key];
}

- (NSComparisonResult)compare:(GCObject *)other
{
    if ([other isKindOfClass:[GC_ExtensionObject class]]) {
        if (self.extension == ((GC_ExtensionObject *)other).extension) {
            NSDictionary *request = @{@"UUIDs": @[self.uuid.UUIDString, ((GC_ExtensionObject *)other).uuid.UUIDString]};
            NSDictionary *msg = [extension sendCommand:@"compareInHouse" withParameters:request];
            if (msg[@"Success"]) {
                NSInteger result = ((NSNumber *)msg[@"Result"]).integerValue;
                return result;
            }
        }
    }
    return NSOrderedSame;
}

- (NSString *)description {
    NSDictionary *msg = [extension sendCommand:@"Describe" withParameters:@{@"UUID": uuid.UUIDString}];
    return msg[@"Result"];
}

@end
