//
//  GCContext.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 12/15/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCCollection.h"

@interface GCContext : GCObject
+ (GCContext *)currentContext;
- (GCTime *)currentTimeWithMask:(NSNumber *)mask;
@end
