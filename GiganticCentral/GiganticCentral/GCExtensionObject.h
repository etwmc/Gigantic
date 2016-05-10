//
//  GCExtensionObject.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 1/27/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCObject.h"
#import "GCExtension.h"

@interface GC_ExtensionObject : GCObject
//Fetch related object
- (NSObject *)getAttribute:(GCObjectRequest *)attribute;
//Perform Actions
- (GCObject *)performAction:(NSArray *)actions;

- (judgementCall)judge:(GCObjectRequest *)judgement;

+ (NSString *)routingName;

+ (instancetype)getInstanceFromRequest:(GCObjectRequest *)request;

+ (void)addSupportExtension:(NSObject *)extension withName:(NSString *)name;
+ (void)removeSupportExtension:(NSObject *)extension withName:(NSString *)name;

@property (readonly) NSString *pronoun, *possessiveDeterminer, *name, *variationOfBe;
@property (readwrite) GCObject *rootObj;
//UUID is defined by the extension, used for extension to track the object
@property (readwrite) NSUUID *uuid;
//Extension is the plugin connection to relay the message
@property (readwrite) GC_Extension *extension;
@end
