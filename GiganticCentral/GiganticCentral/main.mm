//
//  main.cpp
//  GiganticCentral
//
//  Created by Wai Man Chan on 6/12/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <dispatch/dispatch.h>
#import "GCExtensionCentral.h"
#import "GCCollection.h"

#import "GCRecording.h"

#import <stdio.h>

#import "HypothesesTester.h"

#import <signal.h>

#import "Configuration.h"

#import <CoreLocation/CoreLocation.h>

#import "GCVoiceParser.h"

void printObj(GCObject *obj);

char programAddr[1024];
GCExtensionCentral *central;

CLLocationManager *locationManager;

int main(int argc, const char * argv[]) {
    
    id obj = [[NSObject alloc] init];
    id locationManager = nil;
    if ([CLLocationManager locationServicesEnabled]) {
        printf("location service enabled\n");
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:obj];
        [locationManager startUpdatingLocation];
    }
    
    // Extension
    central = [GCExtensionCentral defaultCentral];
    
    strncpy(programAddr, argv[0], 1024);
    
    printf("Loading --- Ready in 3 seconds\n");
    sleep(3);
    
#if TestMode == 1
    
#else
    //GCVoiceInputManager *manager = [GCVoiceInputManager sharedManager];
#endif
    
    dispatch_queue_t queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        char tmp[128];
        while (true) {
#if TestMode == 1
            [GCTextParser parseIncoming];
#else
            [GCVoiceParser parseIncoming];
            //[manager startInput];
#endif
        }
        
    });
    
    [[NSRunLoop mainRunLoop] run];

#if DEBUG
#endif
    return 0;
}

NSMutableArray *result;
void _printObj(GCObject *obj) ;
void printObj(GCObject *obj) {
    result = [NSMutableArray array];
    _printObj(obj);
    NSLog(@"%@", [result componentsJoinedByString:@" "]);
}

void _printObj(GCObject *obj) {
    if ([obj isKindOfClass:[GCPerson class]]) {
        [result insertObject:((GCPerson *)obj).possessiveDeterminer atIndex:0];
    } else {
        [result addObject:obj.description];
    }
    if (obj.rootObj) _printObj(obj.rootObj);
}