#ifndef ARITHMETICEXPREVAL_H
#define ARITHMETICEXPREVAL_H

typedef enum
{
    NoError,             // No error
    SyntaxError,         // Arithmetic expression syntax error
    DivisionByZeroError, // Division by zero error
    OverflowError        // Overflow error
} ErrorType;

/**
 * Evaluate the arithmetic expression.
 */
int evaluate(const char *expression, ErrorType *error);

/**
 * Add two integers safely, checking for overflow.
 */
int safe_add(int a, int b, ErrorType *error);

/**
 * Subtract two integers safely, checking for overflow.
 */
int safe_sub(int a, int b, ErrorType *error);

/**
 * Multiply two integers safely, checking for overflow.
 */
int safe_mul(int a, int b, ErrorType *error);

/**
 * Divide two integers safely, checking for division by zero.
 */
int safe_div(int a, int b, ErrorType *error);

#endif // ARITHMETICEXPREVAL_H
