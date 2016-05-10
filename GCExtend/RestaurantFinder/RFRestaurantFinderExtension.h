//
//  RFRestaurantFinderExtension.h
//  GCExtend
//
//  Created by Wai Man Chan on 2/21/15.
//  Copyright (c) 2015 Wai Man Chan. All rights reserved.
//

#import <GCExtend/GCExtend.h>

#define GCELocation GCEObject
#define GCEBool GCEObject
#define GCEPerson GCEObject

typedef enum {
    RFRestaurantFoodStyle_chinese = 0,
    RFRestaurantFoodStyle_japanese,
    RFRestaurantFoodStyle_american,
    RFRestaurantFoodStyle_english,
    RFRestaurantFoodStyle_french,
    RFRestaurantFoodStyle_fastFood,
} RFRestaurantFoodStyle;

@interface RFFoodType : GCEObject
@end

@interface RFRestaurant : GCELocation
@property (readonly) BOOL opening;
@property (readwrite) NSString *phoneNumber;
@property (readwrite) GCELocation *location;
@property (readwrite) RFRestaurantFoodStyle style;
- (GCEBool *)suitableForPerson:(GCEPerson *)person;
@end

/*
 * This extension will only have one function: 
 * Support a "search" function from the 
 */

@interface RFRestaurantFinderExtension : GCEExtension
- (NSArray *)findRestaurantsForCondition:(NSDictionary *)conditions;
@end
