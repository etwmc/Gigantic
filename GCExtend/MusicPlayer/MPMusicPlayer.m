//
//  MPMusicPlayer.m
//  GCExtend
//
//  Created by Wai Man Chan on 1/27/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "MPMusicPlayer.h"

#import "../../VoiceUI/VIKit/VIKit.h"

NSString *stringOfExtensionClass(Class c) {
    NSString *string = NSStringFromClass(c);
    return [string stringByReplacingCharactersInRange:NSMakeRange(2, 1) withString:@""];
}

@implementation MPTrack
@synthesize singer, album, location;
- (void)play {
    MPMusicPlayer *ext = [MPMusicPlayer singleExtension];
    [ext updatePlaylist:self];
}
- (void)stop {
    MPMusicPlayer *ext = [MPMusicPlayer singleExtension];
    [ext resetUpdatePlaylist];
}
@end
@implementation MPSinger
@synthesize allAlbums;
@dynamic allTracks;
- (NSArray *)allTracks {
    NSArray *array = @[];
    for (MPAlbum *album in self.allAlbums) {
        array = [array arrayByAddingObjectsFromArray:album.allTracks];
    }
    return array;
}
- (void)play {
    MPMusicPlayer *ext = [MPMusicPlayer singleExtension];
    [ext updatePlaylist:self];
}
- (void)stop {
    MPMusicPlayer *ext = [MPMusicPlayer singleExtension];
    [ext resetUpdatePlaylist];
}
@end
@implementation MPAlbum
@synthesize allTracks, singer, creationDate;
- (NSNumber *)numberOfTrack {
    return [NSNumber numberWithUnsignedInt:allTracks.count];
}
- (void)play {
    MPMusicPlayer *ext = [MPMusicPlayer singleExtension];
    [ext updatePlaylist:self];
}
- (void)stop {
    MPMusicPlayer *ext = [MPMusicPlayer singleExtension];
    [ext resetUpdatePlaylist];
}
@end

@interface MPMusicPlayer () {
    NSMutableDictionary *pendingActionList;
    
    NSArray *playlist;
    NSMutableArray *newPlaylist;
}
@end
@implementation MPMusicPlayer

- (NSString *)setAction:(NSDictionary *)actionDictionary atObjects:(NSArray *)objs {
    NSArray *commands = actionDictionary[@"Commands"];
    for (NSDictionary *dict in commands) {
        SEL commandSelector = NSSelectorFromString(dict[@"Command"]);
        for (NSString *strUUID in objs) {
            NSUUID *objUUID = [[NSUUID alloc] initWithUUIDString:strUUID];
            GCEObject *obj = self.objectList[objUUID];
            if (commandSelector && obj) {
                @try {
                    [self startUpdatePlaylist];
                    [obj performSelector:commandSelector];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception);
                    return @"Fail";
                }
                @finally {}
            }
        }
    }
    return @"Success";
}

- (void)startUpdatePlaylist {
    if (!newPlaylist) newPlaylist = [NSMutableArray new];
}

- (void)resetUpdatePlaylist {
    newPlaylist = [NSMutableArray new];
}

- (void)updatePlaylist:(GCEObject *)obj {
    if (obj == nil) return;
    if (obj.class == MPTrack.class) [newPlaylist addObject:obj];
    else [newPlaylist addObjectsFromArray:[(MPSinger *)obj allTracks]];
}

- (void)finalizeUpdatePlaylist {
    if (newPlaylist.count) {
        NSLog(@"The following songs to be played: %@", playlist);
    } else { NSLog(@"Empty new playlist"); }
    playlist = [NSArray arrayWithArray:newPlaylist];
    
    NSMutableArray *array = [NSMutableArray new];
    [playlist enumerateObjectsUsingBlock:^(MPTrack *obj, NSUInteger idx, BOOL *stop) {
        array[idx] = obj.location.path;
    }];
    
    NSData *playlistData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
    
    if (playlist) VIsetPlaylist(playlistData.bytes, playlistData.length);
    newPlaylist = nil;
}

- (NSString *)finalizeSession:(NSUInteger)sessionID {
    [self finalizeUpdatePlaylist];
    switch (playlist.count) {
        case 0:
            return @"No music will be played";
            break;
        case 1: {
            MPTrack *track = playlist[0];
            return [NSString stringWithFormat:@"Now playing, %@ by %@", track.name, track.singer.name];
        }
        default:{
            return [NSString stringWithFormat:@"%d songs will be played", playlist.count];
        }
            break;
    }
}

