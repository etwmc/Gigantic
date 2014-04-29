//
//  Context.cpp
//  NLP
//
//  Created by Wai Man Chan on 4/28/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#include "Context.h"
#include "Person.h"
#include "Self.h"
#include "VoiceCommander.h"
#include "helperFunction.h"


/*
 * POV: User
 */
class ContextInternal {
    Person *_he, *_she;
    Object *_it;
    vector<Object *>_they;
public:
    Person *he() { return _he; }
    Person *she() { return _she; }
    Object *it() { return _it; }
    Self *i() { return Self::singleton(); }
    VoiceCommander *you() { return VoiceCommander::singleton(); }
    vector<Object *>they() { return _they; }
    vector<Object *>we() {
        vector<Object *>container = _they;
        container.push_back(this->i());
        return container;
    }
    
};

ContextInternal *contextInternal = new ContextInternal;


vector<Object *>Context::query(string word) {
    if (!word.compare("he")||!word.compare("his")||!word.compare("him")) {
        vector<Object *> objs;
        objs.push_back(contextInternal->he());
        return objs;
    }
    if (!word.compare("she")||!word.compare("her")) {
        vector<Object *> objs;
        objs.push_back(contextInternal->she());
        return objs;
    }
    if (!word.compare("it")||!word.compare("its")) {
        vector<Object *> objs;
        objs.push_back(contextInternal->it());
        return objs;
    }
    if (!word.compare("i")||!word.compare("me")||!word.compare("my")) {
        vector<Object *> objs;
        if (inputSide) objs.push_back(contextInternal->i());
        else objs.push_back(contextInternal->you());
        return objs;
    }
    if (!word.compare("you")||!word.compare("your")) {
        vector<Object *> objs;
        if (!inputSide) objs.push_back(contextInternal->i());
        else objs.push_back(contextInternal->you());
        return objs;
    }
    if (!word.compare("they")||!word.compare("them")||!word.compare("their")) {
        return contextInternal->they();
    }
    if (!word.compare("we")||!word.compare("our")||!word.compare("us")) {
        return contextInternal->we();
    }
    vector<Object *>v;
    return v;
}