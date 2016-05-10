//
//  GCBoolean.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 1/5/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCValue.h"

@interface GCBoolean : GCValue

@end

@interface GCObject (GCObjectYesNoResult)
//Whether the object fits constraints
- (GCValue *)checkConstraints:(NSArray *)constraints;
@end