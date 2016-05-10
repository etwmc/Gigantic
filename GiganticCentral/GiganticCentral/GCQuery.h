//
//  GCQuery.h
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCCollection.h"
#import "GCQueryConstant.h"
#import "GCQuerySolution.h"
#import "QueryContext.h"

@class QuerySolution;

#define startActionSession @"Query_Start_Action"
#define endActionSession @"Query_End_Action"

@interface Query : NSObject
@property (readwrite) NSString *inputMessage;

//Whether the query is validate
@property (readonly) bool validate;

//What type of query it is
@property (assign) queryType type;

//For statement: apply the actions to all targets
@property (strong) NSArray *actions;

//Targets: all the reference objects in the query. e.g. when is [my] birthday
@property (strong) NSArray *targets;

/* Constaints: filter the query to be valid based on explicit describtion e.g. that _______
 * Example: the car that is red, the friend that is male, newest album
 * Deprecated: The constraints part will be conducted in object tracing
 */
@property (strong) NSArray *constraints;

/* Comparator: compare the targets with the comparators
 * Example: older, HKUST, ....
 */
@property (strong) NSArray *comparator;

//Analyzer: get the attribute referenced
@property (strong) NSArray *analyzer;

//Filter the return type based on question word
@property (strong) Class returnTypes;
//Solution for question
@property (strong) QuerySolution *solution;
//Greeting Type
@property (readwrite) exclamationType exType;
+ (Query *)createQueryFromMessage:(const char *)msg withGrammarBuffer:(const char *)buffer;
- (bool)applyConstraints;
- (bool)applyAction;
- (void)invalidate;
- (bool)analyze;
- (bool)formAnswer;
@end;