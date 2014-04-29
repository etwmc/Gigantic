#include "Person.h"

class VoiceCommander : public Person {
private:
    VoiceCommander();
public:
    virtual string pronoun() const;
    virtual string getPersonLocation();
    virtual string possessiveDeterminer() const;
    static VoiceCommander *singleton();
};