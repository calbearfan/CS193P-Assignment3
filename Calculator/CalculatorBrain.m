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
        [self.programStack addObject:variableName];
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

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
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

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] +
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] *
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor)
            {
                result = [self popOperandOffProgramStack:stack] / divisor;
            }
            else
            {
                // should result in error
                // burn an operand
                [self popOperandOffProgramStack:stack];
                result = 0;
            }
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            double operand = [self popOperandOffProgramStack:stack];
            if (operand >= 0)
                result = sqrt(operand);
            else {
                // should result in error
                result = 0;
            }
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"+/-"]) {
            result = 0 - [self popOperandOffProgramStack:stack];
        } else {
            // assume it is an unmatched variable, which should be zero
            result = 0;
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    if (variableValues)
    {
        // find variables and replace with supplied values
        for (int i=0; i<stack.count; i++)
        {
            id elem = [stack objectAtIndex:i];
            if ([elem isKindOfClass:[NSString class]])
            {
                NSString *variableName = elem;
                id variableValueObject = [variableValues valueForKey:variableName];
                if ([variableValueObject isKindOfClass:[NSNumber class]])
                {
                    // replace element in stack
                    [stack replaceObjectAtIndex:i withObject:[variableValueObject copy]];
                }
            }
        }
    }
    
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
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
            NSString *operand2 = [self descriptionOfTopOfStack:stack];
            NSString *operand1 = [self descriptionOfTopOfStack:stack];
            desc = [NSString stringWithFormat:@"(%@ %@ %@)",
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
    }
    
    while (stack.count) {
        desc = [desc stringByAppendingString:[self descriptionOfTopOfStack:stack]];
        if (stack.count) {
            // separate with commas
            desc = [desc stringByAppendingString:@", "];
        }
    }
    
    return desc;
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *variablesUsed = [[NSMutableSet alloc] init];
    
    for (id elem in program)
    {
        if ([elem isKindOfClass:[NSString class]] && [self isVariable:elem])
        {
            [variablesUsed addObject:elem];
        }
    }
    
    if ([variablesUsed count] > 0) {
        return [variablesUsed copy];
    } else {
        return nil;
    }
}

//- (double)performOperation:(NSString *)operation
//           withErrorMessage:(NSString **)pErrMsg
//{
//    double result = 0;
//    BOOL valid = YES;
//    
//    if ([operation isEqualToString:@"+"])
//    {
//        result = [self popOperand] + [self popOperand];
//    }
//    else if ([operation isEqualToString:@"-"])
//    {
//        double subtrahend = [self popOperand];
//        result = [self popOperand] - subtrahend;
//    }
//    else if ([operation isEqualToString:@"*"])
//    {
//        result = [self popOperand] * [self popOperand];
//    }
//    else if ([operation isEqualToString:@"/"])
//    {
//        double divisor = [self peekOperand];
//        if (divisor)
//        {
//            [self popOperand];
//            result = [self popOperand] / divisor;
//        }
//        else
//        {
//            valid = NO;
//            if (pErrMsg) *pErrMsg = @"Cannot divide by zero.";
//        }
//    }
//    else if ([operation isEqualToString:@"sin"])
//    {
//        result = sin([self popOperand]);
//    }
//    else if ([operation isEqualToString:@"cos"])
//    {
//        result = cos([self popOperand]);
//    }
//    else if ([operation isEqualToString:@"sqrt"])
//    {
//        double operand = [self peekOperand];
//        if (operand >= 0)
//            result = sqrt([self popOperand]);
//        else
//        {
//            valid = NO;
//            if (pErrMsg) *pErrMsg = @"Cannot take sqrt of negative number.";
//        }
//    }
//    else if ([operation isEqualToString:@"π"])
//    {
//        result = M_PI;
//    }
//    else if ([operation isEqualToString:@"+/-"])
//    {
//        result = 0 - [self popOperand];
//    }
//    
//    if (valid)
//    {
//        [self pushOperand:result];
//        return result;
//    }
//    else
//    {
//        return [self peekOperand];
//    }
//}

- (void)performClear
{
    [self.programStack removeAllObjects];
}

@end
