//
//  GCEExtension.h
//  GCExtend
//
//  Created by Wai Man Chan on 6/12/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __GCExtend__GCEExtension__
#define __GCExtend__GCEExtension__

#import <Foundation/Foundation.h>
#import "GCEObjectRequest.h"

extern int extensionID;

/*
 * GCEExtension is the class for getting access to GCEObjects
 * It could access to local databases, Internet, databases, and derivative from other objects. 
 * Each extension could only contain ONE type of objects, where objects could belongs to a bigger object
 * To ensure secuirty, and minimize the risk of "service downtime"
 * Any implment should directly subclass from
 */

@class GCEObject;

@interface GCEExtension : NSObject

- (NSObject *)getRawAttributeFromRemoteObject:(NSString *)rootObjUUID forKeyPath:(NSString *)keyPath;

+ (instancetype)singleExtension;
- (void)startExtension;
- (void)stopExtension;

- (NSDictionary *)routingSchemeForRequest:(GCEObjectRequest *)request;

/*
 * The following functions are respondable for declare the actual extension exchange
 * They are not implemented, as it's implemented in the extension end
 */
- (id)initWithExtensionName:(NSString *)name extensionID:(int)eid andDictionaryAddress:(NSString *)addr;

//Function set for instances access
- (void)registerInstance:(GCEObject *)newObj;
- (NSString *)getInstanceUUID:(GCEObjectRequest *)instanceRequest;

//Function for 
- (NSArray *)getSubObjectUUID:(GCEObjectRequest *)subObjectRequest fromRoot:(NSString *)rootObjUUID;
- (NSString *)setAction:(NSDictionary *)actionDictionary atObjects:(NSArray *)objs;
- (NSString *)getAttributeFromObject:(NSString *)uuid forKeyPath:(NSString *)keyPath;
- (NSString *)finalizeSession:(NSUInteger)sessionID;

- (id)objectForUUID:(NSString *)uuid;
- (NSString *)getUUIDForObject:(NSObject *)obj;

@property (readonly) NSString *extensionName;
@property (readonly) NSString *dictionaryAddr;
@property (readwrite) int extensionID;

@property (readonly, assign, atomic) bool localRunning, remoteRunning;

@property (readonly) NSMutableArray *instanceList;
@property (readonly) NSMutableDictionary *objectList;

@end

/*
 * We need a autorelease pool to contain everything
 */

#endif /* defined(__GCExtend__GCEExtension__) */
