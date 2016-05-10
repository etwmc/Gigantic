//
//  GCELocation.m
//  GCExtend
//
//  Created by Wai Man Chan on 10/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCELocation.h"

@implementation GCELocation
@synthesize address;
@synthesize phoneNumber;
@synthesize latitude;
@synthesize longitude;
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ is %@", self.name, self.address];
}
@end
