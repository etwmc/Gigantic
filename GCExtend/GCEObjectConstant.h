//
//  GCObjectConstant.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef GiganticCentral_GCObjectConstant_h
#define GiganticCentral_GCObjectConstant_h


typedef enum {
    phaseType_questionWord,
    phaseType_noun,
    phaseType_pronoun,
    phaseType_adjective,
    phaseType_verb,
    phaseType_adverb,
    phaseType_person,
    phaseType_location,
    phaseType_preposition,
    phaseType_digit,
    phaseType_instance,
    
    phaseType_exclamation_greet,
    phaseType_exclamation_parting,
    phaseType_exclamation_gratitude,
    
    phaseType_modifier = 32,
    phaseType_modifier_action,
    phaseType_modifier_time,
    phaseType_modifier_location,
    phaseType_modifier_constraint,
    phaseType_modifier_objectRelation,
    
    phaseType_none = 255
} phaseType;


#endif
