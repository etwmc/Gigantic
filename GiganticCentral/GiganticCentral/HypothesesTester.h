//
//  HypothesesTester.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 10/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <sys/socket.h>
#import <sys/types.h>
#import <sys/un.h>
#import <string>

using namespace std;

typedef string Hypotheses;



class HypothesesTester {
    int setupSocket();
    int transcationID;
public:
    HypothesesTester();
    void newTestSection();
    bool testHypotheses(Hypotheses h);
};