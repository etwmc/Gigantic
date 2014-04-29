//
//  Media.cpp
//  NLP
//
//  Created by Wai Man Chan on 4/28/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#include "Media.h"
#include <iostream>
using namespace std;

#define MediaDBAddr "/tmp/media.db"

Media::Media() {
    int err = sqlite3_open(MediaDBAddr, &db);
    if (err) {
        cerr << "Can't open media database: " << sqlite3_errmsg(db) << endl;
    }
}

Media::~Media() {
    sqlite3_close(db);
}