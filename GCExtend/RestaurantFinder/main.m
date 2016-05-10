//
//  main.m
//  RestaurantFinder
//
//  Created by Wai Man Chan on 2/21/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFRestaurantFinderExtension.h"

int main(int argc, const char * argv[]) {
        // insert code here...
        RFRestaurantFinderExtension *rf = [RFRestaurantFinderExtension singleExtension];
        [rf startExtension];
        [[NSRunLoop mainRunLoop] run];
    return 0;
}
