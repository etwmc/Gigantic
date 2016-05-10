//
//  GCQuerySolution.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCObject.h"
#import "GCQueryConstant.h"

@interface QuerySolution : NSObject
@property (assign) queryType type;
@property (strong) NSArray *constraintsResult;
@property (strong) NSArray *respondFormat;
@property (strong) NSArray *resultObjs;
@property (strong) NSString *resultDialog, *errorMessage;
@end