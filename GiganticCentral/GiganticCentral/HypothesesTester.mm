//
//  HypothesesTester.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 10/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "HypothesesTester.h"
#import "QueryContext.h"
extern "C" {
#import "GCGEConnection.h"
#import "../../VoiceUI/VIKit/VIKit.h"
}
#import <iostream>
#import "GCQuery.h"

#import "GCTextParser.h"

//Hypotheses hypotheseFromWords(vector<phase *> phases) {
//    Hypotheses h;
//    for (auto it = phases.begin(); it != phases.end(); it++) {
//        h += (*it).phase + " ";
//    }
//    return h;
//

#define printGEResult 0

HypothesesTester::HypothesesTester() {
    
}

int HypothesesTester::setupSocket() {
    int soc = socket(PF_UNIX, SOCK_STREAM, 0);
    sockaddr_un un; bzero(&un, sizeof(un));
    un.sun_family = PF_UNIX; un.sun_len = sizeof(un); strcpy(un.sun_path, "/vui/socket/GE");
    connect(soc, (const struct sockaddr *)&un, un.sun_len);
    return soc;
}

void HypothesesTester::newTestSection() { transcationID++; }

bool HypothesesTester::testHypotheses(Hypotheses s) {
    
    @autoreleasepool {
        
        //Context
        QueryContext *context = [QueryContext sharedQuery];
        //Launch Grammar Engine
        s+='\n';
        int _socket = setupGrammarConnection();
        write(_socket, s.c_str(), s.length());
        char buffer[2048];
        while (true) {
            bzero(buffer, 2048);
            ssize_t size = read(_socket, buffer, 2048);
#if printGEResult
            cout << buffer << endl;
#endif
            if (size == 0 || strncmp(buffer, "Fail", 4) == 0) { close(_socket); return false; }
            else if (strncmp(buffer, "Test", 4) == 0) {
                NSString *trace = [NSString stringWithUTF8String:&buffer[4]];
                BOOL testResult = [[QueryContext sharedQuery] objectCanBeTrace:trace];
                write(_socket, &testResult, sizeof(testResult));
            } else {
                @try {
                    Query *q = [Query createQueryFromMessage:s.c_str() withGrammarBuffer:buffer];
                    [context startQuery:q withPartition:0];
                    if (q.solution.resultDialog) VIpresentDialog(q.solution.resultDialog.UTF8String, NO);
                    
                    
                    //if (q.solution.resultObjs.count == 0)
                    //    [NSException raise:@"No result come back" format:@"There is no response come from execute the query %s", s.c_str()];
                    //if (q.type == messagePurpose_question && q.returnTypes == nil && [q.solution.resultObjs[0] class] == [GCPerson class])
                    //    [NSException raise:@"What + Person query" format:@"Usually no one ask 'what' to a human"];
                    NSLog(@"%s", s.c_str());
//                    for (GCObject *obj in q.solution.resultObjs) {
//                        NSString *result = obj.description;
//                        VIpresentDialog(result.UTF8String, NO);
//                        if (obj.outputFormat)
//                            NSLog(obj.outputFormat, obj);
//                        else NSLog(@"%@", obj);
//                    }
                    NSLog(@"%@", q.solution.resultDialog);
                    
                    
                    if (q.solution.resultObjs.count) {
                        [context preserveQueryResult:q];
                        
                        return true;
                    }
                }
                @catch (NSException *exception) {
#if printGEResult
                    NSLog(@"%@", exception);
#endif
                    close(_socket);
                    
                    return false;
                }
                @finally {
                    
                    close(_socket);
                    
                    return true;
                }
                
                break;
            }
        }
        
    }
    
}
