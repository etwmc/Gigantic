//
//  ShareContact.h
//  VoiceUI
//
//  Created by Wai Man Chan on 6/18/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

typedef enum {
    //V1 flag
    packetType_notification,
    packetType_dialog,
} packetType;

#define packetLen 8192

#define senderLen 16
#define vui_contentLen packetLen-4-senderLen

typedef struct {
    packetType type;
    char version;
    char flag;
    char sender[senderLen];
    char content[vui_contentLen];
} packet;

/* Notification Structure */

#define notification_v1_msgLen 64
#define notification_v1_vui_contentLen vui_contentLen-notification_v1_msgLen

typedef struct {
    char message[notification_v1_msgLen];
    char fullContent[notification_v1_vui_contentLen];
} notification_v1;

#if DEBUG
#define vuiAddress "/vui/socket/vui"
#define playerAddress "/vui/socket/musicPlayer"
#else
#define vuiAddress "/dev/vui"
#define playerAddress "/dev/musicPlayer"
#endif