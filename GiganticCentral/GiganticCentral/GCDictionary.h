//
//  GCDictionary.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/1/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDictionary : NSObject
+ (instancetype)sharedDictionary;
- (void)attachToDictionary:(id)sender typeID:(NSNumber *)typeID;
- (NSArray *)tokensForWord:(NSString *)word;
@property (readonly) NSMutableDictionary *dictionary;
@end
