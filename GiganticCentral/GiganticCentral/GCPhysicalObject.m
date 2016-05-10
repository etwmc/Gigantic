//
//  GCPhysicalObject.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/20/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCPhysicalObject.h"
#import <objc/message.h>

@implementation GCPhysicalObject

+ (void)load {
    [self initialDict];
}

- (id)init {
    self = [super init];
    if (self) {
        creationTime = [[GCTime alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:0] withResolution:GCTime_Resolution_Day];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *keys = @[@"creationTime"];
    for (NSString *key in keys) {
        NSObject *value = [self valueForKeyPath:key];
        [aCoder encodeObject:value forKey:key];
    }
    [super encodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSArray *keys = @[@"creationTime"];
        for (NSString *key in keys) {
            if ([aDecoder containsValueForKey:key]){
                NSObject *value = [aDecoder decodeObjectForKey:key];
                [self setValue:value forKeyPath:key];
            }
        }
    }
    return self;
}

- (void)print {
    
}

@synthesize creationTime;
@end
