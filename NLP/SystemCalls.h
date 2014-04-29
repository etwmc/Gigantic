//
//  SystemCalls.h
//  NLP
//
//  Created by Wai Man Chan on 2014/1/20.
//  Copyright (c) 2014年 CHAN, Wai Man. All rights reserved.
//

#ifndef NLP_SystemCalls_h
#define NLP_SystemCalls_h

typedef struct {
    
} Location;

Location getCurrentLocation();
bool makePhoneCall(const char *phoneNumber, void *delegate);
bool sendMessage(const char *phoneNumber, const char *message);

#endif