- (NSArray *)getSubObjectUUID:(GCEObjectRequest *)subObjectRequest fromRoot:(NSString *)rootObjUUID {
    switch (subObjectRequest.objID) {
            //Noun 1 = Album
        case 1: {
            NSMutableArray *array = [NSMutableArray new];
            if (rootObjUUID) {
                MPSinger *singer = self.objectList[[[NSUUID alloc] initWithUUIDString:rootObjUUID]];
                for (MPAlbum *album in singer.allAlbums) {
                    if (album.allTracks.count > 1) [array addObject:[self getUUIDForObject:album]];
                }
            } else {
                for (MPSinger *singer in self.instanceList) {
                    for (MPAlbum *album in singer.allAlbums) {
                        if (album.allTracks.count > 1) [array addObject:[self getUUIDForObject:album]];
                    }
                }
            }
            return array;
        }
            //Noun 0 = music
        case 0:
            //Noun 2 = song
        case 2: {
            NSMutableArray *array = [NSMutableArray new];
            if (rootObjUUID) {
                MPSinger *singer = self.objectList[[[NSUUID alloc] initWithUUIDString:rootObjUUID]];
                for (MPTrack *songs in singer.allTracks) {
                    [array addObject:[self getUUIDForObject:songs]];
                }
            } else {
                for (MPSinger *singer in self.instanceList)
                    for (MPTrack *songs in singer.allTracks) {
                        [array addObject:[self getUUIDForObject:songs]];
                    }
            }
            return array;
        }
            //Noun 3 = Single
        case 3: {
            
            MPSinger *singer = self.objectList[[[NSUUID alloc] initWithUUIDString:rootObjUUID]];
            NSMutableArray *array = [NSMutableArray new];
            for (MPAlbum *album in singer.allAlbums) {
                if (album.allTracks.count == 1) [array addObject:[self getUUIDForObject:album]];
            }
            return array;
        }
    }
    return @[];
}

- (NSDictionary *)routingSchemeForRequest:(GCEObjectRequest *)request {
    switch (request.type) {
            //Routing of Verb
        case phaseType_verb:
            switch (request.objID) {
                    //Play
                case 0:
                    return @{@"Commands": @[
                                     @{@"Command": @"play"}
                                     ], @"Return Value": [NSNumber numberWithBool:false]};
                case 1:
                    return @{@"Commands": @[
                                     @{@"Command": @"stop"}
                                     ], @"Return Value": [NSNumber numberWithBool:false]};
            }
    }
    return nil;
}

MPTrack *createTrack(NSString *trackName, MPSinger *singer, MPAlbum *album)
{ MPTrack *track = [MPTrack new]; track.name = trackName; track.singer = singer; track.album = album;
    track.location = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/vui/profile/Music Player/files/%@.m4a", trackName]];
    return track;
}
- (id)init {
    self = [super initWithExtensionName:@"Music Player Extension" extensionID:1000 andDictionaryAddress:@"/vui/profile/Music Player/musicPlayer.dict"];
    if (self) {
        
        MPSinger *taylor = [MPSinger new];  taylor.name = @"Taylor Swift";
        {
            //New Romantics - Single
            MPAlbum *taylor_nr = [MPAlbum new];
            {
                taylor_nr.creationDate = [GCETime new];
                taylor_nr.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1425373200];
                taylor_nr.name = @"New Romantics";
                taylor_nr.singer = taylor;
                taylor_nr.allTracks = @[createTrack(@"New Romantics", taylor, taylor_nr)];
            }
            //1989
            MPAlbum *taylor_1989 = [MPAlbum new];
            {
                taylor_1989.creationDate = [GCETime new];
                taylor_1989.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1414368000];
                taylor_1989.name = @"1989";
                taylor_1989.singer = taylor;
                taylor_1989.allTracks = @[createTrack(@"Welcome to New York", taylor, taylor_1989), createTrack(@"Blank Space", taylor, taylor_1989), createTrack(@"Style", taylor, taylor_1989), createTrack(@"Out of the Woods", taylor, taylor_1989)];
            }
            //Red
            MPAlbum *taylor_red = [MPAlbum new];
            {
                taylor_red.name = @"Red";
                taylor_red.creationDate = [GCETime new];
                taylor_red.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1350864000];
                taylor_red.singer = taylor;
                taylor_red.allTracks = @[createTrack(@"State Of Grace", taylor, taylor_red), createTrack(@"Red", taylor, taylor_red), createTrack(@"22", taylor, taylor_red)];
            }
            MPAlbum *taylor_speakNow = [MPAlbum new];   taylor_speakNow.name = @"Speak Now"; taylor_speakNow.creationDate = [GCETime new];   taylor_speakNow.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1287964800];
            MPAlbum *taylor_fearless = [MPAlbum new];   taylor_fearless.name = @"Fearless"; taylor_fearless.creationDate = [GCETime new];    taylor_fearless.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1226361600];
            MPAlbum *taylor_taylorSwift = [MPAlbum new];   taylor_taylorSwift.name = @"Taylor Swift"; taylor_taylorSwift.creationDate = [GCETime new];   taylor_taylorSwift.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1161648000];
            
            taylor.allAlbums = @[taylor_nr, taylor_1989, taylor_fearless, taylor_red, taylor_speakNow, taylor_taylorSwift];
        }
        
        
        [self registerInstance:taylor];
        
        //Define Lady GaGa
        MPSinger *gaga = [MPSinger new];  gaga.name = @"Lady GaGa";
        {
            //New Romantics - Single
            MPAlbum *btw = [MPAlbum new];
            {
                btw.creationDate = [GCETime new];
                btw.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1414368001];
                btw.name = @"Born This Way";
                btw.singer = gaga;
                btw.allTracks = @[createTrack(@"Born This Way", gaga, btw), createTrack(@"Judas", gaga, btw)];
            }
            //New Romantics - Single
            MPAlbum *br = [MPAlbum new];
            {
                br.creationDate = [GCETime new];
                br.creationDate.realTime = [NSDate dateWithTimeIntervalSince1970:1414368000];
                br.name = @"Bad Romance";
                br.singer = gaga;
                br.allTracks = @[createTrack(@"Bad Romance", gaga, br)];
            }
            
            gaga.allAlbums = @[br, btw];
        }
        
        [self registerInstance:gaga];
    }
    return self;
}
@end