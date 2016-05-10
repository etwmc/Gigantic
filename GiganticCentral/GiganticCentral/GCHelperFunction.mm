//
//  NSString_GCHelperFunction.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/9/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCHelperFunction.h"

#import "GCString.h"

@implementation NSString(whiteSpaceJoint)
- (GCString *)stringByWhiteSpaceJoint:(id)second {
    GCString *string = [[GCString alloc] init];
    string.string = [self stringByAppendingFormat:@" %@", second];
    return string;
}
@end
