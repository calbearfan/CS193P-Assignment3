//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Mike Dunker on 6/23/12.
//  Copyright (c) 2012 Dunker Development. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
+ (NSSet *)operations;
+ (NSSet *)zeroParameterOperations;
+ (NSSet *)oneParameterOperations;
+ (NSSet *)twoParameterOperations;
+ (BOOL)isOperation:(NSString *)str;
+ (BOOL)isVariable:(NSString *)str;
+ (BOOL)isZeroParameterOperation:(NSString *)str;
+ (BOOL)isOneParameterOperation:(NSString *)str;
+ (BOOL)isTwoParameterOperation:(NSString *)str;
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack;
+ (NSString *)peekAtOperationOnTopOfStack:(NSMutableArray *)stack;

@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

+ (NSSet *)zeroParameterOperations
{
    static NSSet * _zeroParameterOperations = nil;
    
    if (!_zeroParameterOperations)
        _zeroParameterOperations = [NSSet setWithObjects:@"π", nil];
    
    return _zeroParameterOperations;
}

+ (NSSet *)oneParameterOperations
{
    static NSSet * _oneParameterOperations = nil;
    
    if (!_oneParameterOperations)
        _oneParameterOperations = [NSSet setWithObjects:@"sin", @"cos", @"sqrt", @"+/-", nil];
    
    return _oneParameterOperations;
}

+ (NSSet *)twoParameterOperations
{
    static NSSet * _twoParameterOperations = nil;
    
    if (!_twoParameterOperations)
        _twoParameterOperations = [NSSet setWithObjects:@"+", @"-", @"*", @"/", nil];
    
    return _twoParameterOperations;
}

+ (NSSet *)operations
{
    static NSMutableSet * _operations = nil;
    
    if (!_operations) {
        _operations = [[NSMutableSet alloc] initWithSet:[self zeroParameterOperations]];
        [_operations unionSet:[self oneParameterOperations]];
        [_operations unionSet:[self twoParameterOperations]];
    }
    
    return _operations;
}

- (id)program
{
    return [self.programStack copy];
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariableOperand:(NSString *)variableName
{
    if (![[self class] isOperation:variableName])
    {
        [self.programStack addObject:variableName];
    }
}

- (void)removeTopOfStack
{
    if ([self.programStack count] > 0)
    {
        [self.programStack removeLastObject];
    }
}

//- (double)peekOperand
//{
//    NSNumber *operandObject = [self.operandStack lastObject];
//    return [operandObject doubleValue];
//}

//- (double)popOperand
//{
//    NSNumber *operandObject = [self.operandStack lastObject];
//    if (operandObject) [self.operandStack removeLastObject];
//    return [operandObject doubleValue];
//}

- (id)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program usingVariableValues:variableValues];
}

- (id)performOperation:(NSString *)operation
{
    return [self performOperation:operation usingVariableValues:nil];
}

+ (BOOL)isOperation:(NSString *)str
{
    return ([[self operations] containsObject:str]);
}

+ (BOOL)isZeroParameterOperation:(NSString *)str
{
    return ([[self zeroParameterOperations] containsObject:str]);
}

+ (BOOL)isOneParameterOperation:(NSString *)str
{
    return ([[self oneParameterOperations] containsObject:str]);
}

+ (BOOL)isTwoParameterOperation:(NSString *)str
{
    return ([[self twoParameterOperations] containsObject:str]);
}

+ (BOOL)isVariable:(NSString *)str
{
    return ![self isOperation:str];
}

