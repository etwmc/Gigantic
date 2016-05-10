//
//  VIPipe.cpp
//  VoiceUI
//
//  Created by Wai Man Chan on 6/17/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "VIPipe.h"
#import "../ShareConstant.h"

#import <sys/socket.h>
#import <sys/types.h>
#import <sys/un.h>
#import <unistd.h>

#include <strings.h>

char applicationName[16];

int startSocket(const char *address) {
    int _socket;
    _socket = socket(PF_UNIX, SOCK_STREAM, 0);
    struct sockaddr_un addr;   bzero(&addr, sizeof(addr));
    addr.sun_family = PF_UNIX;  addr.sun_len = sizeof(addr);    strcpy(addr.sun_path, address);
    connect(_socket, (const struct sockaddr *)&addr, sizeof(addr));
    return _socket;
}

#define sendPacket(p, socket) write(socket, (const void *)&p, sizeof(p));

void VIpresentNotification(const char *summary, const char *description) {
    int _socket = startSocket(vuiAddress);
    notification_v1 msg;
    if (strlen(summary) > 255 || strlen(description) > 1023) return;
    strcpy(msg.message, summary);
    strcpy(msg.fullContent, description);
    packet p;
    p.flag = 0;
    p.type = packetType_notification;
    p.version = 1;
    strcpy(p.sender, applicationName);
    memcpy(p.content, &msg, sizeof(notification_v1));
    sendPacket(msg, _socket);
    close(_socket);
}

void VIpresentDialog(const char *dialog, bool needFeedback) {
    int _socket = startSocket(vuiAddress);
    packet p;
    p.version = 1;
    p.type = packetType_dialog;
    p.flag = needFeedback;
    strcpy(p.sender, applicationName);
    strcpy(p.content, dialog);
    sendPacket(p, _socket);
    close(_socket);
}

//The playlist should send in JSON packaged array
void VIsetPlaylist(const char *playlistPackage, unsigned int len) {
    int _socket = startSocket(playerAddress);
    write(_socket, playlistPackage, len);
    close(_socket);
}