//
//  helperFunction.h
//  NLP
//
//  Created by CHAN, Wai Man on 3/12/13.
//  Copyright (c) 2013 CHAN, Wai Man. All rights reserved.
//

#ifndef __NLP__helperFunction__
#define __NLP__helperFunction__

#import <iostream>
#import <string>
#import <vector>

using namespace std;

string returnCurrentTime ();
string returnCurrentDate ();
string returnCurrentLocation ();
bool matchString(const char *input, const char *targetInput, int targetType, int &output);
inline bool stringEqual(const char *input, const char *target) { return strcmp(input, target) == 0; }
void toLowerString(char *s);
#endif /* defined(__NLP__helperFunction__) */
