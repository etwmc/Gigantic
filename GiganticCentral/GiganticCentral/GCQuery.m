//
//  GCQuery.m
//  GiganticCentral
//
//  Created by Wai Man Chan on 11/26/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import "GCQuery.h"
#import "GCBoolean.h"

@implementation Query
@synthesize inputMessage, type, actions, constraints, returnTypes, targets, solution, validate, analyzer, exType, comparator;
- (id)init {
    self = [super init];
    if (self) {
        actions = [NSArray array];
        constraints = [NSArray array];
        targets = @[];
        solution = [QuerySolution new];
        validate = true;
        analyzer = @[];
        comparator = @[];
    }
    return self;
}
+ (Query *)createQueryFromMessage:(const char *)msg withGrammarBuffer:(const char *)buffer {
    if (strncmp(buffer, "Fail", 4) == 0) {
        return NULL;
    } else {
        NSString *grammarInput = [NSString stringWithUTF8String:buffer];
        NSArray *paras = [grammarInput componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        Query *q = [Query new];
        q.inputMessage = [NSString stringWithUTF8String:msg];
        
        NSString *questionType = nil;
        
        for (NSString *str in paras) {
            NSArray *temp = [str componentsSeparatedByString:@": "];
            //Set Type
            if ([temp[0] isEqualToString:@"Type"]) {
                
                if ([temp[1] isEqualToString:@"Question"])
                    q.type = q.solution.type = messagePurpose_question;
                else if ([temp[1] isEqualToString:@"Statement"])
                    q.type = messagePurpose_statement;
                else if ([temp[1] isEqualToString:@"Exclamation"])
                    q.type = messagePurpose_exclamation;
                else if ([temp[1] isEqualToString:@"Command"])
                    q.type = messagePurpose_command;
                else if ([temp[1] isEqualToString:@"Condition"])
                    q.type = messagePurpose_condition;
                
            } else if ([temp[0] isEqualToString:@"Question Type"]) {
                if (![temp[1] isEqualToString:@"Boolean"])
                    questionType = temp[1];
                NSString *className = [NSString stringWithFormat:@"GC%@", ((NSString *)temp[1]).capitalizedString];
                q.returnTypes = NSClassFromString(className);
                
            } else if ([temp[0] isEqualToString:@"Target"]) {
                //Trace back object
                q.targets = [q.targets arrayByAddingObjectsFromArray:traceObjectsFromString(temp[1])];
                if (q.returnTypes && questionType) {
                    q.targets = [q.targets arrayByAddingObjectsFromArray:traceObjectsFromString([NSString stringWithFormat:@"%@->%@", temp[1], questionType])];
                }
            } else if ([temp[0] isEqualToString:@"Degree Of"]) {
                q.analyzer = [q.analyzer arrayByAddingObject:[[GCObjectRequest alloc] initWithString:temp[1]]];
            } else if ([temp[0] isEqualToString:@"Method"]) {
                //Greet
                {
                    if ([temp[1] isEqualToString:@"Greet"])
                        q.exType = exclamationType_greet;
                }
            } else if ([temp[0] isEqualToString:@"Comparsion"]) {
                q.comparator = [q.comparator arrayByAddingObject:[[GCAdjectiveRequest alloc] initWithString:temp[1]]];
            } else if ([temp[0] isEqualToString:@"Action"]) {
                q.actions = [q.actions arrayByAddingObject:[[GCActionObjectRequest alloc] initWithString:temp[1]]];
            }
        }
        
        return q;
    }
}


NSArray *traceObjectsFromString(NSString *str) {
    QueryContext *qc = [QueryContext sharedQuery];
    return [qc traceObject:str];
}

//The following functions return boolean value on:
//Whether the query is grammarally correct
//Whether the query is contextly correct
//Whether the query is logically correct

//Not:
//Whether the question has an answer
//Whether the action is success

- (bool)applyConstraints {
    //First: remove stuff doesn't fit constraints
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(GCObject *evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject checkConstraints:constraints].value.intValue == judgementCall_true;
    }];
    solution.constraintsResult = [targets filteredArrayUsingPredicate:pred];
    //Second: sort
    for (GCObjectRequest *request in constraints) {
        NSLog(@"%@", request);
    }
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor]
    return true;
}

- (bool)applyAction {
    if (solution.constraintsResult.count == 0) return false;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:startActionSession object:nil];
    
    //Start doing each action
    for (GCObject *obj in solution.constraintsResult) {
        GCObject *sol = [obj performAction:actions forSession:0];
        //The action itself will not be stored
        if (sol) solution.resultObjs = [solution.resultObjs arrayByAddingObject:obj];
    }
    
    //Finalize it with each class (not per object, as for every class the finalization will occur once
    for (GCObject *obj in solution.constraintsResult) {
        self.solution.resultDialog = [obj finalizeActionPerformSession:0];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:endActionSession object:nil];
    
    return true;
}

