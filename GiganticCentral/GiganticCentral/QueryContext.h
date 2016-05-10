//
//  QueryContext.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 10/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"

@class Query;

@interface QueryContext : NSObject
/*
 * Parameter:
 * Query: the content of query
 * Transcation Partition: an id for a hypotheses section
 * Return Value: an id for the query
 */
@property (strong) GCObject *userObj;
@property (strong) GCObject *deviceObj;
@property (strong) NSArray *lastObjs;

- (bool)startQuery:(Query *)query withPartition:(int)partition;
- (void)preserveQueryResult:(Query *)query;
+ (QueryContext *)sharedQuery;
- (NSArray *)traceObject:(NSString *)objectStr;
- (BOOL)objectCanBeTrace:(NSString *)objectStr;
- (void)registerObjectType:(id)type withID:(NSNumber *)objTypeID;
- (Class)classForKey:(NSNumber *)key;
@end