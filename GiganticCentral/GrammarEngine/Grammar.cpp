//
//  Grammar.c
//  GiganticCentral
//
//  Created by Wai Man Chan on 6/23/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <stdio.h>
#import "Grammar.h"
#import <unistd.h>
#import <stdarg.h>

//#if DEBUG
#import <assert.h>
//#endif

string objectDescription(phase *noun);
string adjectiveDescription(phase *adj);
string verbDescription(phase *verb);
string description(phase *word);

extern int grammarSocket;

/*
 * Object Implmentation
 */
string phase::wordContent() {
    string result;
    const char *separator;
    if (this->compound) separator = "&";
    else separator = "|";
    for (auto it = this->subPhases.begin(); it != this->subPhases.end(); it++) {
        if (result != "") result += separator;
        result += ((phase *)(*it))->wordContent();
    }
    return result;
}
message::message(::messagePurpose _purpose, int element, ...) {
    purpose = _purpose;
    va_list vl;
    va_start(vl, element);
    for (int i = 0; i < element; i++) {
        phase *_p = va_arg(vl, phase*);
        subPhases.push_back(_p);
    }
}
message::~message() {
    for (auto it = subPhases.begin(); it != subPhases.end(); it++) {
        delete (*it);
    }
}

/*
 * Handle For Words
 */
phase *wordCombination(phase *link, phase *newNode, phaseType type, bool andGate, bool hierarchy) {
    if (hierarchy||link->isLeaf()) {
        phase *result = new phase(-1, type, 2, link, newNode);
        result->compound = andGate;
        return result;
    } else {
        link->subPhases.push_back(newNode);
        link->compound = andGate;
        return link;
    }
}

/*
 * Output functions
 */

char giantBuffer[4096];
unsigned int bufferLen = 0;
bool voidBuffer = false;

void output(const char *buffer) {
    strcpy(&giantBuffer[bufferLen], buffer);
    bufferLen += strlen(buffer);
    giantBuffer[bufferLen] = '\n';
    bufferLen++;
}

void invaildBuffer() {
    voidBuffer = true;
}

void pushResult() {
    if (voidBuffer)
        write(grammarSocket, "Fail\n", 6);
    else
        write(grammarSocket, giantBuffer, bufferLen);
    //Cleanup
    bzero(giantBuffer, 4096);
    bufferLen = 0;
    voidBuffer = false;
}

#define outputWithFormatBufferSize 256
void outputWithFormat(const char *format, ...) {
    va_list vi;
    va_start(vi, format);
    
    char buffer[outputWithFormatBufferSize];   buffer[outputWithFormatBufferSize-1] = 0;
    vsnprintf(buffer, outputWithFormatBufferSize, format, vi);
    output(buffer);
    
    va_end(vi);
}

/*
 * Handle Input->Format Message->Output
 */
