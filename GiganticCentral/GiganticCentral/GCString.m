//
//  GCString.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/9/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCString.h"

@implementation GCString
@synthesize string;
- (NSString *)description {
    if (self.outputFormat) return @"";
    else return string;
}
@end
