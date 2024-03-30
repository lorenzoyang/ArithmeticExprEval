#include <string.h>
#include <stdio.h>
#include <limits.h>
#include "ArithmeticExpreVal.h"

// 1+(2*3)
int eval(const char *expression, int *index, ErrorType *error)
{
    int value = 0, temp = 0;
    char op = ' '; // no operator

    while (expression[*index] != '\0')
    {
        if (expression[*index] == '(')
        {
            (*index)++;
            temp = eval(expression, index, error);
            if (*error != NoError)
                return 0;
        }
        else if (expression[*index] >= '0' && expression[*index] <= '9')
        {
            int length = 1;
            while (expression[*index + length] >= '0' && expression[*index + length] <= '9')
                length++;
            temp = string2int(expression + *index, length, error);
            *index += length - 1;
        }
        else if (expression[*index] == ')')
        {
            (*index)++;
            break;
        }
        else if (expression[*index] == '+' || expression[*index] == '-' ||
                 expression[*index] == '*' || expression[*index] == '/')
        {
            op = expression[*index];
            (*index)++;
            continue;
        }
        else
        {
            *error = SyntaxError;
            return 0;
        }

        switch (op)
        {
        case ' ':
            value = temp;
            break;
        case '+':
            value = safe_add(value, temp, error);
            break;
        case '-':
            value = safe_sub(value, temp, error);
            break;
        case '*':
            value = safe_mul(value, temp, error);
            break;
        case '/':
            value = safe_div(value, temp, error);
            break;
        }

        if (*error != NoError)
            return 0;

        (*index)++;
    }

    return value;
}

/**
 * private function
 * Convert a string that contains only positive integer digits to an integer
 */
int string2int(const char *expression, int length, ErrorType *error)
{
    int result = 0, index = 0;
    while (index < length)
    {
        if (expression[index] >= '0' && expression[index] <= '9')
        {
            result = result * 10 + expression[index] - '0';
            // check for overflow
            if (result < 0)
            {
                *error = OverflowError;
                return 0;
            }
        }
        index++;
    }
    return result;
}

/**
 * private function
 * Add two integers safely
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

/**
 * private function
 * Subtract two integers safely
 */
int safe_sub(int a, int b, ErrorType *error)
{
    if (b > 0 && a < (INT_MIN + b) || b < 0 && a > (INT_MAX + b))
    {
        *error = OverflowError;
        return 0;
    }
    return a - b;
}

/**
 * private function
 * Multiply two integers safely
 */
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

/**
 * private function
 * Divide two integers safely
 */
int safe_div(int a, int b, ErrorType *error)
{
    if (b == 0)
    {
        *error = DivisionByZeroError;
        return 0;
    }
    return a / b;
}
