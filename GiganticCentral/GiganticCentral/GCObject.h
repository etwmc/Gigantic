//
//  GCObject.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/19/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObjectRequest.h"
#import "GCObjectConstant.h"


typedef enum {
    judgementCall_true = 1,
    judgementCall_false = 0,
    judgementCall_fail = -1
} judgementCall;

@class GCObject;

@interface _obj : NSObject <NSObject, NSCoding>

//Fetch related object
- (NSArray *)getSubObjects:(GCObjectRequest *)objectInfo;
+ (NSArray *)getSubObjects:(GCObjectRequest *)objectInfo fromObject:(GCObject *)obj;
- (NSObject *)getAttribute:(GCObjectRequest *)attribute;

//Perform Actions
@property (readonly, atomic) NSUInteger startActionPerformSession;
- (GCObject *)performAction:(NSArray *)actions forSession:(NSUInteger)sessionID;;
- (BOOL)performActionDictionary:(NSDictionary *)actionDictionary forSession:(NSUInteger)sessionID;
- (void)undoActionPerformSession:(NSUInteger)sessionID;
- (NSString *)finalizeActionPerformSession:(NSUInteger)sessionID;

- (judgementCall)judge:(GCAdjectiveRequest *)judgement fromSampleSet:(NSArray *)sampleSet;

+ (NSDictionary *)getRouting:(GCObjectRequest *)attribute;

+ (NSString *)routingName;

+ (void)initialDict;

+ (instancetype)getInstanceFromRequest:(GCObjectRequest *)request;

- (NSString *)responseForRequest:(GCObjectRequest *)request;

+ (void)addSupportExtension:(NSObject *)extension withName:(NSNumber *)name;
+ (void)removeSupportExtension:(NSObject *)extension withName:(NSNumber *)name;

//For testing only
+ (NSArray *)vocabulatory:(phaseType)type;

- (void)voiceOutput:(NSString *)outputDialogue;

@property (readonly) NSString *pronoun, *possessiveDeterminer, *name, *variationOfBe;
@property (readwrite) GCObject *rootObj;
//UUID on object, in the whole system
@property (readonly) NSUUID *uuid;

@property (readwrite) NSString *outputFormat;
@end

@interface GCObject : _obj
@end
