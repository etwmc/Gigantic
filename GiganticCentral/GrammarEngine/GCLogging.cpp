//
//  GCLogging.c
//  GiganticCentral
//
//  Created by Wai Man Chan on 26/8/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCLogging.h"

dispatch_queue_t loggingQueue = dispatch_queue_create("Logging", DISPATCH_QUEUE_SERIAL);

FILE *loggingFile = fopen("/vui/log", "a");

void logger::log(const char *string, size_t length) {
    dispatch_async(loggingQueue, ^{
        fwrite(string, sizeof(char), length, loggingFile);
        fwrite("\n", sizeof(char), 1, loggingFile);
    });
}

void logger::logUnbalanceLogic(const char *term) {
    char buffer[512];
    size_t len = snprintf(buffer, 512, "Unbalance Logic: %s", term);
    log(buffer, len);
}

void logger::logNonexistTerm(const char *term) {
    char buffer[512];
    size_t len = snprintf(buffer, 512, "Non-exist term: %s", term);
    log(buffer, len);
}

void logger::logUndefineAction(const char *action, const char *object) {
    char buffer[512];
    size_t len = snprintf(buffer, 512, "Fail aggregation: [%s] with action [%s]", object, action);
    log(buffer, len);
}

void logger::logFailGrammar(const char *fullInput) {
    char buffer[512];
    size_t len = snprintf(buffer, 512, "Fail Grammar: %s", fullInput);
    log(buffer, len);
}
