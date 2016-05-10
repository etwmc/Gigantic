//
//  GCBoolean.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 1/5/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCBoolean.h"
#import "GCTime.h"

@implementation GCBoolean

- (NSString *)description {
    if (self.value.boolValue) return @"Yes";
    else return @"No";
}

@end

@implementation GCObject (GCObjectYesNoResult)
- (GCBoolean *)checkConstraints:(NSArray *)constraints {
    judgementCall result = judgementCall_true;
    for (GCAdjectiveRequest *request in constraints) {
        result = [self judge:request fromSampleSet:@[self]];
        if (result <= 0) break;
    }
    return [[GCBoolean alloc] initNumber:[NSNumber numberWithInt:result]];
}

@end