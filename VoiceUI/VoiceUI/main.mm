//
//  main.cpp
//  VoiceUI
//
//  Created by Wai Man Chan on 6/17/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <fstream>
#import <dispatch/dispatch.h>

#import <sys/socket.h>
#import <sys/types.h>
#import <sys/un.h>
#import <netinet/in.h>

#import <vector>
#import <map>
#import <list>

#import "../ShareConstant.h"

extern "C" {
#import "VUI_SpeechSynthesizer.h"
}

#import <iostream>

#ifdef __APPLE__
#import <Foundation/Foundation.h>
#endif

dispatch_queue_t queue = dispatch_queue_create("Voice UI Server", DISPATCH_QUEUE_CONCURRENT);;
dispatch_semaphore_t msgStackSem = dispatch_semaphore_create(1);
dispatch_semaphore_t msgSem = dispatch_semaphore_create(0);

//List of dialog, FIFO
std::list<packet *>dialogs;

//Map of FIFO list, each list contain all the notification from the same sender
std::map<const int, std::list<packet*>>msgStack;
std::vector<char*>priorityList;

#define PriorityListAddr "/vui/config/vui/priority"

void readInPriority() {
    
    std::fstream file(PriorityListAddr, std::fstream::in);
    while (!file.eof()) {
        char *buffer = new char[24];
        file.getline(buffer, 24);
        if (strlen(buffer)) priorityList.push_back(buffer);
    }
    file.close();
}

int searchPriority(char *id) {
    int i = 0;
    bool found = false;
    for (auto it = priorityList.begin(); it != priorityList.end() && !found; it++, i++) {
        if (strcmp(id, *it) == 0) found = true;
    }
    return i;
}

int configSocket(const char *address) {
    int _socket;
#if DEBUG
//    _socket = socket(PF_INET, SOCK_STREAM, 0);
//    sockaddr_in addr;   bzero(&addr, sizeof(addr));
//    addr.sin_addr.s_addr = htonl(INADDR_ANY);   addr.sin_family = AF_INET;  addr.sin_len = sizeof(addr);    addr.sin_port = htons(54322);
//    int err;
//    {
//        int trueBool = true;
//        err = setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, &trueBool, sizeof(trueBool));
//    }
//    do {
//        err = bind(_socket, (const sockaddr *)&addr, sizeof(addr));
//    } while (err);
//    listen(_socket, 10);
//#else
    _socket = socket(PF_UNIX, SOCK_STREAM, 0);
    sockaddr_un addr;   bzero(&addr, sizeof(addr));
    std::cout << address << std::endl;
    addr.sun_family = PF_UNIX;  addr.sun_len = sizeof(addr);    strcpy(addr.sun_path, address);
    unlink(address);
    int err;
    do {
        err = bind(_socket, (const sockaddr *)&addr, sizeof(addr));
    } while (err);
    listen(_socket, 10);
#endif
    return _socket;
}

packet *fetchFirstMessage() {
    packet *m;
    if (dialogs.size() > 0) {
        m = dialogs.front();
        dialogs.pop_front();
        return m;
    }
    
    for (auto it = msgStack.begin(); it != msgStack.end(); it++) {
        if ((*it).second.size() > 0) {
            m = (*it).second.front();
            (*it).second.pop_front();
            break;
        }
    }
    return m;
}

packet *lastMessage = NULL;
time_t lastMessageOutputTime;

void outputMessage() {
    char buffer[1024];
    //Output loop
    while (true) {
        dispatch_semaphore_wait(msgSem, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(msgStackSem, DISPATCH_TIME_FOREVER);
        
        /*
         * Output to console on testing/debug
         * Output to eSpeak on release
         */
        packet *msg = fetchFirstMessage();
        bzero(buffer, 1024);
        
        switch (msg->type) {
            case packetType_notification:
                strncpy(buffer, msg->content, 1024);
                break;
            
            case packetType_dialog:
                strncpy(buffer, msg->content, 1024);
                break;
                
            default:
                break;
        }
        

        playMessage(buffer);
        waitTillMessagePlayThr();
        if (lastMessage) delete lastMessage;
        lastMessage = msg;
        lastMessageOutputTime = time(NULL);
        
        sleep(3);
        
        dispatch_semaphore_signal(msgStackSem);
    }
}

void readNotification(int senderPriority, packet notificationPacket) {
    packet *buffer = new packet;
    memcpy(buffer, &notificationPacket, sizeof(packet));
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(msgStackSem, DISPATCH_TIME_FOREVER);
        msgStack[senderPriority].push_back(buffer);
        dispatch_semaphore_signal(msgStackSem);
        dispatch_semaphore_signal(msgSem);
    });
}

void readDialog(packet dialog) {
    packet *buffer = new packet;
    memcpy(buffer, &dialog, sizeof(packet));
    
    dispatch_semaphore_wait(msgStackSem, DISPATCH_TIME_FOREVER);
    
    dialogs.push_back(buffer);
    
    dispatch_semaphore_signal(msgStackSem);
    dispatch_semaphore_signal(msgSem);
}

void readPacket(int child) {
    dispatch_async(queue, ^{
        int priority = -1;
        packet buffer;
        while (true) {
            bzero(&buffer, sizeof(buffer));
            int len = (int)read(child, &buffer, sizeof(buffer));
            if (len <= 0) break; /* Disconnected */
            if (len > 0) {
                //Check sender priority, one time only
                if (priority == -1) priority = searchPriority(buffer.sender);
                
                //Packet type switch
                switch (buffer.type) {
                    case packetType_notification:
                        readNotification(priority, buffer);
                        break;
                    case packetType_dialog:
                        readDialog(buffer);
                        break;
                    default:
                        perror("Don't know message type solution");
                        break;
                }
                
            }
        }
        close(child);
    });
}

void musicPlayer() {
    dispatch_async(queue, ^{
        int _socket = configSocket(playerAddress);
        dispatch_async(queue, ^{
            while (true) {
                int child = accept(_socket, NULL, NULL);
                char *buffer = new char[8192];
                int len = read(child, buffer, 8192);
                if (len > 0) {
                    buffer[len] = 0;
                    playMusic(buffer);
                    delete [] buffer;
                    close(child);
                }
            }
        });
    });
}

int main(int argc, const char * argv[]) {
    //Init
    initSynthesizer();
    int _socket = configSocket(vuiAddress);
    readInPriority();
    
    //Setup music player
    musicPlayer();
    
    //Communication events
    dispatch_async(queue, ^{
        while (true) {
            int child = accept(_socket, NULL, NULL);
            readPacket(child);
        }
    });
    
    dispatch_async(queue, ^{
        outputMessage();
    });
    
#ifdef __APPLE__
    [[NSRunLoop mainRunLoop] run];
#endif
    
    return 0;
}
