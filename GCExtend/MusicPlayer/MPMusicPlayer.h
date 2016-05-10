//
//  MPMusicPlayer.h
//  GCExtend
//
//  Created by Wai Man Chan on 1/27/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <GCExtend/GCExtend.h>

#define GCERecord GCEObject
#define GCEPerson GCEObject

@class MPSinger, MPAlbum;

@interface MPTrack : GCERecord
@property (readwrite) MPSinger *singer;
@property (readwrite) MPAlbum *album;
@property (readwrite) NSURL *location;
@end

@interface MPSinger : GCEPerson
@property (readwrite) NSArray *allAlbums;
@property (readwrite) NSArray *allTracks;
@end

@interface MPAlbum : GCERecord
@property (readwrite) NSArray *allTracks;
@property (readwrite) MPSinger *singer;
@property (readwrite) GCETime *creationDate;
@property (readonly) NSNumber *numberOfTrack;
@end

@interface MPMusicPlayer : GCEExtension
- (void)startUpdatePlaylist;
- (void)updatePlaylist:(GCEObject *)obj;
- (void)resetUpdatePlaylist;
- (void)finalizeUpdatePlaylist;
- (void)registerInstance:(NSObject *)newObj;
@end