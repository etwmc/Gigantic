//
//  Media.h
//  NLP
//
//  Created by Wai Man Chan on 4/28/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __NLP__Media__
#define __NLP__Media__

#include <stdio.h>
#include <sqlite3.h>

class Media {
    sqlite3 *db;
public:
    Media();
    ~Media();
};

#endif /* defined(__NLP__Media__) */
