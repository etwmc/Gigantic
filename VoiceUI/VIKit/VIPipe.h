 //
//  VIPipe.h
//  VoiceUI
//
//  Created by Wai Man Chan on 6/17/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#include <stdbool.h>

extern char applicationName[16];

void VIpresentNotification(const char *summary, const char *description);
void VIpresentDialog(const char *dialog, bool needFeedback);
void VIsetPlaylist(const char *playlistPackage, unsigned int len);