void printMessageStructure(message *message) {
    //Output Message Type
    char buffer[32];    buffer[0] = 0;
#if DEBUG
    switch (message->messagePurpose()) {
        case messagePurpose_command:
            strcpy(buffer, "Type: Command");
            break;
        case messagePurpose_exclamation:
            strcpy(buffer, "Type: Exclamation");
            break;
        case messagePurpose_question:
            strcpy(buffer, "Type: Question");
            break;
        case messagePurpose_statement:
            strcpy(buffer, "Type: Statement");
            break;
        case messagePurpose_condition:
            strcpy(buffer, "Type: Condition");
            break;
    }
#else
    snprintf(buffer, 32, "Type: %d", message->messagePurpose());
#endif
    output(buffer);
    switch (message->messagePurpose()) {
        case messagePurpose_command:
            printCommand(message->subPhases[0], message->subPhases[1]);
            break;
        case messagePurpose_exclamation:
            printExclamation((word *)message->subPhases[0]);
            break;
        case messagePurpose_question:
            if (message->subPhases[0]->isCompound()||message->subPhases[0]->wordContent().length())
                printQuestionStructure(message->subPhases[0], message->subPhases[1], message->subPhases[2]);
            else printBooleanQuestion(message->subPhases[2], message->subPhases[1]);
            break;
        case messagePurpose_statement:
        case messagePurpose_condition:
            printStatement(message->subPhases[0], message->subPhases[2], message->subPhases[1]);
            break;
    }
}
//Command
void printCommandAction(phase *action) {
    string verbStr = verbDescription(action);
    outputWithFormat("Action: %s", verbStr.c_str());
}
void printCommandTarget(phase *target) {
    string targetStr = objectDescription(target);
    outputWithFormat("Target: %s", targetStr.c_str());
}
void printCommand(phase *action, phase *target) {
    printCommandAction(action);
    printCommandTarget(target);
}
//Statement
void printStatement(phase *obj1, phase *obj2, phase *relation) {
    string obj1String = objectDescription(obj1);
    string obj2String = objectDescription(obj2);
    string relationString = verbDescription(relation);
    outputWithFormat("Source: %s", obj1String.c_str());
    outputWithFormat("Target: %s", obj2String.c_str());
    outputWithFormat("Action: %s", relationString.c_str());
}
//Question
void printQuestionWordType(word *_word) {
    char pattern[] = "Question Type: %s";
    string wc = _word->wordContent();
    if (wc == "what")         outputWithFormat(pattern, "generic");
    else if (wc == "who")     outputWithFormat(pattern, "person");
    else if (wc == "where")   outputWithFormat(pattern, "location");
    else if (wc == "whose")   outputWithFormat(pattern, "ownership");
    else if (wc == "when")    outputWithFormat(pattern, "time");
    else if (wc == "which")   outputWithFormat(pattern, "reduce");
    else if (wc == "how")     outputWithFormat(pattern, "method");
    else if (wc == "how many")outputWithFormat(pattern, "number");
    else if (wc == "how much")outputWithFormat(pattern, "number");
    else /*if (wc == "do")*/      outputWithFormat(pattern, "boolean");
}
void printQuestionStructure(phase *questionPhase, phase *verb, phase *target) {
    string targetDescription = description(target);
    if (questionPhase->isLeaf()) {
        word *_word = dynamic_cast<word *>(questionPhase);
        if (_word != nullptr) {
            printQuestionWordType(_word);
        }
        description(verb);
        outputWithFormat("Target: %s", targetDescription.c_str());
    } else {
        if (questionPhase->child().size() == 2) {
            //Return Pattern
            char pattern[] = "Question Type: %s";
            word *_questionWord = dynamic_cast<word *>(questionPhase->child().front());
            
            phase *_constraint = dynamic_cast<phase *>(questionPhase->child().back());
            string description = objectDescription(_constraint);
            bool printTarget = true;
            
            //Solve the two phase type of question phase
            //Current implment: What ____, How _____, which one
            if (_questionWord != nullptr && _constraint != nullptr) {
                if (_questionWord->wordContent() == "what" && _constraint->phaseType() == phaseType_noun) {
                    outputWithFormat(pattern, description.c_str());
                    if (printTarget) outputWithFormat("Target: %s->%s", targetDescription.c_str(), description.c_str());
                } else if (_questionWord->wordContent() == "how" && _constraint->phaseType() == phaseType_adjective) {
                    outputWithFormat(pattern, "degree");
                    outputWithFormat("Degree Of: %s", description.c_str());
                    outputWithFormat("Target: %s", targetDescription.c_str());
                } else if (_questionWord->wordContent() == "which" &&
                           _constraint->phaseType() == phaseType_pronoun) {
                    word *_word = dynamic_cast<word *>(_constraint);
                    assert(_word->wordContent() == "one");
                    outputWithFormat(pattern, "MC21");//Question Pattern: MC to 1, which return 1 answer or return reason of multiple solution
                    description = "";
                    outputWithFormat("Target: MC");
                    if (printTarget) outputWithFormat("Target: %s->%s", targetDescription.c_str(), description.c_str());
                }
            }
        }
    }
    
}
void printBooleanQuestion(phase *subject, phase *comparator) {
    output("Question Type: Boolean");
    string targetDescription = objectDescription(subject);
    outputWithFormat("Target: %s", targetDescription.c_str());
    if (comparator->phaseType() == phaseType_verb) {
        string constraintTarget = description(comparator);
        outputWithFormat("Action: %s", constraintTarget.c_str());
    } else {
        string constraintTarget = description(comparator);
        outputWithFormat("Comparsion: %s", constraintTarget.c_str());
    }
}
//Exclamation
/*
 * stringIsEqualToEleArray
 * Return the indexo of the array
 */

inline int stringIsEqualToEleArray(string input, string strings[], size_t numberOfString) {
    for (int i = 0; i < numberOfString; i++) {
        if (input == strings[i]) return i;
    }
    return -1;
}
void printExclamation(word *word) {
    string wc = word->wordContent();
    switch (word->phaseType()) {
        case phaseType_exclamation_gratitude: {
            output("Method: Gratitude");
        }
            break;
        case phaseType_exclamation_greet: {
            output("Method: Greet");
            string greetings[] = {"hi", "hello", "hey"};
            switch (stringIsEqualToEleArray(wc, greetings, 3)) {
                case -1:
                    string timeConstraint = string(word->wordContent(), 5, string::npos);
                    string possibleTime[] = {"morning", "afternoon", "evening"};
                    int i = stringIsEqualToEleArray(timeConstraint, possibleTime, 3);
                    outputWithFormat("Target: it->0, 1, 0\nComparsion: 124, 3, %d", i);
                    break;
            }
        }
            break;
        case phaseType_exclamation_parting: {
            output("Method: Part");
            string gn [] = {"good night", "good bye"};
            if (stringIsEqualToEleArray(wc, gn, 1) == 0) {
                output("Comparsion: it->time=night");
            }
        }
            break;
        default:
            assert(false);  //Should never happen
            break;
    }
}

