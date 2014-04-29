//
//  helperFunction.h
//  NLP
//
//  Created by CHAN, Wai Man on 3/12/13.
//  Copyright (c) 2013 CHAN, Wai Man. All rights reserved.
//

#ifndef __NLP__helperFunction__
#define __NLP__helperFunction__

#include "librarySet.h"
#include "Object.h"
#include "Person.h"
#include <iostream>
#include <string>
#include <vector>
#include "NLP.h"

using namespace std;
#warning - Not define
typedef vector<void *> complexRelationship;

string returnCurrentTime ();
string returnCurrentDate ();
string returnCurrentLocation ();
bool matchString(const char *input, const char *targetInput, int targetType, int &output);
inline bool stringEqual(const char *input, const char *target) { return strcmp(input, target) == 0; }
void toLowerString(char *s);
vector<Person *> analyzeRelationship(complexRelationship relationship);
vector<Person *> searchForPeople(const char *name);
Person *getSinglePerson(vector<Person *>people);

typedef enum {
    simplePresent,
    simplePast,
    simpleFuture
} tense;
string buildObjectOwnership(Object *owner, string object);
string buildSentence(string pronoun, string verb, tense verbTense, bool passive, string object);
vector<string>adjectiveConvertion(vector<wordStruct>adjectives);
bool nounHasSuchWordDescribe(vector<string>adjs, string word);
string constructNoun(wordStruct noun);
#endif /* defined(__NLP__helperFunction__) */
