//
//  GCVoiceInput.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 1/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __GiganticCentral__GCVoiceInput__
#define __GiganticCentral__GCVoiceInput__

#import <stdio.h>
#import <julius/julius.h>

#import <Foundation/Foundation.h>

@interface GCVoiceInputManager : NSObject
+ (instancetype)sharedManager;
- (void)startInput;
- (void)stopInput;
- (void)loadExtensionDictionary:(NSString *)dictionaryAddress withID:(NSUInteger)extID;
@end

#endif /* defined(__GiganticCentral__GCVoiceInput__) */
