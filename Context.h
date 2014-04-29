//
//  Context.h
//  NLP
//
//  Created by Wai Man Chan on 4/28/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __NLP__Context__
#define __NLP__Context__

#include "Object.h"
#include <vector>
using namespace std;

class Context {
    bool inputSide;
public:
    Context(bool input) {
        inputSide = input;
    }
    static Context *shareContext_InputSide() {
        static Context *context = nullptr;
        if (context == nullptr) context = new Context(true);
        return context;
    }
    static Context *shareContext_OutputSide() {
        static Context *context = nullptr;
        if (context == nullptr) context = new Context(false);
        return context;
    }
    vector<Object *>query(string word);
};

#endif /* defined(__NLP__Context__) */
