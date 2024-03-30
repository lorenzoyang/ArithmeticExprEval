#include <string.h>
#include <stdio.h>
#include <limits.h>
#include <stdbool.h>
#include "arithmetic_expre_val.h"

// Private helper function to convert a string to an integer
int string2int(const char *expression, ErrorType *error, int *index);
// Private recursive helper function to evaluate the arithmetic expression
int eval(const char *expr, ErrorType *error, int *index, const int length, int *parentheses);

int evaluate(const char *expr, ErrorType *error)
{
    int index = 0;
    int length = strlen(expr);
    int parentheses = 0;
    int result = eval(expr, error, &index, length, &parentheses);

    if (parentheses != 0)
    {
        *error = ParenthesesMismatchError;
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
 * Evaluate the arithmetic expression.
 */
int eval(const char *expr, ErrorType *error, int *index, const int length, int *parentheses)
{
    int left = 0, right = 0, result = 0;
    char op = '_'; // '_' means no operator

    while (*index < length)
    {
        if (expr[*index] == '(') // new sub-expression
        {
            (*parentheses)++;

            (*index)++;
            if (op == '_') // no operator => left operand
            {
                left = eval(expr, error, index, length, parentheses);
            }
            else // right operand
            {
                right = eval(expr, error, index, length, parentheses);
            }
        }
        else if (expr[*index] >= '0' && expr[*index] <= '9')
        {
            if (op == '_') // no operator => left operand
            {
                left = string2int(expr, error, index);
            }
            else // right operand
            {
                right = string2int(expr, error, index);
            }
        }
        else if (expr[*index] == '+' || expr[*index] == '-' || expr[*index] == '*' || expr[*index] == '/')
        {
            op = expr[*index];
            (*index)++;
            continue;
        }
        else if (expr[*index] == ')') // base case
        {
            (*parentheses)--;
            if (*parentheses < 0)
            {
                *error = ParenthesesMismatchError;
                break;
            }
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
        (*index)++;
    }
    return result;
}

/**
 * Private helper function
 * Convert a string that contains only positive integer digits to an integer
 */

int string2int(const char *expression, ErrorType *error, int *index)
{
    int result = 0;
    while (expression[*index] >= '0' && expression[*index] <= '9')
    {
        result = result * 10 + expression[*index] - '0';
        if (result < 0) // check for overflow
        {
            *error = OverflowError;
            return 0;
        }
        (*index)++;
    }
    (*index)--; // move back to the last digit
    return result;
}

/***********************************************************************************************************************
 * Operations with overflow and division by zero checking
 * ********************************************************************************************************************
 */

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
