//
//  ObjectTrace.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 6/27/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "ObjectTrace.h"
#import "GCObject.h"
#import <Foundation/Foundation.h>

NSArray *separateElemet(NSString *source) {
    return [source componentsSeparatedByString:@"->"];
}