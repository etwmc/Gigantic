//
//  VUI_SpeechSynthesizer.h
//  VoiceUI
//
//  Created by Wai Man Chan on 3/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __VoiceUI__VUI_SpeechSynthesizer__
#define __VoiceUI__VUI_SpeechSynthesizer__

#import "ShareConstant.h"

void playMessage(const char *m);
void waitTillMessagePlayThr();

void playMusic(const char *playlist);

void initSynthesizer();

#endif /* defined(__VoiceUI__VUI_SpeechSynthesizer__) */
