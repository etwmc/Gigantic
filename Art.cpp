//
//  Art.cpp
//  Gigantic
//
//  Created by CHAN, Wai Man on 29/4/14.
//
//

#include "Art.h"

string Art::query(string syntax) {
    string upperAnswer = Object::query(syntax);
    if (upperAnswer.length()) return upperAnswer;
    else {
        
    }
    return NULL;
}