/*
 * This function is for describing object (and subject) in a (almost) proper format (there will be a "->" at the beginning of every output, which in the output of root will be remove by the wrapper function
 * It's _ prefix indicate it's for internal usage only
 * For any root node, it should return the value of the node
 * For node containing 2 children, it should done a recursive event on each child, and output a <relation> b, where a and b are the output of the children.
 * For compound logic node with more than one nodes, we output a <& or |> b
 * Other case should be consider as an error, which should trigger assert event
 */
string _objectDescription(phase *noun) {
    string result = "->";
    assert(noun); //Hang at null input
    
    if (noun->isLeaf()) { //Root node
        word *_word = dynamic_cast<word *>(noun);
        assert(_word);//Hang for leaf node that's not a word object
        result += _word->wordContent();
    } else {
        assert(noun->child().size() != 1); //If it's a compound node, it should have two or more child
        assert(noun->compoundType() != wordsCompoundType_noneCompound); //A compound phase should have a compound type
        if (noun->compoundType() == wordsCompoundType_logic) {
            char relationSymbol = noun->isCompound()?'&':'|';
            for (auto it = noun->child().begin(); it != noun->child().end(); it++) {
                result += (objectDescription(*it)+relationSymbol);
            }
            result = string(result, 0, result.length()-1);
        } else {
            //Two nodes case
            string a = objectDescription(noun->child().front());
            string b = objectDescription(noun->child().back());
            switch (noun->compoundType()) {
                case wordsCompoundType_child:
                    result += (a+"->"+b);
                    break;
                case wordsCompoundType_owner:
                    result += (a+"->"+b);
                    break;
                case wordsCompoundType_descibe:
                    result += (b+"|"+a);
                    break;
                default:
                    assert(false);//This should not appear
                    break;
        }
        }
    }
    return result;
//    Archive: 8 July 2014
//    if (noun->phaseType() != phaseType_noun) result = "";
//    if (noun == NULL) result = "";
//    else if (noun->isLeaf()) { result = noun->wordContent(); }
//    else {
//        const char *sepator;
//        auto childs = noun->child();
//        bool moreThanOneObj = false;
//        for (auto it = childs.begin(); it != childs.end(); it++) {
//            phase *p = *it;
//            if (p->phaseType() == phaseType_pronoun) {
//                result += p->wordContent()+".";
//                break;
//            }
//        }
//        if (noun->isCompound()) sepator = "&";
//        else sepator = "|";
//        vector<phase *>adjective;
//        for (auto it = childs.begin(); it != childs.end(); it++) {
//            phase *p = *it;
//            switch (p->phaseType()) {
//                case phaseType_adjective:
//                    adjective.push_back(p);
//                    break;
//                case phaseType_person:
//                case phaseType_location:
//                case phaseType_noun:
//                    if (moreThanOneObj) {
//                        result += sepator;
//                    }
//                    result += (objectDescription(p));
//                    break;
//                default:
//                    //It does not suppose to happen, every object "object" includes only noun, and adjective
//                    assert(true);
//                    break;
//            }
//        }
//        if (adjective.size()) {
//            result += "(";
//            for (auto it = adjective.begin(); it != adjective.end(); it++) {
//                result += (*it)->wordContent();
//            }
//            result += ")";
//        }
//    }
//    return result;
}

string objectDescription(phase *noun) {
    string temp = _objectDescription(noun);
    return string(temp, 2, string::npos);
}

string adjectiveDescription(phase *adj) {
    return adj->wordContent();
}

string verbDescription(phase *verb) {
    string content = verb->wordContent();
    if (verb->modifier.size()) {
        for (auto it = verb->modifier.begin(); it != verb->modifier.end(); it++) {
            content += "/";
            //Print preposition
            content += (*it)->subPhases[0]->wordContent();
            content += "_";
            //Print the trace noun
            content += description((*it)->subPhases[1]);
        }
    }
    return content;
}

string description(phase *word) {
    switch (word->type) {
        case phaseType_noun:
        case phaseType_instance:
        case phaseType_pronoun:
        case phaseType_modifier_objectRelation:
            return objectDescription(word);
            break;
        case phaseType_adjective:
            return adjectiveDescription(word);
        case phaseType_verb:
            return verbDescription(word);
        default:
            return "";
            break;
    }
}

bool testNounCombinatioin() {
    return false;
}