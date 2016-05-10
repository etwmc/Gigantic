//
//  GCTextParser.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/3/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCTextParser : NSObject
+ (void)parseIncoming;
+ (dispatch_semaphore_t)outputSemaphore;
+ (NSArray *)constructHyphtosisFromTokens:(NSArray *)tokens;
@end
