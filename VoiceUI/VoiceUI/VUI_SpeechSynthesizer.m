//
//  VUI_SpeechSynthesizer.c
//  VoiceUI
//
//  Created by Wai Man Chan on 3/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "VUI_SpeechSynthesizer.h"
#import <dispatch/dispatch.h>

#define backgroundSound

#ifdef __APPLE__
#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
typedef NSSpeechSynthesizer synthesizerType;
dispatch_semaphore_t synthesizerSem;
@interface VUISynthesizerDelegate : NSObject <NSSpeechSynthesizerDelegate, AVAudioPlayerDelegate> {
#pragma - Background Player
    NSArray *playlist;
    NSInteger playlistIndex;
    AVAudioPlayer *backgroundPlayer;
    NSTimer *restoreVolumeTimer;
}
- (void)startPlaylist:(NSArray *)newPlaylist;
- (void)startV;
@end
@implementation VUISynthesizerDelegate
#pragma - Background Player
- (void)startV {
    [restoreVolumeTimer invalidate];
    restoreVolumeTimer = nil;
    backgroundPlayer.volume = 0.05;
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self audioPlayerDidFinishPlaying:player successfully:false];
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    float volume = player? player.volume: 1;
    playlistIndex++;
    if (!flag) {
        
    }
    if (playlistIndex < playlist.count) {
        backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:playlist[playlistIndex]] error:nil];
        [backgroundPlayer prepareToPlay];
        backgroundPlayer.delegate = self;
        backgroundPlayer.volume = volume;
        [backgroundPlayer play];
    }
}
- (void)restoreVolume { backgroundPlayer.volume = 1.0; }
- (void)startPlaylist:(NSArray *)newPlaylist {
    //Stop current track, restore state
    if (backgroundPlayer)
        [backgroundPlayer stop];
    playlistIndex = -1;
    
    playlist = newPlaylist;
    
    //Start playing
    [self audioPlayerDidFinishPlaying:nil successfully:YES];
}
#pragma - Speech Synthesizer
- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking {
    if (finishedSpeaking) {
        dispatch_semaphore_signal(synthesizerSem);
        restoreVolumeTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(restoreVolume) userInfo:nil repeats:NO];
    }
}

@end
VUISynthesizerDelegate *speechDelegate;
#endif

synthesizerType *synthesizer;

void initSynthesizer() {
#ifdef __APPLE__
    synthesizer = [NSSpeechSynthesizer new];
    synthesizer.delegate = speechDelegate = [VUISynthesizerDelegate new];
    synthesizerSem = dispatch_semaphore_create(1);
#if DEBUG
    [synthesizer setUsesFeedbackWindow:true];
#endif
#endif
}

void playMessage(const char *m) {
#ifdef __APPLE__
    [speechDelegate startV];
    NSString *str = [NSString stringWithUTF8String:m];
    [synthesizer startSpeakingString:str];
#endif
}

void waitTillMessagePlayThr() {
    dispatch_semaphore_wait(synthesizerSem, DISPATCH_TIME_FOREVER);
}

void playMusic(const char *playlist) {
#ifdef __APPLE__
    @autoreleasepool {
        NSData *playlistAsData = [NSData dataWithBytes:playlist length:strlen(playlist)];
        NSArray *playlistArray = [NSJSONSerialization JSONObjectWithData:playlistAsData options:0 error:nil];
        if (playlistArray) [speechDelegate startPlaylist:playlistArray];
    }
#endif
}