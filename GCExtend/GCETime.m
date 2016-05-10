//
//  GCETime.m
//  GCExtend
//
//  Created by Wai Man Chan on 2/10/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCETime.h"

@implementation GCETime
@synthesize realTime;
- (NSComparisonResult)compare:(GCETime *)other
{
    return [self.realTime compare:other.realTime];
}
@end
