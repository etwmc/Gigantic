//
//  GCValue.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/24/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCObject.h"

@interface GCValue : GCObject
@property (readonly, strong) NSNumber *value;
- (id)initNumber:(NSNumber *)number;
@end

@interface GCActionResultValue : GCValue
@property (readwrite, strong) NSString *actionResult;
@end