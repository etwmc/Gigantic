//
//  NSString_GCHelperFunction.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/9/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCString;

@interface NSString(whiteSpaceJoint)
- (GCString *)stringByWhiteSpaceJoint:(NSString *)second;
@end
