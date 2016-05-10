//
//  ExtensionCentral.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 6/12/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCExtensionCentral.h"

#import <sys/socket.h>
#import <sys/types.h>
#import <sys/un.h>

#import <netinet/in.h>

#define GCExtensionSocket "/vui/socket/GCE"

#define GCExtensionDataSocket "/vui/socket/GCE_Data"

#import "QueryContext.h"

#import "GCVoiceInput.h"

#import "GCObject.h"

#import "GCDictionary.h"

@interface GCExtensionCentral () {
    int dataFetchSocket;
}
@end

@implementation GCExtensionCentral

@synthesize registeredObj;

+ (GCExtensionCentral *)defaultCentral {
    static GCExtensionCentral *obj = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [GCExtensionCentral new];
    });
    return obj;
}

- (void)initialSocket {
#if !DEBUG
    _socket = socket(PF_INET, SOCK_STREAM, 0);
    
    sockaddr_in addr;   bzero(&addr, sizeof(addr));
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);  addr.sin_family = PF_INET;  addr.sin_len = sizeof(addr);    addr.sin_port = htons(54323);
    bind(_socket, (const struct sockaddr *)&addr, addr.sin_len);
#define ProtocolType PF_INET
#else
    _socket = socket(PF_UNIX, SOCK_STREAM, 0);
    struct sockaddr_un addr; addr.sun_family = PF_UNIX; addr.sun_len = sizeof(addr); strcpy(addr.sun_path, GCExtensionSocket);
    unlink(GCExtensionSocket);
    bind(_socket, (const struct sockaddr *)&addr, addr.sun_len);
#define ProtocolType PF_UNIX
#endif
}

+ (dispatch_semaphore_t)semaphore {
    static dispatch_semaphore_t sem;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sem = dispatch_semaphore_create(1);
    });
    return sem;
}

- (void)setupExtension:(GC_Extension *)extension {
    [_extensions addObject:extension];
    {
        NSNumber *eID = [NSNumber numberWithInt:extension.extensionID];
        [[QueryContext sharedQuery] registerObjectType:extension withID:eID];
        [GCObject addSupportExtension:extension withName:eID];
        if ([GCVoiceInputManager sharedManager])
            [[GCVoiceInputManager sharedManager] loadExtensionDictionary:extension.dictionaryAddr withID:extension.extensionID];
        [[GCDictionary sharedDictionary] attachToDictionary:extension typeID:eID];
    }
}

- (void)initialDataSocket {
#if !DEBUG
    _socket = socket(PF_INET, SOCK_STREAM, 0);
    
    sockaddr_in addr;   bzero(&addr, sizeof(addr));
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);  addr.sin_family = PF_INET;  addr.sin_len = sizeof(addr);    addr.sin_port = htons(54323);
    bind(_socket, (const struct sockaddr *)&addr, addr.sin_len);
#define ProtocolType PF_INET
#else
    dataFetchSocket = socket(PF_UNIX, SOCK_STREAM, 0);
    struct sockaddr_un addr; addr.sun_family = PF_UNIX; addr.sun_len = sizeof(addr); strcpy(addr.sun_path, GCExtensionDataSocket);
    unlink(GCExtensionDataSocket);
    bind(dataFetchSocket, (const struct sockaddr *)&addr, addr.sun_len);
#define ProtocolType PF_UNIX
#endif
}

- (instancetype)init {
    self = [super init];
    if (self) {
        registeredObj = [NSMutableDictionary new];
        _extensions = [NSMutableArray array];
        queue = dispatch_queue_create("GCExtension", DISPATCH_QUEUE_CONCURRENT);
        //Connection Information
        [self initialSocket];
        [self initialDataSocket];
        listen(_socket, 100);
        dispatch_async(queue, ^{
            while (true) {
                int newPort = accept(_socket, 0, 0);
                //Handshake
                char buffer[256];
                if (read(newPort, buffer, 256)) {
                    GC_Extension *extension = [[GC_Extension alloc] initWithSocket:newPort];
                    [self setupExtension:extension];
                }
            }
        });
        
        listen(dataFetchSocket, 100);
        dispatch_async(queue, ^{
            while (true) {
                int newPort = accept(dataFetchSocket, 0, 0);
                //Handshake
                char buffer[1024];
                int len = read(newPort, buffer, 1024);
                if (len) {
                    NSData *json = [NSData dataWithBytes:buffer length:len];
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json options:0 error:0];
                    NSString *uuid = dict[@"UUID"];
                    NSObject *ext = [GCExtensionCentral objectForUUID:uuid];
                    if ([ext.class isSubclassOfClass:[GC_Extension class]]) {
                        dict = [(GC_Extension *)ext sendCommand:nil withParameters:dict];
                        NSData *d = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                        write(newPort, d.bytes, d.length);
                    } else {
                        NSString *keyPath = dict[@"key"];
                        NSObject *result = [ext valueForKeyPath:keyPath];
                        if (result == nil) result = @"";
                        NSData *d = [NSJSONSerialization dataWithJSONObject:@{@"Result": result} options:0 error:nil];
                        write(newPort, d.bytes, d.length);
                    }
                }
                close(newPort);
            }
        });
        
    }
    return self;
}

+ (GC_Extension *)extensionForID:(int)_extensionID {
    GCExtensionCentral *central = [GCExtensionCentral defaultCentral];
    NSArray *extensions = central.extensions;
    for (GC_Extension *ext in extensions) {
        if (ext.extensionID == _extensionID)
            return ext;
    }
    return nil;
}

+ (void)registerUUID:(NSString *)uuid fromExtension:(GC_Extension *)extension {
    if (uuid == nil ||extension == nil) return;
    GCExtensionCentral *central = [GCExtensionCentral defaultCentral];
    central.registeredObj[uuid] = extension;
}

+ (void)registerUUID:(NSString *)uuid forLocalObject:(GCObject *)object {
    if (uuid == nil ||object == nil) return;
    GCExtensionCentral *central = [GCExtensionCentral defaultCentral];
    central.registeredObj[uuid] = object;
}

+ (NSObject *)objectForUUID:(NSString *)uuid {
    GCExtensionCentral *central = [GCExtensionCentral defaultCentral];
    return central.registeredObj[uuid];
}

@end

/*
 * To make the extension central awake, the singleton must be called once.
*/