+ (id)popOperandOffProgramStack:(NSMutableArray *)stack
{
    id result = [NSNumber numberWithDouble:0.0];
    
    id topOfStack = [stack lastObject];
    if (topOfStack)
    {
        [stack removeLastObject];
    }
    
    if (!topOfStack)
    {
        result = nil;
    }
    else if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack copy];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            id operand2 = [self popOperandOffProgramStack:stack];
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1 || !operand2)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]] &&
                [operand2 isKindOfClass:[NSNumber class]])
            {
                double resultValue = [operand1 doubleValue] + [operand2 doubleValue];
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand2;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else if ([operation isEqualToString:@"*"]) {
            id operand2 = [self popOperandOffProgramStack:stack];
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1 || !operand2)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]] &&
                [operand2 isKindOfClass:[NSNumber class]])
            {
                double resultValue = [operand1 doubleValue] * [operand2 doubleValue];
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand2;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else if ([operation isEqualToString:@"-"]) {
            id operand2 = [self popOperandOffProgramStack:stack];
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1 || !operand2)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]] &&
                [operand2 isKindOfClass:[NSNumber class]])
            {
                double resultValue = [operand1 doubleValue] - [operand2 doubleValue];
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand2;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else if ([operation isEqualToString:@"/"]) {
            id operand2 = [self popOperandOffProgramStack:stack];
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1 || !operand2)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand2 isKindOfClass:[NSNumber class]] && [operand2 doubleValue] == 0.0)
            {
                result = @"DIVIDE BY ZERO";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]] &&
                [operand2 isKindOfClass:[NSNumber class]])
            {
                double resultValue = [operand1 doubleValue] / [operand2 doubleValue];
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand2;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else if ([operation isEqualToString:@"sin"]) {
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]])
            {
                double resultValue = sin([operand1 doubleValue]);
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else if ([operation isEqualToString:@"cos"]) {
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]])
            {
                double resultValue = cos([operand1 doubleValue]);
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else if ([operation isEqualToString:@"sqrt"]) {
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]] && [operand1 doubleValue] < 0)
            {
                result = @"SQRT OF NEGATIVE NUMBER";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]])
            {
                double resultValue = sqrt([operand1 doubleValue]);
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else if ([operation isEqualToString:@"π"]) {
            result = [NSNumber numberWithDouble:M_PI];
        } else if ([operation isEqualToString:@"+/-"]) {
            id operand1 = [self popOperandOffProgramStack:stack];
            if (!operand1)
            {
                result = @"NOT ENOUGH OPERANDS";
            }
            else if ([operand1 isKindOfClass:[NSNumber class]])
            {
                double resultValue = 0 - [operand1 doubleValue];
                result = [NSNumber numberWithDouble:resultValue];
            }
            else if ([operand1 isKindOfClass:[NSString class]])
            {
                result = operand1;
            }
            else
            {
                result = [NSNumber numberWithDouble:0.0];
            }
        } else {
            // assume it is an unmatched variable, which should be zero
            result = [NSNumber numberWithDouble:0.0];
        }
    }
    
    // clear negative zero
    if ([result isKindOfClass:[NSNumber class]] && [result doubleValue] == 0.0)
    {
        result = [NSNumber numberWithDouble:0.0];
    }
    
    return result;
}

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // find variables and replace with supplied values
    for (int i=0; i<stack.count; i++)
    {
        id elem = [stack objectAtIndex:i];
        if ([elem isKindOfClass:[NSString class]] &&
            [self isVariable:elem])
        {
            NSString *variableName = elem;
            if (variableValues)
            {
                id variableValueObject = [variableValues valueForKey:variableName];
                if ([variableValueObject isKindOfClass:[NSNumber class]])
                {
                    // replace element in stack
                    [stack replaceObjectAtIndex:i withObject:[variableValueObject copy]];
                }
                else
                {
                    // variable not found, treat as 0
                    [stack replaceObjectAtIndex:i withObject:
                     [NSNumber numberWithDouble:0.0]];
                }
            }
            else
            {
                // no variable list supplied, all are treated as 0
                [stack replaceObjectAtIndex:i withObject:
                 [NSNumber numberWithDouble:0.0]];
            }
        }
    }
    
    return [self popOperandOffProgramStack:stack];
}

+ (id)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

+ (NSString *)peekAtOperationOnTopOfStack:(NSMutableArray *)stack
{
    id topOfStack = [stack lastObject];
    // don't removeLastObject, this is a peek
    
    if ([topOfStack isKindOfClass:[NSString class]] && [self isOperation:topOfStack])
    {
        return topOfStack;
    }
    else
    {
        // not an operation
        return nil;
    }
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *desc;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        double value = [topOfStack doubleValue];
        desc = [NSString stringWithFormat:@"%g", value];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *token = topOfStack;
        if ([self isVariable:token]) {
            desc = token;
        }
        else if ([self isZeroParameterOperation:token]) {
            desc = token;
        }
        else if ([self isOneParameterOperation:token]) {
            if ([token isEqualToString:@"+/-"]) token = @"-";
            desc = [NSString stringWithFormat:@"%@(%@)", token,
                    [self descriptionOfTopOfStack:stack]];
        }
        else if ([self isTwoParameterOperation:token]) {
            NSString *peekOperand2 = [self peekAtOperationOnTopOfStack:stack];
            NSString *operand2 = [self descriptionOfTopOfStack:stack];
            NSString *peekOperand1 = [self peekAtOperationOnTopOfStack:stack];
            NSString *operand1 = [self descriptionOfTopOfStack:stack];
            BOOL currentOpIsMultiplyOrDivide = ([token isEqualToString:@"*"] ||
                                                [token isEqualToString:@"/"]);
            BOOL operand1IsAddOrSubtract = ([peekOperand1 isEqualToString:@"+"] ||
                                            [peekOperand1 isEqualToString:@"-"]);
            BOOL operand2IsAddOrSubtract = ([peekOperand2 isEqualToString:@"+"] || 
                                            [peekOperand2 isEqualToString:@"-"]);
            if (currentOpIsMultiplyOrDivide && operand1IsAddOrSubtract)
            {
                // wrap if operand operation is lower priority
                operand1 = [NSString stringWithFormat:@"(%@)", operand1];
            }
            if ((currentOpIsMultiplyOrDivide && operand2IsAddOrSubtract) ||
                [peekOperand2 isEqualToString:@"+/-"])
            {
                // operand 2 also needs parens if it is a sign change operator
                operand2 = [NSString stringWithFormat:@"(%@)", operand2];
            }
            desc = [NSString stringWithFormat:@"%@ %@ %@",
                    operand1, token, operand2];
        }
    }
    
    return desc;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    NSString *desc = @"";
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        
        while (stack.count) {
            desc = [desc stringByAppendingString:[self descriptionOfTopOfStack:stack]];
            if (stack.count) {
                // separate with commas
                desc = [desc stringByAppendingString:@", "];
            }
        }
    }
    
    return desc;
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *variablesUsed = [[NSMutableSet alloc] init];
    
    if ([program isKindOfClass:[NSArray class]]) {
        for (id elem in program)
        {
            if ([elem isKindOfClass:[NSString class]] && [self isVariable:elem])
            {
                [variablesUsed addObject:elem];
            }
        }
    }
    
    if ([variablesUsed count] > 0) {
        return [variablesUsed copy];
    } else {
        return nil;
    }
}

- (void)performClear
{
    [self.programStack removeAllObjects];
}

@end
