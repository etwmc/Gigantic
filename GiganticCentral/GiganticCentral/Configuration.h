//
//  Configuration.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 4/8/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#ifndef GiganticCentral_Configuration_h
#define GiganticCentral_Configuration_h

/*
 * Test Mode:
 * 0 = none
 * 1 = text->grammar engine
 */

#define TestMode 1

#if TestMode
#import "GCTextParser.h"
#else
#import "GCVoiceInput.h"
#endif

#endif