- (bool)analyze {
    if (solution.resultObjs.count == 0) return true;
    
    bool newResult = false;
    NSArray *result = @[];
    
    if (self.analyzer.count) {
        newResult = true;
        for (GCObjectRequest *ana in analyzer) {
            for (GCObject *obj in solution.resultObjs) {
                NSObject *analyzeResult = [obj getAttribute:ana];
                if (analyzeResult) result = [result arrayByAddingObject:analyzeResult];
            }
        }
    }
    
    if (newResult) solution.resultObjs = result;
    
    
    newResult = false;
    
    if (self.comparator.count) {
        for (GCObject *obj in solution.resultObjs) {
            GCValue *analyzeResult = [obj checkConstraints:self.comparator];
            analyzeResult.rootObj = obj;
            if (analyzeResult) result = [result arrayByAddingObject:analyzeResult];
        }
        newResult = true;
    }
    
    if (newResult) solution.resultObjs = result;
    return true;
}

- (bool)formAnswer {
    //Trim failed judgement call analyze
    solution.resultObjs = [solution.resultObjs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[GCValue class]]) {
            return ((GCValue *)evaluatedObject).value.intValue != judgementCall_fail;
        }
        return true;
    }]];
    
    //If there is result type constraints
    if (returnTypes) {
        solution.resultObjs = [solution.resultObjs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", returnTypes]];
        if (solution.resultObjs.count == 0) return false;
    }
    
    
    
    switch (type) {
        case messagePurpose_command: {
            
            //If there is already a solution, skip
            if (solution.resultDialog) break;
            
            NSArray *failed = [solution.resultObjs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"value != 1"]];
            
            if (failed.count == 0) {
                solution.resultObjs = @[[[GCValue alloc] initNumber:[NSNumber numberWithBool:true]]];
                if (!solution.resultDialog) solution.resultDialog = @"All Done";
            } else {
                solution.resultObjs = @[[[GCValue alloc] initNumber:[NSNumber numberWithBool:false]]];
                if (failed.count == solution.resultObjs.count)
                    solution.resultDialog = @"I can't do it";
                else solution.resultDialog = @"Something is wrong";
            }
            
            return true;
        }
            break;
            
        case messagePurpose_question: {
            
            if (returnTypes == [GCBoolean class]) {
                if (solution.resultObjs.count == 1) {
                    if (((NSNumber *)[solution.resultObjs[0] value]).boolValue)
                        solution.resultDialog = @"Yes";
                    else solution.resultDialog = @"No";
                }
            }
            else {
                if (solution.resultObjs.count == 0) {
                    solution.errorMessage = solution.resultDialog = @"Wrong result type";
                    return false;
                }
                else if (solution.resultObjs.count == 1) {
                    GCObject *obj = solution.resultObjs[0];
                    NSString *format = [obj valueForKey:@"outputFormat"];
                    if (format) solution.resultDialog = [NSString stringWithFormat:format, obj.description];
                    else solution.resultDialog = obj.description;
                } else {
                    solution.resultDialog = @"They are";
                    for (GCObject *obj in solution.resultObjs) {
                        solution.resultDialog = [solution.resultDialog stringByReplacingOccurrencesOfString:@"_-"withString:@" "];
                        solution.resultDialog = [solution.resultDialog stringByAppendingFormat:@"_-%@", obj.name];
                    }
                    solution.resultDialog = [solution.resultDialog stringByReplacingOccurrencesOfString:@"_-"withString:@" and "];
                    
                }
            }
            
            solution.resultDialog = [solution.resultDialog stringByReplacingOccurrencesOfString:@"(null)"withString:@""];
            return true;
        }
            break;
            
        case messagePurpose_exclamation: {
            switch (exType) {
                case exclamationType_greet: {
                    if (solution.resultObjs.count) {
                        //At least one object. i.e. there exist come constraints
                        GCValue *_result = solution.resultObjs[0];
                        if (!_result.value.boolValue) {
                            solution.resultDialog = @"You can't say that";
                            return true;
                        }
                    }
                    solution.resultDialog = inputMessage;
                    return true;
                }
                    break;
                    
                case exclamationType_gratutyde: {
#warning - Change the condition to "if the previous query has fulfill some request/fetch/whatever"
                    if (true) {
                        solution = [QuerySolution new];
                        solution.resultDialog = @"you're welcome";
                    } else {
                        solution = [QuerySolution new];
                        solution.resultDialog = @"what for?";
                    }
                }
                default:
                    break;
            }
            return true;
        }
            break;
            
        default:
            solution.resultDialog = @"Not defined";
            break;
    }
    
    return false;
}

- (void)invalidate {
    validate = false;
}

@end