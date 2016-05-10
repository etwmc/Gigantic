//
//  GCGEConnection.c
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#include "GCGEConnection.h"
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/un.h>
#import <Foundation/Foundation.h>

extern char programAddr[1024];

int setupGrammarConnection() {
    int _socket;
#if DEBUG
    struct sockaddr_in addr;   bzero(&addr, sizeof(addr));
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);  addr.sin_family = PF_INET;  addr.sin_len = sizeof(addr);    addr.sin_port = htons(54321);
#define ProtocolType PF_INET
#else
    sockaddr_un addr;
    addr.sun_family = PF_UNIX; addr.sun_len = sizeof(addr); strcpy(addr.sun_path, "/vui/socket/GE");
    unlink("/vui/socket/GE");
#define ProtocolType PF_UNIX
#endif
    _socket = socket(ProtocolType, SOCK_STREAM, 0);
    int err = connect(_socket, (const struct sockaddr *)&addr, (socklen_t)sizeof(addr));
    if (err) {
        NSString *geAddr = [NSString stringWithUTF8String:programAddr];
        geAddr = [geAddr stringByDeletingLastPathComponent];
        geAddr = [geAddr stringByAppendingPathComponent:@"GrammarEngine"];
        NSTask *geTask = [NSTask launchedTaskWithLaunchPath:geAddr arguments:@[]];
        sleep(2);
        connect(_socket, (const struct sockaddr *)&addr, (socklen_t)sizeof(addr));
    }
    return _socket;
}