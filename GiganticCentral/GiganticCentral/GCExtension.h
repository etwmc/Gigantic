//
//  GCExtension.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 16/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __GiganticCentral__GCExtension__
#define __GiganticCentral__GCExtension__

#import "GCObject.h"
#import "GCObjectRequest.h"
#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>


@interface GC_Extension : NSObject
@property (readonly) int extensionID;
- (bool)rawInputForObject:(GCObjectRequest *)obj buffer:(const char *)buffer;
//Every extension object in central come from a connection
- (NSString *)name;
- (instancetype)initWithSocket:(int)socket;
//Extension feature
- (GCObject *)getInstanceFromRequest:(GCObjectRequest *)request;
- (NSArray *)getObjectsFromRequest:(GCObjectRequest *)request;

- (NSDictionary *)sendCommand:(NSString *)command withParameters:(NSDictionary *)parameters;

- (NSDictionary *)routingForRequest:(GCObjectRequest *)request;

- (NSArray *)vocabulatory:(phaseType)type;

//Dictionary
@property (readonly) NSString *dictionaryAddr;
@end

#endif /* defined(__GiganticCentral__GCExtension__) */
