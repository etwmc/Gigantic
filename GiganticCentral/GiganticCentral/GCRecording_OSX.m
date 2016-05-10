//
//  GCRecording.c
//  GiganticCentral
//
//  Created by Wai Man Chan on 5/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#include "GCRecording.h"
#import "../../Gigantic_GlobalConstant.h"
#import <AVFoundation/AVFoundation.h>

AVAudioRecorder *recorder;

void startRecording() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:GiganticQueryRecordingAddress]];
        recorder = [[AVAudioRecorder alloc] initWithURL:url settings:@{AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVSampleRateKey: [NSNumber numberWithFloat:44100], AVNumberOfChannelsKey: [NSNumber numberWithInt:1], AVEncoderAudioQualityKey: [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderBitRateKey: [NSNumber numberWithInt:12800]} error:NULL];
    });
    [recorder record];
}

void stopRecording() {
    [recorder stop];
}