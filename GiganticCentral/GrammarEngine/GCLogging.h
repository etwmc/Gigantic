//
//  GCLogging.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 26/8/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#ifndef __GiganticCentral__GCLogging__
#define __GiganticCentral__GCLogging__

#import <stdio.h>
#import <dispatch/dispatch.h>

class logger {
    void log(const char *string, size_t length);
public:
    void logUndefineAction(const char *action, const char *object);
    void logUnbalanceLogic(const char *term);
    void logNonexistTerm(const char *term);
    void logFailGrammar(const char *fullInput);
};

#endif /* defined(__GiganticCentral__GCLogging__) */
