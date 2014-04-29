#ifndef __NLP__header__
#define __NLP__header__

#include <string>
#include <vector>
#include <typeinfo>
#include "Object.h"

using namespace std;

typedef void * Location;

typedef enum {
    //Time Related Question Word
    qwtTime,
    qwtDate,
    qwtDuration,
    //Location Related Word
    qwtLocation,
    qwtPerson,
    qwtGeneral
} questionWordType;

typedef enum {
    vtGeneral
} verbType;

typedef enum {
    ntPronoun_I,
    ntPronoun_He,
    ntPronoun_She,
    ntPronoun_They,
    ntPronoun_We,
    ntPronoun_You,
    ntPerson,
    ntTime,
    ntDate,
    ntGeneral
} nounType;

typedef enum {
    atPositive,
    atNetural,
    atNegative
} adjectiveType;


typedef struct wordStruct{
    int type;
    string raw;
    vector <Object *>relatedObjs;
    vector <struct wordStruct>describe;
} wordStruct;

#define YYSTYPE wordStruct
#endif