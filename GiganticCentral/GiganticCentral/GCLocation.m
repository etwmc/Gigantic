//
//  GCLocation.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/20/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCLocation.h"
#import <objc/message.h>

CLLocation *currentLocation;

@interface NSObject(CB)
- (void)logLonLat:(CLLocation*)location;
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
@end

@implementation NSObject(CB)
- (void)logLonLat:(CLLocation*)location
{
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSLog(@"latitude,logitude : %f, %f", coordinate.latitude, coordinate.longitude);
    NSLog(@"timestamp         : %@", location.timestamp);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //NSLog(@"Error: %@", error);
}

@end

extern CLLocationManager *locationManager;

@implementation GCLocation

+ (void)load {
    [self initialDict];
}

+ (CLLocationManager *)locationManager {
    return locationManager;
}

- (NSArray *)keys {
    return @[@"location"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *keys = [self keys];
    for (NSString *key in keys) {
        NSObject *value = [self valueForKeyPath:key];
        [aCoder encodeObject:value forKey:key];
    }
    [super encodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSArray *keys = [self keys];
        for (NSString *key in keys) {
            if ([aDecoder containsValueForKey:key]){
                NSObject *value = [aDecoder decodeObjectForKey:key];
                [self setValue:value forKeyPath:key];
            }
        }
    }
    return self;
}

- (id)valueForUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"location"]) {
        return self;
    }
    return nil;
}

@end
