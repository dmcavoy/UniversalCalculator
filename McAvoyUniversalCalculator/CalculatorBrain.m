//
//  CalculatorBrain.m
//  McAvoyCalculator
//
//  Created by Danielle McAvoy on 2/8/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

#import "CalculatorBrain.h"
#include <math.h>

@interface CalculatorBrain()
//internal expression
@property (nonatomic) NSMutableArray * internalExpression;

// For performing operations with 2 operands
@property (nonatomic, strong) NSString *waitingOperation;
@property (nonatomic) double waitingOperand;

@end

@implementation CalculatorBrain

@synthesize operand = _operand;
@synthesize storageNumber = _storageNumber;
@synthesize waitingOperand = _waitingOperand;
@synthesize waitingOperation = _waitingOperation;
@synthesize equationDisplayText = _equationDisplayText;
@synthesize startDisplayOver = _startDisplayOver;
@synthesize internalExpression = _internalExpression;
@synthesize expression = _expression;


- (NSMutableArray *)internalExpression {
    if (!_internalExpression)
        _internalExpression = [[NSMutableArray alloc] init];
    return _internalExpression;
}

- (id)expression {
    NSArray *newArray = [self.internalExpression copy];
    return newArray;
}

// ********************
// ** Hidden Methods **
// ********************

/* This method deals with the issue that sometimes we
 need multiple operands to do an operation. So we save
 those values and then do the math with them here.
 */
-(void)performWaitingOperation{
    
    if([@"+" isEqual:self.waitingOperation]){
        self.operand = self.waitingOperand + self.operand;
    }
    else if([@"*" isEqual:self.waitingOperation]){
        self.operand = self.waitingOperand * self.operand;
    }
    else if([@"-" isEqual:self.waitingOperation]){
        self.operand = self.waitingOperand - self.operand;
    }
    else if([@"/" isEqual:self.waitingOperation]){
        // make sure not dividing by zero
        // silent fail
        if (self.operand){
            self.operand = self.waitingOperand / self.operand;
        }
        // if it is divid by Zero tell the user
        // Also reset the operand so that now
        // the user has to start over
        else{
            self.startDisplayOver = YES;
            self.equationDisplayText = @"Divid by Zero!";
            self.operand = 0;
        }
    }
}

/*
 Checks if the operation is a variable.
 
 Parameter
 operation -> operation to check if variable
 
 Return
 BOOL -> True if is a variable
 */

+(BOOL)isAVariable:(NSString *)operation{
    return ([operation length] > 1 && [[operation substringWithRange:(NSRange){0,1}] isEqualToString:VARIABLE_PREFIX]);
}

// ********************
// ** Public Methods **
// ********************

/* EXPRESSION MANAGEMENT FUNCTIONS */

+ (double)evaluateExpression:(id)anExpression
         usingVariableValues:(NSDictionary *)variables{
    
    CalculatorBrain *tempBrain = [[CalculatorBrain alloc]init];
    
    double tempOperand;
    for (id obj in anExpression) {
        
        // Check if it is a number
        if ([obj isKindOfClass:[NSNumber class]]) {
            [tempBrain pushOperand: [obj doubleValue]];
        }
        
        // Check if it is an NSString
        else if ([obj isKindOfClass:[NSString class]]) {
            NSString * temp = (NSString*)obj;
            
            // Variable
            // This should fail silently if not a defined variable
            if ([self isAVariable:temp]) {
                for (id key in variables) {
                    if ([(NSString*)key isEqualToString:[temp substringFromIndex:1]]) {
                        [tempBrain pushOperand: [[variables objectForKey:key]doubleValue]];
                    }
                }
            }
            
            // Operation
            else{
                tempOperand =[tempBrain performOperation:temp];
            }
        }
    }
    return tempOperand;
}

+ (NSSet *)variablesInExpression:(id)anExpression{
    NSMutableSet * variableSet = [[NSMutableSet alloc]init];
    for (id obj in anExpression) {
        // Check if it is an NSString
        if ([obj isKindOfClass:[NSString class]]) {
            NSString * temp = (NSString*)obj;
        
            // Variable
            if ([self isAVariable:temp]) {
                NSString *variable = [temp substringFromIndex:1];
                // Not already in set
                if (![variableSet member:variable]) {
                    [variableSet addObject:variable];
                }
            }
        }
    }
    
    // Return nil if no variables
    if ([variableSet count]== 0) {
        return nil;
    }
    
    return variableSet;
}


