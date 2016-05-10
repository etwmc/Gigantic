//
//  GCLocation.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/20/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GCAttribute.h"

@interface GCLocation : GCAttribute
+ (CLLocationManager *)locationManager;
@end
