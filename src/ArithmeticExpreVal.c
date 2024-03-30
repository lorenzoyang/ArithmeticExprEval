#include <string.h>
#include <stdio.h>
#include <limits.h>
#include <stdbool.h>
#include "ArithmeticExpreVal.h"

// Private helper function to convert a string to an integer
int string2int(const char **expression, ErrorType *error);

int eval(const char **expr, ErrorType *error)
{
    int left = 0, right = 0, result = 0;
    char op = '_'; // '_' means no operator

    while ((**expr) != '\0')
    {
        if ((**expr) == '(') // new sub-expression
        {
            (*expr)++;
            if (op == '_') // no operator => left operand
            {
                left = eval(expr, error);
            }
            else // right operand
            {
                right = eval(expr, error);
            }
        }
        else if ((**expr) >= '0' && (**expr) <= '9')
        {
            if (op == '_') // no operator => left operand
            {
                left = string2int(expr, error);
            }
            else // right operand
            {
                right = string2int(expr, error);
            }
        }
        else if ((**expr) == '+' || (**expr) == '-' || (**expr) == '*' || (**expr) == '/')
        {
            op = (**expr);
            (*expr)++;
            continue;
        }
        else if ((**expr) == ')') // base case
        {

            break;
        }
        else
        {
            *error = SyntaxError;
            break;
        }

        switch (op)
        {
        case '+':
            result = safe_add(left, right, error);
            break;
        case '-':
            result = safe_sub(left, right, error);
            break;
        case '*':
            result = safe_mul(left, right, error);
            break;
        case '/':
            result = safe_div(left, right, error);
            break;
        default:
            break;
        }

        if ((**expr) == '\0')
            break;

        (*expr)++;
    }
    return result;
}

/**
 * ********************************************************************************************************************
 * helper functions
 ********************************************************************************************************************
 */

/**
 * Private helper function
 * Convert a string that contains only positive integer digits to an integer
 */

int string2int(const char **expression, ErrorType *error)
{
    int result = 0;
    while ((**expression) >= '0' && (**expression) <= '9')
    {
        result = result * 10 + (**expression) - '0';
        if (result < 0) // check for overflow
        {
            *error = OverflowError;
            return 0;
        }
        (*expression)++;
    }
    (*expression)--; // move back to the last digit
    return result;
}

int safe_add(int a, int b, ErrorType *error)
{
    if (b > 0 && a > (INT_MAX - b) || b < 0 && a < (INT_MIN - b))
    {
        *error = OverflowError;
        return 0;
    }
    return a + b;
}

int safe_sub(int a, int b, ErrorType *error)
{
    if (b > 0 && a < (INT_MIN + b) || b < 0 && a > (INT_MAX + b))
    {
        *error = OverflowError;
        return 0;
    }
    return a - b;
}

int safe_mul(int a, int b, ErrorType *error)
{
    if (a > 0)
    {
        if (b > 0 && a > (INT_MAX / b) || b < 0 && b < (INT_MIN / a))
        {
            *error = OverflowError;
            return 0;
        }
    }
    else
    {
        if (b > 0 && a < (INT_MIN / b) || b < 0 && a < (INT_MAX / b))
        {
            *error = OverflowError;
            return 0;
        }
    }
    return a * b;
}

int safe_div(int a, int b, ErrorType *error)
{
    if (b == 0)
    {
        *error = DivisionByZeroError;
        return 0;
    }
    return a / b;
}
