//
//  GCObjectRequest.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObjectConstant.h"

@interface GCObjectRequest : NSObject
- (instancetype)initWithString:(NSString *)str;
/*
 * Creator is the extension that create and handling such object
 */
@property (readonly) long creator;
/*
 * Type represent the type of object it is
 */
@property (readonly) phaseType type;
/*
 * Obj ID is a number, for the extension and the central keep track of the object.
 * All object interaction at central are relay in a message to the extension with the object ID.
 * In the extension side, the Object ID is a
 */
@property (readwrite) long objID;

@property (readonly) NSString *requestString;

@end

@interface GCActionObjectRequest : GCObjectRequest
@property (readonly) NSMutableDictionary *modifierDictionary;
@end

typedef enum {
    GCAdjectiveRequestMode_describe,
    GCAdjectiveRequestMode_compare,
    GCAdjectiveRequestMode_absolute
} GCAdjectiveRequestMode;

@interface GCAdjectiveRequest : GCObjectRequest
@property (readonly) GCAdjectiveRequestMode mode;
@end