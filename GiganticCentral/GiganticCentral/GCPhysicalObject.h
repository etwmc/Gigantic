//
//  GCPhysicalObject.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/20/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCObject.h"
#import "GCTime.h"
#import "GCLocation.h"

@interface GCPhysicalObject : GCObject <NSCoding>
/*
 * Creation Time is the physical object creation time
 * i.e. For human, it's birthday. 
 * If the creation time is unknown, input 1970
 */
@property (readwrite, strong) GCTime *creationTime;
@property (readwrite) GCLocation *location;
@end
