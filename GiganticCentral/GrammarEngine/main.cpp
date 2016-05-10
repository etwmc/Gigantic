//
//  main.cpp
//  GrammarEngine
//
//  Created by Wai Man Chan on 6/24/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <iostream>
#import "Grammar.h"
#import <sys/socket.h>
#import <sys/types.h>
#import <unistd.h>
#import <sstream>
#import "Grammar.yy.h"

#if DEBUG
#import <netinet/in.h>
#else
#import <sys/un.h>
#endif

#import <dispatch/dispatch.h>

#define sizeOfInput 1024

int _socket;    //sockaddr_un addr;
int grammarSocket;

extern int yydebug;

void setup() {
#if DEBUG
    sockaddr_in addr;   bzero(&addr, sizeof(addr));
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);  addr.sin_family = PF_INET;  addr.sin_len = sizeof(addr);    addr.sin_port = htons(54321);
#define ProtocolType PF_INET
#else
    sockaddr_un addr;
    addr.sun_family = PF_UNIX; addr.sun_len = sizeof(addr); strcpy(addr.sun_path, "/vui/socket/GE");
    unlink("/vui/socket/GE");
#define ProtocolType PF_UNIX
#endif
    _socket = socket(ProtocolType, SOCK_STREAM, 0);
#if DEBUG
    {
        int trueBool = true;
        setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, &trueBool, sizeof(trueBool));
    }
#endif
    bind(_socket, (const struct sockaddr *)&addr, (socklen_t)sizeof(addr));
    listen(_socket, 1000);
}

dispatch_queue_t queue = dispatch_queue_create("Child Monitor", DISPATCH_QUEUE_CONCURRENT);
dispatch_semaphore_t sem = dispatch_semaphore_create(1);
int counter = 0;

int main(int argc, const char * argv[]) {
    // insert code here...
    yydebug = 1;
    
    setup();
    bool mainThread = true;
    while (mainThread) {
        grammarSocket = accept(_socket, NULL, NULL);
        if (grammarSocket > 0) {
            dispatch_async(queue, ^{
                char *buffer = new char[sizeOfInput];   bzero(buffer, sizeOfInput);
                size_t s = read(grammarSocket, buffer, sizeOfInput);
                if (s&&s==strlen(buffer)) {
                    yyscan_t scanner;
                    yylex_init(&scanner);
                    YY_BUFFER_STATE state = yy_scan_string(buffer, scanner);
                    yy_switch_to_buffer(state, scanner);
                    yyparse(scanner);
                    yy_delete_buffer(state, scanner);
                    yylex_destroy(scanner);
#if DEBUG
                    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                    counter++;
                    dispatch_semaphore_signal(sem);
#endif
                }
//#if DEBUG
                else {
                    cout << "Inconsistent" << " " << counter << endl;
                    cout << buffer << endl;
                    cout << "s = " << s << endl;
                    cout << endl;
                }
//#endif
                delete [] buffer;
                close(grammarSocket);
                cout << counter << endl;
                cout << endl;
            });
        }
        
    }
    return 0;
}
