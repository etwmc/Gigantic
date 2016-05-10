//
//  helperFunction.cpp
//  NLP
//
//  Created by CHAN, Wai Man on 3/12/13.
//  Copyright (c) 2013 CHAN, Wai Man. All rights reserved.
//

#import "helperFunction.h"

string returnCurrentTime () {
    time_t rawTime = time(NULL);
    struct tm *timeInfo = localtime(&rawTime);
    
    char answer[50];
    sprintf(answer, "This is %.2d:%.2d",
           timeInfo->tm_hour,
           timeInfo->tm_min);
    return string(answer);
}

string returnCurrentDate () {
    time_t rawTime = time(NULL);
    struct tm *timeInfo = localtime(&rawTime);
    
    static const char wday_name[7][10] = {
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    };
    static const char mon_name[][4] = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    };
    //static char result[26];
    
    char answer[50];
    sprintf(answer, "This is %s %.3s %d %d.",
           wday_name[timeInfo->tm_wday],
           mon_name[timeInfo->tm_mon],
           timeInfo->tm_mday,
           1900 + timeInfo->tm_year);
    return string(answer);
}

string returnCurrentLocation () {
    char answer[128];
    sprintf(answer, "Unknown");
    return string(answer);
}

void toLowerString(char *s) {
    for (int i = 0; i < strlen(s); i++) {
        s[i] = tolower(s[i]);
    }
}

//Person *getSinglePerson(vector<Person *>people) {
//    switch (people.size()) {
//        case 0:
//            return NULL;
//        case 1:
//            return people[1];
//        default: {
//	    int i = 1;
//            for (vector<Person *>::iterator it = people.begin(); it != people.end(); i++, it++) {
//                cout << i << ". " << *it << endl;
//            }
//            int selection;
//            do {
//                cin >> selection;
//            } while (selection <= 0 || selection > people.size());
//            return people[(selection-1)];
//	}
//            break;
//    }
//}
//
///*
// * Parameter: 
// * verb = go/see/watch/...
// * verbTense = tense of the verb
// * passive = whether the verb need to prefix a "be"
// * postfixS = whether a s is need, only true for he/she/it as pronoun
// * am = whether the pronoun is I
// */
//#warning - Future development: should replace theh postfixS and am to a pronouon system
//string verbTransform(string verb, tense verbTense, bool passive, bool postfixS, bool am) {
//    if (verb.compare("be")==0) {
//        switch (verbTense) {
//            case simplePresent:
//                if (postfixS) return "is";
//                else if (am) return "am";
//                else return "are";
//                break;
//            case simplePast:
//                if (postfixS||am) return "was";
//                else return "are";
//                break;
//            default:
//                break;
//        }
//    }
//    switch (verbTense) {
//        case simplePresent: {
//            if (passive) {
//                if (postfixS) return ("is "+verbTransform(verb, simplePast, false, false, false));
//                else {
//                    if (am) return ("am "+verbTransform(verb, simplePast, false, false, false));
//                    //Logic decduction: Not he/she/it, not I as pronoun => Only you/we/they
//                    else return ("are "+verbTransform(verb, simplePast, false, false, false));
//                }
//            } else {
//#warning - Current development: should build a sqlite db to store special case
//                if (postfixS) return verb+"s";
//                else return verb;
//            }
//        }
//            break;
//        case simplePast: {
//            if (passive) {
//                if (postfixS || am) return ("was "+verbTransform(verb, simplePast, false, false, false));
//                else return ("were "+verbTransform(verb, simplePast, false, false, false));
//            } else {
//#warning - Current development: should build a sqlite db to store special case
//                return verb+"ed";
//            }
//        }
//            break;
//        case simpleFuture:
//            return "will "+verb;
//            break;
//        default:
//            return verb;
//            break;
//    }
//}
//
//string buildObjectOwnership(Object *owner, string object) {
//    Person *per = dynamic_cast<Person *>(owner);
//    if (per) {
//        vector<string>strings;
//        return per->query("ownerPronoun", strings)+" "+object;
//    } else {
//        return object+" of "+owner->name();
//    }
//}
//
//string buildSentence(string pronoun, string verb, tense verbTense, bool passive, string object) {
//    string convertedVerb;
//    if (pronoun.compare("i")==0)
//        convertedVerb = verbTransform(verb, verbTense, passive, false, true);
//    else if (pronoun.compare("he")==0||pronoun.compare("she")==0||pronoun.compare("it")==0) {
//        convertedVerb = verbTransform(verb, verbTense, passive, true, false);
//    } else if (pronoun.compare("we")==0||pronoun.compare("they")==0||pronoun.compare("you")==0) {
//        convertedVerb = verbTransform(verb, verbTense, passive, false, false);
//    } else {
//#warning - Current development: need algorithm to detect if current pronoun need verb transform
//        convertedVerb = verbTransform(verb, verbTense, passive, true, false);;
//    }
//    pronoun[0] = toupper(pronoun[0]);
//    return pronoun+" "+convertedVerb+" "+object;
//}
//
//vector<string>adjectiveConvertion(vector<wordStruct>adjectives) {
//    vector<string>temps;
//    for (auto it = adjectives.begin(); it != adjectives.end(); it++) {
//        temps.push_back((*it).raw);
//    }
//    return temps;
//}
//
//bool nounHasSuchWordDescribe(vector<string>adjs, string word) {
//    for (auto it = adjs.begin(); it != adjs.end(); it++) {
//        if (!word.compare(*it)) return true;
//    }
//    return false;
//}
//
//string constructNoun(wordStruct noun) {
//    string result = "";
//    int length = noun.describe.size();
//    if ((length-2) > 0) {
//        for (int i = 0; i < noun.describe.size()-2; i++) {
//            result = result + noun.describe[i].raw + ", ";
//        }
//    }
//    if ((length-1) > 0) {
//        result = result + noun.describe[length-2].raw + " and ";
//    }
//    if (length)
//        result = result + noun.describe[length-1].raw + " ";
//    result = result + noun.raw;
//    return result;
//}