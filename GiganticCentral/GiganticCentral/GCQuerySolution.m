//
//  GCQuerySolution.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCQuerySolution.h"

@implementation QuerySolution
@synthesize type, constraintsResult, resultObjs, resultDialog, errorMessage;
- (id)init {
    self = [super init];
    if (self) {
        constraintsResult = @[];
        resultObjs = @[];
    }
    return self;
}
@end
