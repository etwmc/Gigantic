//
//  Object.h
//  NLP
//
//  Created by CHAN, Wai Man on 3/12/13.
//  Copyright (c) 2013 CHAN, Wai Man. All rights reserved.
//

#ifndef __NLP__Object__
#define __NLP__Object__

#include <iostream>
#include <fstream>
#include <vector>
#include "librarySet.h"
#include <sqlite3.h>

using namespace std;

#ifndef DISPATCH_QUEUE_CONCURRENT
#define DISPATCH_QUEUE_CONCURRENT 0
#endif

class ObjDB;
class Object {
public:
    virtual string name() const { return ""; }
    virtual string pronoun() const { return "it"; }
    virtual string possessiveDeterminer() const { return "its"; }
    virtual string query(string syntax, vector<string>describes = vector<string>()) {
#warning - Unimplemented method
        return "";
    }
    
    virtual void setValueForKey(string key, void *value) {}
};
ObjDB operator << (ObjDB &db, Object &obj);

class ObjDB {
protected:
    sqlite3 *db;
    dispatch_queue_t dbQueue;
public:
    ObjDB(string address);
    virtual void initDB() { return; }
    virtual void wrapEverything() { return; }
    ~ObjDB();
};

#endif /* defined(__NLP__Object__) */
