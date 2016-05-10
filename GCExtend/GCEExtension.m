//
//  GCEExtension.cpp
//  GCExtend
//
//  Created by Wai Man Chan on 6/12/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCEExtension.h"

#import <sys/socket.h>
#import <sys/un.h>

#import <netinet/in.h>

#define GCExtensionSocket "/vui/socket/GCE"

#define GCExtensionMessageSize 1000

#import "GCEObject.h"

#import "GCETime.h"

//dispatch_queue_t queue = dispatch_queue_create("Extension Queue", DISPATCH_QUEUE_CONCURRENT);


int createConnection() {
    int _socket;
    

    
    int err;
    do {
        sleep(1);
#if !DEBUG
        _socket = socket(PF_INET, SOCK_STREAM, 0);
        
        struct sockaddr_in addr;   bzero(&addr, sizeof(addr));
        addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);  addr.sin_family = PF_INET;  addr.sin_len = sizeof(addr);    addr.sin_port = htons(54323);
        err = connect(_socket, (const struct sockaddr *)&addr, sizeof(addr));
#define ProtocolType PF_INET
#else
        _socket = socket(PF_UNIX, SOCK_STREAM, 0);
        struct sockaddr_un addr; addr.sun_family = PF_UNIX; addr.sun_len = sizeof(addr); strcpy(addr.sun_path, GCExtensionSocket);
        err = connect(_socket, (const struct sockaddr *)&addr, sizeof(addr));
#define ProtocolType PF_UNIX
#endif
    } while (err);
    char empty = 0;
    write(_socket, &empty, 1);
    return _socket;
}

void connectionFailed(int *connection) {
    close(*connection);
    *connection = -1;
}

@interface GCEExtension () {
    int _socket;
    char buffer[GCExtensionMessageSize];
    dispatch_queue_t extensionQueue;
}
@end

@implementation GCEExtension
//Variable for extension info
@synthesize extensionID, extensionName, dictionaryAddr;
//Status of the extension and the central
@synthesize localRunning, remoteRunning;
//A caching list of systen
@synthesize instanceList, objectList;




#define GCExtensionDataSocket "/vui/socket/GCE_Data"

- (NSDictionary *)writeToDataSocket:(NSDictionary *)packet {
    int dataFetchSocket = socket(PF_UNIX, SOCK_STREAM, 0);
    struct sockaddr_un addr; addr.sun_family = PF_UNIX; addr.sun_len = sizeof(addr); strcpy(addr.sun_path, GCExtensionDataSocket);
    int result = connect(dataFetchSocket, (const struct sockaddr *)&addr, addr.sun_len);
    NSData *writeD = [NSJSONSerialization dataWithJSONObject:packet options:0 error:0];
    write(dataFetchSocket, writeD.bytes, writeD.length);
    NSMutableData *readD = [NSMutableData dataWithLength:1024];
    int len = read(dataFetchSocket, readD.mutableBytes, 1024);
    readD = [readD subdataWithRange:NSMakeRange(0, len)];
    return [NSJSONSerialization JSONObjectWithData:readD options:0 error:0];
}

- (NSObject *)getRawAttributeFromRemoteObject:(NSString *)rootObjUUID forKeyPath:(NSString *)keyPath {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:rootObjUUID];
    if (objectList[uuid]) {
        return [objectList[uuid] valueForKeyPath:keyPath];
    }
    
    NSDictionary *titleFetchDict = @{ @"Command": @"raw_attribute", @"UUID": rootObjUUID, @"key": keyPath };
    NSDictionary *titlePacket = [self writeToDataSocket:titleFetchDict];
    return titlePacket[@"Result"];
}


- (NSDictionary *)processRequest:(GCEObjectRequest *)request {
    switch (request.type) {
        case phaseType_instance:
            return @{@"UUID": [self getInstanceUUID:request]};
    }
    return nil;
}
- (id)initWithExtensionName:(NSString *)name extensionID:(int)eid andDictionaryAddress:(NSString *)addr {
    self = [super init];
    if (self) {
        _socket = createConnection();
        extensionQueue = dispatch_queue_create("Extension Queue", DISPATCH_QUEUE_CONCURRENT);
        localRunning = false;
        instanceList = [NSMutableArray new];
        objectList = [NSMutableDictionary new];
        extensionName = name; extensionID = eid; dictionaryAddr = addr;
    }
    return self;
}
- (void)startExtension {
    if (!localRunning) {
        localRunning = true;
        dispatch_async(extensionQueue, ^{
            int len = 0;
            while (localRunning) {
                bzero(buffer, GCExtensionMessageSize);
                do {
                    if (len <= 0) {
                        connectionFailed(&(_socket));
                        _socket = createConnection();
                    }
                    len = (int)read(_socket, buffer, GCExtensionMessageSize);
                    if (len <= 0) printf("Error: Socket reset? \n");
                } while (len <= 0);
                NSData *input = [NSData dataWithBytes:buffer length:len];
                NSData *result = [self handleMessage:input];
                if (result) {
                    write(_socket, result.bytes, result.length);
                }
            }
        });
    }
}
- (void)stopExtension {
    localRunning = false;
}

- (NSString *)finalizeSession:(NSUInteger)sessionID { return @"The developer should override this"; }

