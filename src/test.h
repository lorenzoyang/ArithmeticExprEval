#ifndef TEST_H
#define TEST_H

#include "arithmetic_expre_val.h"

typedef struct
{
    const char *input; // input string (arithmetic expression to be evaluated) to be tested
    int result;        // result of the expression
    int expected;      // expected result of the expression
    ErrorType error;   // error type
} TestCase;

#endif // TEST_H