//
//  Info.h
//  NLP
//
//  Created by Wai Man Chan on 4/28/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __NLP__Info__
#define __NLP__Info__

#include "librarySet.h"

class Info {
    string readableSourceName;
public:
    virtual string introduction();
    virtual string detail();
    
};

#endif /* defined(__NLP__Info__) */
