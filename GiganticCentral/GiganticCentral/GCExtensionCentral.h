//
//  ExtensionCentral.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 6/12/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <dispatch/dispatch.h>
#import "GCExtension.h"
#import <Foundation/Foundation.h>

@interface GCExtensionCentral : NSObject {
    NSMutableArray *_extensions;
    int _socket; //Socket of the central
    dispatch_queue_t queue;
}
@property (readonly) NSArray *extensions;
@property (readonly) NSMutableDictionary *registeredObj;
+ (GCExtensionCentral *)defaultCentral;
+ (GC_Extension *)extensionForID:(int)extensionID;
+ (void)registerUUID:(NSString *)uuid fromExtension:(GC_Extension *)extension;
+ (void)registerUUID:(NSString *)uuid forLocalObject:(GCObject *)object;
+ (GC_Extension *)extensionForUUID:(NSString *)uuid;
@end