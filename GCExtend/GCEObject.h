//
//  GCEObject.h
//  GCExtend
//
//  Created by Wai Man Chan on 10/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCEObjectRequest.h"

typedef enum {
    judgementCall_true = 1,
    judgementCall_false = 0,
    judgementCall_fail = -1
} judgementCall;

@interface GCEObject : NSObject <NSObject, NSCoding>

//Fetch related object
- (NSArray *)getSubObjects:(GCEObjectRequest *)objectInfo;
- (NSObject *)getAttribute:(GCEObjectRequest *)attribute;
//Perform Actions
- (GCEObject *)performAction:(NSArray *)actions;

- (judgementCall)judge:(GCEObjectRequest *)judgement;

+ (NSString *)routingName;

+ (void)initialDict;

+ (instancetype)getInstanceFromRequest:(GCEObjectRequest *)request;

+ (void)addSupportExtension:(NSObject *)extension withName:(NSString *)name;
+ (void)removeSupportExtension:(NSObject *)extension withName:(NSString *)name;

@property (readwrite) NSString *pronoun, *possessiveDeterminer, *name, *variationOfBe;
@property (readonly) phaseType type;
@property (readwrite) GCEObject *rootObj;
@property (readonly) NSUUID *uuid;

/*
 * This should be declare at the root object
 */
- (BOOL)setObjectWithAdjective:(NSString *)adjective;
- (double)ratingOfObject;

@end
