//
//  GCAttribute.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/6/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "GCObject.h"

@interface GCAttribute : GCObject
@property (readonly) BOOL ready, fetching;
- (id)initWithAttributeFetch:(id(^)())fetcher;
- (void)prepareAttribute;
/*
 * Subcalss only this method
 */
- (void)valueChange:(id)result;

@property (readonly) id(^fetcher)();
@property (readwrite, atomic, strong) NSString *(^longFetchBlock)();
@property (readwrite, atomic, strong) NSString *(^completitionBlock)(id value);
@end
