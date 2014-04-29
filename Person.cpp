//
//  Person.cpp
//  NLP
//
//  Created by CHAN, Wai Man on 3/12/13.
//  Copyright (c) 2013 CHAN, Wai Man. All rights reserved.
//

#include "Person.h"
#include "helperFunction.h"
#include "NLP.h"

extern string returnCurrentLocation ();

string Person::getPersonLocation() {
    return "Unknown";
}

vector<Person *> Person::peopleWithDirectRelation(string relation) {
    vector<Person *>temp;
    for (vector<PeopleRelation *>::iterator con_it = directRelation.begin(); con_it != directRelation.end(); con_it++) {
        if (relation.compare((*con_it)->relationship)==0) {
            temp.push_back((*con_it)->person);
        }
    }
    return temp;
}
string Person::name() const{
    if (strcmp(nickname.c_str(), "")!=0) return nickname;
    else return this->fullname();
}
string Person::fullname() const {
     return firstName + ' ' + lastName;
}
string Person::pronoun() const{
    switch (gender) {
        case PGmale:
            return "he";
        case PGfemale:
            return "she";
        case PGnoGender:
            return "it";
    }
}
string Person::possessiveDeterminer() const{
    switch (gender) {
        case PGmale:
            return "his";
        case PGfemale:
            return "her";
        case PGnoGender:
            return "its";
    }
}

string Person::query(string syntax, vector<string>describes) {
    if (!syntax.compare("name")) {
        if (nounHasSuchWordDescribe(describes, "full")) {
            return this->fullname();
        } else if (nounHasSuchWordDescribe(describes, "first")) return this->firstName;
        else if (nounHasSuchWordDescribe(describes, "last")) return this->lastName;
        else return this->name();
    } else if (!syntax.compare("pronoun")) return this->pronoun();
    else if (!syntax.compare("gender")) {
        switch (gender) {
            case PGmale:
                return "male";
            case PGfemale:
                return "female";
            case PGnoGender:
                return "undefined";
        }
    } else if (!syntax.compare("ownerPronoun")) return possessiveDeterminer();
    else if (!syntax.compare("location")) return getPersonLocation();
    else return "";
}

#define PersonDB_FileAddr "/tmp/Person.db"

PersonDB::PersonDB() : ObjDB(PersonDB_FileAddr) {
}

void PersonDB::initDB() {
    /*
     * First table: the name list
     * including name, gender, birthday
     */
    
}

vector<Person *>personQuery(string query) {
    vector<Person *>people;
    
    return people;
}
