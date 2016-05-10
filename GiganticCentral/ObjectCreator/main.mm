//
//  main.m
//  ObjectCreator
//
//  Created by Wai Man Chan on 12/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <iostream>

using namespace std;

bool loopContinue() {
    char conOrBreak[8];
    printf("Continue? ");
    cin.getline(conOrBreak, 8);
    return tolower(conOrBreak[0])=='y';
}

int main(int argc, const char * argv[]) {
    
        // insert code here...
        do {
            char temp[1024];
            printf("What class? ");
            cin.getline(temp, 1024);
            NSString *className = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
            Class objectClass = NSClassFromString(className);
            NSObject *newObj = [objectClass new];
            do {
                printf("Which key to change? ");
                cin.getline(temp, 1024);
                NSString *key = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                
                printf("To what value? ");
                cin.getline(temp, 1024);
                NSString *value = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
                
                @try {
                    [newObj setValue:value forKeyPath:key];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error on changing key: %@, with exception %@", key, exception);
                }
            } while (loopContinue());
            
            printf("To what address? ");
            cin.getline(temp, 1024);
            NSString *addr = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
            
            [NSKeyedArchiver archiveRootObject:newObj toFile:addr.stringByExpandingTildeInPath];
            
        } while (loopContinue());
    
    return 0;
}

//Useless interface, to stop GCObject having compile error
@interface QueryContext : NSObject
@end
@implementation QueryContext
+ (instancetype)sharedQuery { return nil; }
@end