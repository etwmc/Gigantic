//
//  GCQueryConstant.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef GiganticCentral_GCQueryConstant_h
#define GiganticCentral_GCQueryConstant_h


typedef enum {
    messagePurpose_question,
    messagePurpose_command,
    messagePurpose_exclamation,
    messagePurpose_statement,
    messagePurpose_condition
} queryType;

typedef enum {
    exclamationType_none = 0,
    exclamationType_greet,
    exclamationType_gratutyde
} exclamationType;

#endif
