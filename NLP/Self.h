#include "Person.h"

#ifndef __NLP__Self__
#define __NLP__Self__

class Self : public Person {
private:
    void save();
public:
    Self();
    virtual string pronoun() const;
    virtual string getPersonLocation();
    virtual string possessiveDeterminer() const;
    static Self *singleton();
};
#endif