+ (NSString *)descriptionOfExpression:(id)anExpression{
    
    NSString * description = [[NSString alloc]init];
    
    for (id obj in anExpression) {
        
        // Check if it is a number
        if ([obj isKindOfClass:[NSNumber class]]) {
            description = [[description stringByAppendingString: @" "]stringByAppendingFormat:@"%@", obj];
        }
        
        // Check if it is an NSString
        else if ([obj isKindOfClass:[NSString class]]) {
            NSString * temp = (NSString*)obj;
            
            // Variable
            if ([self isAVariable:temp]) {
                description =[[description stringByAppendingString: @" "]stringByAppendingString:[temp substringFromIndex:1]];
            }
            
            // Operation
            else{
                description = [[description stringByAppendingString: @" "]stringByAppendingString:temp];
            }
        }
    }
    return description;
}

+(id)propertyListForExpression:(id)anExpression{
    NSArray *propertyList = anExpression;
    return propertyList;
}


+(id)expressionForPropertyList:(id)propertyList{
    NSMutableArray *tempExpression = propertyList;
    return tempExpression;
}

-(void) setVariableAsOperand:(NSString *)variableName{
    [self.internalExpression addObject: [VARIABLE_PREFIX stringByAppendingString: variableName]];
}

/*
 Checks if the operation is a memory operation. 
 
 Parameters
 operation-> operation to check
 
 Return:
 BOOL -> true if is a memory operation
 */
-(BOOL)isMemoryOperation:(NSString *)operation{
    return([@"Mem+" isEqual:operation] || [@"Store" isEqual:operation] || [@"Recal" isEqual:operation]);
}

/* CALCULATION METHODS */

-(void) pushOperand: (double)aDouble{
    [self.internalExpression addObject:
        [NSNumber numberWithDouble:aDouble]];
    self.operand = aDouble;
}

-(double)performOperation:(NSString*)operation{
    
    // Keeps user from using memory functions once you
    // Are dealing with variables
    if (!([self isMemoryOperation:operation] && [CalculatorBrain variablesInExpression:self.expression])) {
        [self.internalExpression addObject:operation];
    }

    self.equationDisplayText = [self.equationDisplayText stringByAppendingString:[@" " stringByAppendingString: [operation stringByAppendingString:@" "]]];
    
    // single operand operations
    if([operation isEqual:@"sqrt"]){
        if(self.operand >= 0){
            self.operand = sqrt(self.operand);
        }
        else{
            self.startDisplayOver = YES;
            self.equationDisplayText = @"Not a real number";
            self.operand = 0;
        }
    }
    else if([@"+/-" isEqual:operation]){
        //zero does not have a sign
        if (self.operand) {
            self.operand = -self.operand;
        }
    }
    else if([@"1/x" isEqual:operation]){
        //deal with divid by zero by failing
        //silently
        if(self.operand){
            self.operand = 1 / self.operand;
        }
        else{
            self.startDisplayOver = YES;
            self.equationDisplayText = @"Divid by Zero!";
            self.operand = 0;
        }
    }
    else if([@"cos" isEqual:operation]){
        self.operand = cos(self.operand);
    }
    else if([@"sin" isEqual:operation]){
        self.operand = sin(self.operand);
    }
    
    // Memory Operations
    // Treat like Single Operand Operations
    else if([@"Store" isEqual:operation]){
        self.storageNumber = self.operand;
        self.startDisplayOver = YES;
    }
    else if([@"Recall" isEqual:operation]){
        self.operand = self.storageNumber;
        self.equationDisplayText = operation;
        self.startDisplayOver = YES;
    }
    else if([@"Mem+" isEqual:operation]){
        self.storageNumber = self.storageNumber + self.operand;
        self.operand = self.storageNumber;
        self.startDisplayOver = YES;
    }
    
    // 2-operand operations
    else{
        
        if ([@"="isEqual:operation]) {
            self.startDisplayOver = YES;
        }
        
        [self performWaitingOperation];
        self.waitingOperation = operation;
        self.waitingOperand = self.operand;
    }
    
    return self.operand;
}

-(void)clearVariables{
    self.operand = 0;
    self.storageNumber = 0;
    self.waitingOperation = nil;
    self.waitingOperand = 0;
    self.equationDisplayText = @"0";
    self.startDisplayOver = YES;
    self.internalExpression = nil;  
}
@end
