//
//  Grammar.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 6/21/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <string>
#import <vector>
#import "helperFunction.h"
#import "GCObjectConstant.h"

#import "../GiganticCentral/GCQueryConstant.h"

using namespace std;

#define socket_address "/tmp/ge"

typedef enum {
    wordsCompoundType_owner = 0,
    wordsCompoundType_descibe,
    wordsCompoundType_child,
    wordsCompoundType_logic,
    wordsCompoundType_noneCompound = 255
} wordsCompoundType;

typedef queryType messagePurpose;

class phase {
    long sourceID;
    phaseType type;
    bool compound;
    wordsCompoundType _compoundType = wordsCompoundType_noneCompound;
protected:
    /*
     * When Source ID = -1, the phase is a composition of multiple word
     */
    phase() {}
    phase(long _sourceID, phaseType _type) { sourceID = _sourceID; type = _type; };
public:
    vector<phase *>modifier;
    vector<phase *>subPhases;
    phase(long _sourceID, phaseType _type, int numberOfElement, ...) {
        sourceID = _sourceID;
        type = _type;
        va_list vl;
        va_start(vl, numberOfElement);
        for (int i = 0; i < numberOfElement; i++) {
            phase *p = va_arg(vl, phase*);
            subPhases.push_back(p);
        }
        va_end(vl);
    }
    phaseType phaseType() { return type; }
    long phaseSourceID() { return sourceID; }
    virtual bool isCompound() { return compound; }
    virtual wordsCompoundType compoundType() { return _compoundType; }
    virtual bool isLeaf() { return subPhases.size() == 0; };
    virtual string wordContent();
    vector<phase *>child() { return subPhases; }
    ~phase() {
        for (auto it = subPhases.begin(); it != subPhases.end(); it++) {
            delete *it;
        }
    }
    friend phase *wordCombination(phase *link, phase *newNode, ::phaseType type, bool andGate, bool hierarchy);
    friend int yyparse(void *scanner);
    friend string description(phase *word);
};

class word: public phase {
    long identity;
    string content;
public:
    //This class is for ONE SINGLE word, so it must not be compound
    virtual bool isCompound() { return false; }
    virtual bool isLeaf() { return true; }
    word(long _sourceID, ::phaseType _type, short _identity): phase(_sourceID, _type) {
        identity = _identity; char _content[20];
        snprintf(_content, 20, "%ld, %d, %ld", phaseSourceID(), phaseType(), wordIdentity());
        string __content(_content);
        content = __content;
    }
    word(long _sourceID, ::phaseType _type, const char * _content): phase(_sourceID, _type) {
        char *buffer = new char[1024];
        strcpy(buffer, _content);
        toLowerString(buffer);
        content = string(buffer); identity = -1;
    }
    long wordIdentity() { return identity; }
    virtual string wordContent() { return content; }
};

class message: public phase {
    messagePurpose purpose;
public:
    messagePurpose messagePurpose() { return purpose; }
    void setMessagePurpose(::messagePurpose pur) { purpose = pur; }
    message(::messagePurpose _purpose, int element, ...);
    ~message();
};
void printMessageStructure(message *message);

#define YYSTYPE phase*

phase *wordCombination(phase *link, phase *newNode, phaseType type, bool andGate, bool hierarchy);

void output(const char *buffer);
void invaildBuffer();
void pushResult();
void outputWithFormat(const char *format, ...);

void printStatement(phase *obj1, phase *obj2, phase *relation);
void printCommand(phase *action, phase *target);
void printQuestionStructure(phase *questionPhase, phase *verb, phase *target);
void printBooleanQuestion(phase *subject, phase *comparator);
void printExclamation(word *word);

bool testNounCombinatioin();

extern int yyparse (void *YYPARSE_PARAM);