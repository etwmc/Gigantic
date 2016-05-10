//
//  main.m
//  MusicPlayer
//
//  Created by Wai Man Chan on 1/20/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPMusicPlayer.h"

int main(int argc, const char * argv[]) {
    MPMusicPlayer *player = [MPMusicPlayer singleExtension];
    [player startExtension];
    [[NSRunLoop mainRunLoop] run];
    return 0;
}
