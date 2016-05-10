//
//  LyricFinder.h
//  GCExtend
//
//  Created by Wai Man Chan on 4/16/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <GCExtend/GCExtend.h>

#import <Cocoa/Cocoa.h>

@interface rawMessage : GCEObject
@property (readwrite) NSString *message;
@end

@interface LyricFinder : GCEExtension {
    rawMessage *successedMessage_single;
    rawMessage *successedMessage_multiple;
    rawMessage *failedMessage_multiple;
}
@end
