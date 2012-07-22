//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Mike Dunker on 6/23/12.
//  Copyright (c) 2012 Dunker Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushVariableOperand:(NSString *)variableName;
- (void)removeTopOfStack;
//- (double)performOperation:(NSString *)operation withErrorMessage:(NSString **)pErrMsg;
- (double)performOperation:(NSString *)operation;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues;
- (void)performClear;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
