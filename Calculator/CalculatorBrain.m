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
@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in Homework #2";
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariableOperand:(NSString *)variableName
{
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
        } else if ([@"*" isEqualToString:operation]) {
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
    return [self popOperandOffProgramStack:stack];
}

+ (double)runProgram:(id)program
{
    // implement using empty variable values dictionary
    NSDictionary *variableValues = [[NSDictionary alloc] init];
    return [self runProgram:program usingVariableValues:variableValues];
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
