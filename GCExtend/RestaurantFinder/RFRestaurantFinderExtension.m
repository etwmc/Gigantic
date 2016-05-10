//
//  RFRestaurantFinderExtension.m
//  GCExtend
//
//  Created by Wai Man Chan on 2/21/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import "RFRestaurantFinderExtension.h"

@implementation RFFoodType
@end

@interface RFRestaurantFinderExtension () {
    NSMutableArray *restaurantsList;
    NSMutableArray *searchingList;
    NSString *resultBuffer;
}
- (BOOL)restaurant:(RFRestaurant *)restaurant isSuitableForPerson:(NSUUID *)personUUID;
@end

@implementation RFRestaurant
@synthesize phoneNumber, opening, location, style;
- (id)valueForUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"nationality"]) {
        return [NSNumber numberWithInt:style];
    }
    return nil;
}
@end

@implementation RFRestaurantFinderExtension

- (BOOL)restaurant:(RFRestaurant *)restaurant isSuitableForPerson:(NSString *)personUUID {
    NSString *className = [self getRawAttributeFromRemoteObject:personUUID forKeyPath:@"className"];
    if (className && [className containsString:@"Person"]) {
        NSString *personFirstName = [self getRawAttributeFromRemoteObject:personUUID forKeyPath:@"firstName"];
        NSString *personLastName = [self getRawAttributeFromRemoteObject:personUUID forKeyPath:@"lastName"];
        
        if ([personFirstName isEqualToString:@"Sanki"] && [personLastName isEqualToString:@""]) {
            //Reject the Japanese restaurant "Fake Japanese Restaurant"
            return ![restaurant.name isEqualToString:@"Fake Japanese Restaurant"] && ![restaurant.name isEqualToString:@"Real Chinese Restaurant"];
        }
        
        if ([personFirstName isEqualToString:@"Wai Man"] && [personLastName isEqualToString:@"Chan"]) {
            //Reject the Japanese restaurant "Real Chinese Restaurant"
            return ![restaurant.name isEqualToString:@"Real Japanese Restaurant"] && ![restaurant.name isEqualToString:@"Fake Chinese Restaurant"];
        }
        
    } else if (className && [className containsString:@"RFFoodType"]) {
        NSString *foodType = [self getRawAttributeFromRemoteObject:personUUID forKeyPath:@"name"];
        if ([foodType isEqualToString:@"Dim Sum"]) {
            return [restaurant.name isEqualToString:@"Real Chinese Restaurant"];
        } else if ([foodType isEqualToString:@"Sushi"]) {
            return [restaurant.name isEqualToString:@"Real Japanese Restaurant"];
        }
    }
    
    return true;
}

- (NSArray *)getSubObjectUUID:(GCEObjectRequest *)subObjectRequest fromRoot:(NSString *)rootObjUUID {
    switch (subObjectRequest.objID) {
        case 0: {
            NSMutableArray *uuids = [NSMutableArray new];
            for (NSObject *obj in restaurantsList) {
                [uuids addObject:[self getUUIDForObject:obj]];
            }
            return uuids;
        }
            break;
    }
    return nil;
}

- (NSDictionary *)routingSchemeForRequest:(GCEObjectRequest *)request {
    switch (request.type) {
            //Routing of Verb
        case phaseType_verb:
            switch (request.objID) {
                    //Find
                case 0:
                    return @{@"Commands": @[
                                     @{@"Command": @"print"}
                                     ], @"Return Value": [NSNumber numberWithBool:false]};
            }
    }
    return nil;
}

- (NSString *)finalizeSession:(NSUInteger)sessionID {
    if (searchingList == nil) return resultBuffer;
    if (searchingList.count == 0)
        resultBuffer = @"I found nothing";
    else {
        NSString *result = @"I found ";
        for (RFRestaurant *restaurant in searchingList) {
            result = [result stringByAppendingFormat:@"%@, ", restaurant.name];
        }
        searchingList = nil;
        result = [result substringToIndex:result.length-2];
        resultBuffer = result;
    }
    return resultBuffer;
}

- (NSString *)setAction:(NSDictionary *)actionDictionary atObjects:(NSArray *)objs {
    //Handle the action: Find
    if (!searchingList)
        searchingList = [NSMutableArray new];
    RFRestaurant *restaurant = self.objectList[[[NSUUID alloc] initWithUUIDString:objs[0]]];
    [searchingList addObject:restaurant];
    if (actionDictionary[@"modifier"]) {
        NSDictionary *modifier = actionDictionary[@"modifier"];
        if (modifier[@"for"]) {
            NSArray *forMod = modifier[@"for"];
            for (NSString *uuid in forMod) {
                if (![self restaurant:restaurant isSuitableForPerson:uuid]) {
                    [searchingList removeObject:restaurant];
                }
            }
        }
    }
    return @"Success";
}

RFRestaurant *createRestaurant(NSString *restaurantName, RFRestaurantFoodStyle style) {
    RFRestaurant *r = [RFRestaurant new];
    r.name = restaurantName;
    r.style = style;
    return r;
}

- (id)init {
    self = [super initWithExtensionName:@"Restaurant Finder" extensionID:1001 andDictionaryAddress:@"/vui/profile/Restaurant Finder/rf.dict"];
    if (self) {
        restaurantsList = [NSMutableArray new];
        
        RFRestaurant *mcdonald = createRestaurant(@"McDonald's", RFRestaurantFoodStyle_fastFood);
        [restaurantsList addObject:mcdonald];
        
        RFRestaurant *fakeJapanese = createRestaurant(@"Fake Japanese Restaurant", RFRestaurantFoodStyle_japanese);
        [restaurantsList addObject:fakeJapanese];
        
        RFRestaurant *realJapanese = createRestaurant(@"Real Japanese Restaurant", RFRestaurantFoodStyle_japanese);
        [restaurantsList addObject:realJapanese];
        
        RFRestaurant *fakeChinese = createRestaurant(@"Fake Chinese Restaurant", RFRestaurantFoodStyle_chinese);
        [restaurantsList addObject:fakeChinese];
        
        RFRestaurant *realChinese = createRestaurant(@"Real Chinese Restaurant", RFRestaurantFoodStyle_chinese);
        [restaurantsList addObject:realChinese];
        
        //Food Type
        RFFoodType *dimSum = [RFFoodType new];
        dimSum.name = @"Dim Sum";
        [self registerInstance:dimSum];
        
        RFFoodType *sushi = [RFFoodType new];
        sushi.name = @"Sushi";
        [self registerInstance:sushi];
        
    }
    return self;
}

@end
