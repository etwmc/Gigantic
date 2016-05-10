//
//  main.m
//  LyricFinder
//
//  Created by Wai Man Chan on 4/11/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LyricFinder.h"

int main(int argc, const char * argv[]) {
    LyricFinder *player = [LyricFinder singleExtension];
    [player startExtension];
    [[NSRunLoop mainRunLoop] run];
    return 0;
}
