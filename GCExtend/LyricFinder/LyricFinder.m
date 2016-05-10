//
//  LyricFinder.m
//  GCExtend
//
//  Created by Wai Man Chan on 4/16/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "LyricFinder.h"

#import <sys/socket.h>

#import <sys/un.h>

@implementation rawMessage
@synthesize message;
- (NSString *)description { return message; }
@end

@implementation LyricFinder

- (NSArray *)getSubObjectUUID:(GCEObjectRequest *)subObjectRequest fromRoot:(NSString *)rootObjUUID {
    switch (subObjectRequest.objID) {
        case 0: {
            //"lyric" of something
            NSString *className = [self getRawAttributeFromRemoteObject:rootObjUUID forKeyPath:@"className"];
            if ([className containsString:@"Album"]) {
                if ([[self getRawAttributeFromRemoteObject:rootObjUUID forKeyPath:@"numberOfTrack"] isGreaterThan:@1]) {
                    return @[[self getUUIDForObject:failedMessage_multiple]];
                }
                NSString *songTitle = [self getRawAttributeFromRemoteObject:rootObjUUID forKeyPath:@"name"];
                NSString *singerName = [self getRawAttributeFromRemoteObject:rootObjUUID forKeyPath:@"singer.name"];
                NSURL *url = [[NSURL alloc] initWithScheme:@"lyric" host:singerName path:[NSString stringWithFormat:@"/%@", songTitle]];
                if ([[NSWorkspace sharedWorkspace] openURL:url]) {
                    return @[[self getUUIDForObject:successedMessage_single]];
                }
            }
            
            return @[];
            break;
        }
            
        default:
            return @[];
            break;
    }
}

- (id)init {
    self = [super initWithExtensionName:@"Lyric Finding Extension" extensionID:1002 andDictionaryAddress:@"/vui/profile/LyricGenius/LyricGenius.dict"];
    if (self) {
        successedMessage_single = [rawMessage new];
        successedMessage_single.message = @"The lyric is display on your tablet";
        
        successedMessage_multiple = [rawMessage new];
        successedMessage_multiple.message = @"The lyrics are display on your tablet";
        
        failedMessage_multiple = [rawMessage new];
        failedMessage_multiple.message = @"There is multple songs in the album";
    }
    return self;
}
@end
