#include "VoiceCommander.h"

VoiceCommander::VoiceCommander() {
    nickname = "NLP";
    firstName = "N.";
    lastName = "LP";
}
string VoiceCommander::getPersonLocation() {
    return "your ear";
}
string VoiceCommander::pronoun() const{
    return "i";
}
string VoiceCommander::possessiveDeterminer() const {
    return "my";
}
VoiceCommander *VoiceCommander::singleton() {
    VoiceCommander *singleton = NULL;
    if (!singleton) singleton = new VoiceCommander();
    return singleton;
}