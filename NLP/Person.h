//
//  Person.h
//  NLP
//
//  Created by CHAN, Wai Man on 3/12/13.
//  Copyright (c) 2013 CHAN, Wai Man. All rights reserved.
//

#ifndef __NLP__Person__
#define __NLP__Person__

#include <iostream>
#include <string>
#include <vector>
#include "Object.h"
#include <map>
using namespace std;

class Person;
typedef struct {
    Person *person;
    string relationship;
} PeopleRelation;

typedef enum {
    PGmale,
    PGfemale,
    PGnoGender
} Person_Gender;

class Person : public Object {
#warning - Not implement yet
private:
protected:
    vector<PeopleRelation *> directRelation;
    string firstName, lastName, nickname;
    virtual string fullname() const;
    virtual string name() const;
    Person_Gender gender;
    //Pronoun Function
    virtual string pronoun() const;
    virtual string possessiveDeterminer() const;
    virtual string getPersonLocation();
    vector<Person *> peopleWithDirectRelation(string relation);
public:
    //General Infomation
    Person() {}
    Person(string data);
    //Object based information
    virtual string query(string syntax, vector<string>describes = vector<string>());
    Object *personRelated(string) { return NULL; }
};

ostream &operator << (ostream &ost, const Person & per);

class PersonDB : ObjDB {
    PersonDB();
    //Data DB
    vector<Person *>list;
    static Person *myself;
    //Service Socket
    virtual void initDB();
public:
    vector<Person *>personQuery(string query);
};

#endif /* defined(__NLP__Person__) */
