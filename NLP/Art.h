//
//  Art.h
//  Gigantic
//
//  Created by CHAN, Wai Man on 29/4/14.
//
//

#ifndef __Gigantic__Art__
#define __Gigantic__Art__

#include <string>
using namespace std;

#include "Object.h"

class Art : Object {
    string creator;
public:
    virtual string query(string syntax);
};

#endif /* defined(__Gigantic__Art__) */