- (NSData *)handleMessage:(NSData *)input {
    NSDictionary *inputDict = [NSJSONSerialization JSONObjectWithData:input options:0 error:Nil];
    /*
     * This is the routing logic for the packet received by extension
     * It is similar to the front desk of an office
     */
    
    @try {
        NSString *command = inputDict[@"Command"];
        if ([command isEqualToString:@"Name"])
            return [NSJSONSerialization dataWithJSONObject:@{@"Result": self.extensionName} options:0 error:nil];
        
        else if ([command isEqualToString:@"Dictionary"])
            return [NSJSONSerialization dataWithJSONObject:@{@"Result": self.dictionaryAddr} options:0 error:nil];
        
        else if ([command isEqualToString:@"Instance Request"]) {
            NSString *requestStr = inputDict[@"Request"];
            GCEObjectRequest *request = [[GCEObjectRequest alloc] initWithString:requestStr];
            NSDictionary *objs = [self processRequest:request];
            return [NSJSONSerialization dataWithJSONObject:objs options:0 error:nil];
            
        } else if ([command isEqualToString:@"Perform Action"]) {
            NSString *objectID = @"UUID";
            
            NSDictionary *actionDef = inputDict[@"Action"];
            
            NSString *result = [self setAction:actionDef atObjects:inputDict[@"Objs"]];
            
            return [NSJSONSerialization dataWithJSONObject:@{@"Result": result} options:0 error:nil];
        } else if ([command isEqualToString:@"Describe"]) {
            NSObject *obj = [self objectForUUID:inputDict[@"UUID"]];
            return [NSJSONSerialization dataWithJSONObject:@{@"Result": obj.description} options:0 error:nil];
        } else if ([command isEqualToString:@"Sub object"]) {
            NSString *requestStr = inputDict[@"Request"];
            GCEObjectRequest *request = [[GCEObjectRequest alloc] initWithString:requestStr];
            NSString *rootUUID = inputDict[@"UUID"];
            NSArray *uuids = [self getSubObjectUUID:request fromRoot:rootUUID];
            return [NSJSONSerialization dataWithJSONObject:@{@"UUIDs": uuids} options:0 error:nil];
        } else if ([command isEqualToString:@"attribute"]) {
            NSString *UUID = inputDict[@"UUID"];
            NSString *result = [self getAttributeFromObject:UUID forKeyPath:inputDict[@"key"]];
            return [NSJSONSerialization dataWithJSONObject:@{@"Result": result} options:0 error:nil];
        } else if ([command isEqualToString:@"raw_attribute"]) {
            NSString *UUID = inputDict[@"UUID"];
            NSObject *result = [self getRawAttributeFromObject:UUID forKeyPath:inputDict[@"key"]];
            if ([result.className hasPrefix:@"NS"]||[result.className hasPrefix:@"__NS"])
                return [NSJSONSerialization dataWithJSONObject:@{@"Result": result} options:0 error:nil];
        } else if ([command isEqualToString:@"Route"]) {
            NSString *requestStr = inputDict[@"Request"];
            GCEObjectRequest *request = [[GCEObjectRequest alloc] initWithString:requestStr];
            
            NSDictionary *routingDef = [self routingSchemeForRequest:request];
            
            return [NSJSONSerialization dataWithJSONObject:@{@"Result": routingDef} options:0 error:nil];
        } else if ([command isEqualToString:@"Extension ID"]) {
            return [NSJSONSerialization dataWithJSONObject:@{@"Result": [NSNumber numberWithInt:extensionID]} options:0 error:nil];
        } else if ([command isEqualToString:@"Finalize"]) {
            //This is the message trigger the extension to finalize the actions, and come up with a return string
            NSString *finalizeResult = [self finalizeSession:inputDict[@"Session ID"]];
            return [NSJSONSerialization dataWithJSONObject:@{@"Msg": finalizeResult} options:0 error:nil];
        } else if ([command isEqualToString:@"compareInHouse"]) {
            NSArray *uuids = inputDict[@"UUIDs"];
            id obj1 = [self objectForUUID:uuids[0]]; id obj2 = [self objectForUUID:uuids[1]];
            NSComparisonResult result = [obj1 compare:obj2];
            NSNumber *resultInNumber = [NSNumber numberWithInteger:result];
            return [NSJSONSerialization dataWithJSONObject:@{@"Success": @"", @"Result": resultInNumber} options:0 error:nil];
        }
        
    }
    @catch (NSException *exception) {
        //If anything happen, it returns an empty dictionary
        return [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
    }
    @finally {}
    
}

- (NSString *)getInstanceUUID:(GCEObjectRequest *)instanceRequest {
    GCEObject *obj = instanceList[instanceRequest.objID];
    return [self getUUIDForObject:obj];
}

- (void)registerInstance:(GCEObject *)newObj {
    [self.instanceList addObject:newObj];
}

- (NSString *)getUUIDForObject:(NSObject *)obj {
    if (![objectList.allValues containsObject:obj]) {
        NSUUID *newUUID = [NSUUID UUID];
        [objectList setObject:obj forKey:newUUID];
        return newUUID.UUIDString;
    } else {
        NSUInteger index = [objectList.allValues indexOfObject:obj];
        NSUUID *uuid = [objectList.allKeys objectAtIndex:index];
        return uuid.UUIDString;
    }
}

+ (instancetype)singleExtension {
    static GCEExtension *ext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ext = [self new];
    });
    return ext;
}

- (NSString *)getAttributeFromObject:(NSString *)uuid forKeyPath:(NSString *)keyPath {
    NSObject *obj = [self getRawAttributeFromObject:uuid forKeyPath:keyPath];
    return [self getUUIDForObject:obj];
}

- (NSObject *)getRawAttributeFromObject:(NSString *)uuid forKeyPath:(NSString *)keyPath {
    NSObject *obj = [self objectForUUID:uuid];
    NSObject *attribute = [obj valueForKeyPath:keyPath];
    return attribute;
}

- (id)objectForUUID:(NSString *)uuid {
    NSUUID *_u = [[NSUUID alloc] initWithUUIDString:uuid];
    return self.objectList[_u];
}

@end