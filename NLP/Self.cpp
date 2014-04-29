#include "Self.h"
#include "helperFunction.h"
#include <fstream>
using namespace std;

#define selfRecord "/tmp/self.setting"

Self::Self() {
    //Default Setting
    nickname = "NA";
    firstName = "Not";
    lastName = "Available";
    
    //Read in
    ifstream stream;
    stream.open(selfRecord);
    while (stream.good()) {
        string title;
        stream >> title;
        string data;
        stream >> data;
        if (!title.compare("nickname")) nickname = data;
        else if (!title.compare("firstname")) firstName = data;
        else if (!title.compare("lastname")) lastName = data;
    }
    stream.close();
}
string Self::getPersonLocation() {
    return returnCurrentLocation();
}
string Self::pronoun() const{
    return "you";
}
string Self::possessiveDeterminer() const {
    return "your";
}
Self *Self::singleton() {
    Self *singleton = NULL;
    if (!singleton) singleton = new Self();
    return singleton;
}

void Self::save() {
    //Read in
    ofstream stream;
    stream.open(selfRecord);
    stream << "nickname" << endl << nickname << endl;
    stream << "firstname" << endl << firstName << endl;
    stream << "lastname" << endl << lastName << endl;
    stream.close();
}