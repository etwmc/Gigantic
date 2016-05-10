//
//  GCExtension.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 16/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCExtension.h"
#import <string>
#import "GCExtensionObject.h"

#import "GCExtensionCentral.h"

@interface GC_Extension ()  {
    //Basic Information
    //Connection
    int _socket;
    dispatch_queue_t queue;
    NSString *name;
    
    NSDictionary *vocabulatory;
}
@end

@implementation GC_Extension

@synthesize extensionID;

+ (int)ticket {
    static int ticket = 1000;
    int result;
    static dispatch_semaphore_t sem = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    result = ticket++;
    dispatch_semaphore_signal(sem);
    return result;
}

- (NSDictionary *)sendCommand:(NSString *)command withParameters:(NSDictionary *)parameters {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (command) newDict[@"Command"] = command;
    NSMutableData *result = [NSMutableData dataWithLength:8192];
    __block ssize_t len;
    NSData *package = [NSJSONSerialization dataWithJSONObject:newDict options:0 error:nil];
    dispatch_sync(queue, ^{
        write(_socket, package.bytes, package.length);
        len = read(_socket, result.mutableBytes, 8192);
    });
    if (len > 0) {
        NSData *d = [result subdataWithRange:NSMakeRange(0, len)];
        return [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
    } else return nil;
}

- (NSDictionary *)sendCommand:(NSString *)command {
    return [self sendCommand:command withParameters:@{}];
}

- (instancetype)initWithSocket:(int)socket {
    self = [super init];
    if (self) {
        _socket = socket;
        queue = dispatch_queue_create("Extension Queue", DISPATCH_QUEUE_SERIAL);
        NSDictionary *handshakeMsg = [self sendCommand:@"Extension ID"];
        extensionID = ((NSNumber *)handshakeMsg[@"Result"]).intValue;
        //extensionID = [GC_Extension ticket];
    }
    return self;
}

- (NSString *)name {
    if (name == nil) {
        NSDictionary *dict = [self sendCommand:@"Name"];
        if (dict) name = dict[@"Result"];
    }
    return name;
}

- (GCObject *)getInstanceFromRequest:(GCObjectRequest *)request {
    GC_ExtensionObject *obj = [GC_ExtensionObject new];
    obj.extension = self;
    NSDictionary *msg = [self sendCommand:@"Instance Request" withParameters:@{@"Request": request.requestString}];
    if (msg == nil) return nil;
    obj.uuid = [[NSUUID alloc] initWithUUIDString:msg[@"UUID"]];
    [GCExtensionCentral registerUUID:msg[@"UUID"] fromExtension:self];
    return obj;
}

- (NSArray *)getObjectsFromRequest:(GCObjectRequest *)objectInfo {
    //All the UUID of the extension object
    NSDictionary *request = @{@"Request": objectInfo.requestString};
    
    NSDictionary *msg = [self sendCommand:@"Sub object" withParameters:request];
    NSArray *uuids = msg[@"UUIDs"];
    NSMutableArray *objs = [NSMutableArray new];
    for (NSString *_uuid in uuids) {
        GC_ExtensionObject *obj = [GC_ExtensionObject new];
        obj.uuid = [[NSUUID alloc] initWithUUIDString:_uuid];
        obj.extension = self;
        [objs addObject:obj];
        [GCExtensionCentral registerUUID:obj.uuid.UUIDString fromExtension:self];
    }
    return [NSArray arrayWithArray:objs];
}

- (bool)rawInputForObject:(GCObjectRequest *)obj buffer:(const char *)buffer {
#define len 1000
    char *_buffer = new char[len];
    int _len = snprintf(_buffer, len, "Execute:%ld_%s", obj.objID, buffer);
    __block bool success;
    dispatch_sync(queue, ^{
        write(_socket, _buffer, _len);
        read(_socket, &success, sizeof(success));
    });
    return success;
}

- (NSString *)description { return name; }

- (void)dealloc {
    close(_socket);
}

- (NSString *)dictionaryAddr {
    NSDictionary *dict = [self sendCommand:@"Dictionary"];
    return dict[@"Result"];
}

- (NSDictionary *)routingForRequest:(GCObjectRequest *)request {
    NSDictionary *dict = [self sendCommand:@"Route" withParameters:@{@"Request": request.requestString}];
    return dict[@"Result"];
}

- (NSArray *)vocabulatory:(phaseType)type {
    
    NSString *addr = [self dictionaryAddr];
    addr = [addr stringByReplacingOccurrencesOfString:@"dict" withString:@"plist"];
    vocabulatory = [NSDictionary dictionaryWithContentsOfFile:addr];
    
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
    
    if (vocabulatory) {
        return vocabulatory[key];
    } else return nil;
    
}

@end
