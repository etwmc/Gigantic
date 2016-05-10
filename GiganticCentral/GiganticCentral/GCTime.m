//
//  GCTime.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/18/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCTime.h"

@implementation GCTime
@synthesize date, formatter;
@synthesize year, month, day, hour, minute, second;

+ (void)load {
    [self initialDict];
}

- (id)init {
    self = [super init];
    if (self) {
        date = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self;
}

- (id)initWithDate:(NSDate *)_date withResolution:(GCTime_Resolution)resolution{
    self = [super init];
    if (self) {
        date = _date;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitSecond|NSCalendarUnitYear) fromDate:_date];
        NSString *dateFormat = nil;
        switch (resolution) {
            case GCTime_Resolution_Day:
                if (!dateFormat) dateFormat = @"dd MMMM yyyy";
                day = [NSNumber numberWithInteger:components.day];
            case GCTime_Resolution_Month:
                if (!dateFormat) dateFormat = @"MMMM yyyy";
                month = [NSNumber numberWithInteger:components.month];
            case GCTime_Resolution_Year:
                if (!dateFormat) dateFormat = @"yyyy";
                year = [NSNumber numberWithInteger:components.year];
                break;
            case GCTime_Resolution_Second:
                if (!dateFormat) dateFormat = @"h mm ss a";
                second = [NSNumber numberWithInteger:components.second];
            case GCTime_Resolution_Minute:
                if (!dateFormat) dateFormat = @"h mm a";
                minute = [NSNumber numberWithInteger:components.minute];
            case GCTime_Resolution_Hour:
                if (!dateFormat) dateFormat = @"HH";
                hour = [NSNumber numberWithInteger:components.hour];
                break;
        }
        formatter = [NSDateFormatter new];
        [formatter setDateFormat:dateFormat];
    }
    return self;
}

- (GCTimeInterval *)durationToNow {
    return [[GCTimeInterval alloc] initWithTimeInterval:-date.timeIntervalSinceNow];
}

- (NSString *)description {
    return [formatter stringFromDate:date];
}

+ (NSString *)routingName {
    return @"Time";
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:date forKey:@"date"];
    [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        date = [aDecoder decodeObjectForKey:@"date"];
        formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"dd MM yyyy"];
    }
    return self;
}

@end

@implementation GCTimeInterval
@synthesize year, month, day, hour, minute, second;

- (id)initWithTimeInterval:(long long)intervalInSecond {
    self = [super init];
    if (self) {
        second = [[GCValue alloc] initNumber:@(intervalInSecond%60)];  intervalInSecond /= 60;
        minute = [[GCValue alloc] initNumber:@(intervalInSecond%60)];  intervalInSecond /= 60;
        hour = [[GCValue alloc] initNumber:@(intervalInSecond%24)];  intervalInSecond /= 24;
        day = [[GCValue alloc] initNumber:@(intervalInSecond%30)];  intervalInSecond /= 30;
        month = [[GCValue alloc] initNumber:@(intervalInSecond%12)];  intervalInSecond /= 12;
        year = [[GCValue alloc] initNumber:@(intervalInSecond)];
    }
    return self;
}

@end