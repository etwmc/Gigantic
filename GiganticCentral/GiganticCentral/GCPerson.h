//
//  GCPerson.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 25/7/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCPhysicalObject.h"
#import "GCLocation.h"

typedef enum {
    GCPersonGender_noGender = 0,
    GCPersonGender_male,
    GCPersonGender_female,
} GCPersonGender;

typedef enum {
    GCPersonRacial_unknown = 0,
    GCPersonRacial_white,
    GCPersonRacial_black,
    GCPersonRacial_asian,
    GCPersonRacial_nativeAmerican,
    GCPersonRacial_hispanic,
} GCPersonRacial;

typedef enum {
    GCPersonNationality_chinese = 0,
    GCPersonNationality_japanese,
    GCPersonNationality_american,
    GCPersonNationality_english,
    GCPersonNationality_french,
} GCPersonNationality;

@interface GCPerson : GCPhysicalObject <NSCoding>
@property (readwrite) NSString *firstName, *lastName;
@property (readwrite) GCPersonRacial race;
@property (readwrite, assign) GCPersonGender gender;
@property (readwrite) short numberOfParty;
@property (readwrite) NSString *phoneNumber;
@property (readwrite) GCLocation *homeAddress;
@property (readwrite) GCPersonNationality nationality;
@property (readwrite) GCLocation *currentLocation;
@property (readwrite) NSArray *relation;
- (void)phone;
+ (GCPerson *)user;
+ (GCPerson *)server;
@end

typedef enum : NSUInteger {
    //Layer 1 Relation: family realtion
    GCPersonRelation_Parent = 1 << 0,
    GCPersonRelation_Couple = 2 << 0,
    GCPersonRelation_Friend = 3 << 0,
    //Layer 2 Relation: business realtion
    GCPersonRelation_Employ = 1 << 2,
} GCPersonRelation;

@interface GCRelationship : NSObject
@property (readwrite) GCPersonRelation relation;
@property (readwrite) GCPerson *toPerson;
@end