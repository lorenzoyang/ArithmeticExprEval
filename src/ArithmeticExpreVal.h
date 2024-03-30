#ifndef ARITHMETICEXPREVAL_H
#define ARITHMETICEXPREVAL_H

typedef enum
{
    NoError,             // No error
    SyntaxError,         // Arithmetic expression syntax error
    DivisionByZeroError, // Division by zero error
    OverflowError        // Overflow error
} ErrorType;

typedef struct
{
    int value;       // The result of the evaluation
    ErrorType error; // The error type
} EvalResult;

int eval(const char *expression, int *index, ErrorType *error);
int string2int(const char *expression, int length, ErrorType *error);

int safe_add(int a, int b, ErrorType *error);
int safe_sub(int a, int b, ErrorType *error);
int safe_mul(int a, int b, ErrorType *error);
int safe_div(int a, int b, ErrorType *error);

#endif // ARITHMETICEXPREVAL_H
