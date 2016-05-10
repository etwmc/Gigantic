//
//  GCTime.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/18/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCObject.h"
#import "GCValue.h"

typedef enum {
    GCTime_Resolution_Year = 0,
    GCTime_Resolution_Month,
    GCTime_Resolution_Day,
    GCTime_Resolution_Hour,
    GCTime_Resolution_Minute,
    GCTime_Resolution_Second
} GCTime_Resolution;


@interface GCTimeInterval : GCObject
- (id)initWithTimeInterval:(long long)intervalInSecond;
@property (readonly) GCValue *year, *month, *day, *hour, *minute, *second;
@end

@interface GCTime : GCObject
@property (readonly) NSDate *date;
@property (readonly) NSDateFormatter *formatter;
@property (readonly) NSNumber *year, *month, *day, *hour, *minute, *second;
- (id)initWithDate:(NSDate *)date withResolution:(GCTime_Resolution)resolution;
- (GCTimeInterval *)durationToNow;
@end