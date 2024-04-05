#ifndef ARITHMETIC_EXPRE_VAL_H
#define ARITHMETIC_EXPRE_VAL_H

typedef enum
{
    NoError,                  // No error
    SyntaxError,              // Arithmetic expression syntax error
    DivisionByZeroError,      // Division by zero error
    OverflowError,            // Overflow error
    ParenthesesMismatchError, // Parentheses mismatch error
} ErrorType;

/**
 * Evaluate the arithmetic expression.
 */
int evaluate(const char *expression, ErrorType *error);

const char *skip_spaces(const char *expr);

const char *read_operand(const char *expr, ErrorType *error, int *parentheses);

const char *read_operator(const char *expr, ErrorType *error);

/**
 * Convert a string that contains only positive integer digits to an integer
 */
int string2int(const char **expr, ErrorType *error);

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

#endif // ARITHMETIC_EXPRE_VAL_H
