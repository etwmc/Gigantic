//
//  GCPerson.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 25/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCPerson.h"
#import <objc/message.h>

#import <AppKit/AppKit.h>

#import "GCLocation.h"

@interface GCPerson () {
    GCLocation *_currentLocation;
}
@end

extern CLLocation *currentLocation;

@implementation GCRelationship
@synthesize relation, toPerson;
@end
@interface GCPerson (GCRelationshipExten)
- (NSArray *)getFriend;
@end

@implementation GCPerson (GCRelationshipExten)
- (NSArray *)getFriend {
    NSMutableArray *result = [NSMutableArray new];
    for (GCRelationship *relation in self.relation) {
        if (relation.relation == GCPersonRelation_Friend) {
            [result addObject:relation.toPerson];
        }
    }
    return result;
}
@end

@implementation GCPerson
@synthesize firstName, lastName, gender, numberOfParty, race, homeAddress, relation, phoneNumber;

- (GCLocation *)location {
    GCLocation *location = [[GCLocation alloc] initWithAttributeFetch:^id{
        sleep(1);
        return currentLocation;
    }];
    
    [location setLongFetchBlock:^NSString *{
        return [NSString stringWithFormat:@"Now searching for %@ location", self.ownershipPronoun];
    }];
    
    [location setCompletitionBlock:^NSString *(id value){
        CLLocationCoordinate2D corrdinate = ((CLLocation *)value).coordinate;
        NSString *resulting = [NSString stringWithFormat:@"%@ GPS coordinate is %f %f", self.ownershipPronoun, corrdinate.latitude, corrdinate.longitude];
        return resulting;
    }];
    [location prepareAttribute];
    return location;
}

+ (void)load {
    [self initialDict];
}

- (id)init {
    self = [super init];
    if (self) {
        numberOfParty = 3;
    }
    return self;
}

- (NSString *)outputFormat {
    return [NSString stringWithFormat:@"%@ %@ %%@", self.pronoun, self.variationOfBe];
}

- (id)initWithFirstName:(NSString *)_firstName lastName:(NSString *)_lastName gender:(GCPersonGender)_gender party:(short)_party birth:(NSDate *)birth {
    self = [self init];
    if (self) {
        firstName = _firstName;
        lastName = _lastName;
        gender = _gender;
        numberOfParty = _party;
        self.creationTime = [[GCTime alloc] initWithDate:birth withResolution:GCTime_Resolution_Day];
    }
    return self;
}

- (NSString *)pronoun {
    if (numberOfParty == 1) return @"you";
    else if (numberOfParty == 2) return @"i";
    else switch (self.gender) {
        case GCPersonGender_male:    return @"he";
        case GCPersonGender_female:  return @"she";
        case GCPersonGender_noGender:return @"he or she";
    }
}
- (NSString *)possessiveDeterminer {
    if (numberOfParty == 1) return @"your";
    else if (numberOfParty == 2) return @"i";
    else switch (self.gender) {
        case GCPersonGender_male:    return @"him";
        case GCPersonGender_female:  return @"her";
        case GCPersonGender_noGender:return @"him or her";
    }
}

- (NSString *)ownershipPronoun {
    if (numberOfParty == 1) return @"your";
    else if (numberOfParty == 2) return @"my";
    else switch (self.gender) {
        case GCPersonGender_male:    return @"his";
        case GCPersonGender_female:  return @"her";
        case GCPersonGender_noGender:return @"his or her";
    }
}

- (NSString *)variationOfBe {
    if (numberOfParty == 1) return @"are";
    else if (numberOfParty == 2) return @"am";
    else return @"is";
}

+ (GCPerson *)user {
    static GCPerson *per = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        per = [[GCPerson alloc] initWithFirstName:@"Wai Man" lastName:@"Chan" gender:GCPersonGender_male party:1 birth:[NSDate dateWithTimeIntervalSince1970:722476800]];
        
        GCObjectRequest *requestSanki = [[GCObjectRequest alloc] initWithString:@"125, 1, 0"];
        GCPerson *sanki = [self getInstanceFromRequest:requestSanki];
        GCRelationship *sankitRel = [[GCRelationship alloc] init];
        sankitRel.relation = GCPersonRelation_Friend;
        sankitRel.toPerson = sanki;
        
        GCObjectRequest *requestJonny = [[GCObjectRequest alloc] initWithString:@"125, 1, 1"];
        GCPerson *jonny = [self getInstanceFromRequest:requestJonny];
        GCRelationship *jonnyRel = [[GCRelationship alloc] init];
        jonnyRel.relation = GCPersonRelation_Friend;
        jonnyRel.toPerson = jonny;
        
        per.relation = @[sankitRel, jonnyRel];
    });
    return per;
}

+ (GCPerson *)server {
    static GCPerson *per = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        per = [[GCPerson alloc] initWithFirstName:@"Gigantic" lastName:@"" gender:GCPersonGender_noGender party:2 birth:[NSDate dateWithTimeIntervalSince1970:-365*40*24*60*60]];
    });
    return per;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

+ (NSArray *)key {
    return @[@"firstName", @"lastName", @"race", @"gender", @"relation", @"numberOfParty", @"homeAddress", @"nationality"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *keys = [GCPerson key];
    for (NSString *key in keys) {
        NSObject *value = [self valueForKeyPath:key];
        [aCoder encodeObject:value forKey:key];
    }
    [super encodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSArray *keys = [GCPerson key];
        for (NSString *key in keys) {
            if ([aDecoder containsValueForKey:key]){
                NSObject *value = [aDecoder decodeObjectForKey:key];
                [self setValue:value forKeyPath:key];
            }
        }
    }
    return self;
}

- (void)phone {
    NSURL *url = [NSURL URLWithString:[@"tel:" stringByAppendingString:phoneNumber]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
