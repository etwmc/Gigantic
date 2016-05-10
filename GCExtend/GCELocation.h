//
//  GCELocation.h
//  GCExtend
//
//  Created by Wai Man Chan on 10/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCEObject.h"

@interface GCELocation : GCEObject
@property (readonly) NSString *address;
@property (readonly) NSString *phoneNumber;
@property (readonly, assign) double latitude;
@property (readonly, assign) double longitude;
@end
